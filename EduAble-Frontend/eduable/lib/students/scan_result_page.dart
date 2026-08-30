import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import '../services/ai_explanation_service.dart';



class ScanResultPage extends StatefulWidget {
  final File imageFile;

  const ScanResultPage({super.key, required this.imageFile});

  @override
  State<ScanResultPage> createState() => _ScanResultPageState();
}

class _ScanResultPageState extends State<ScanResultPage> {
  String extractedText = '';
  bool isProcessing = true;
  String? error;
  List<String> keyConcepts = [];
  List<Map<String, dynamic>> practiceQuestions = [];

  // Quiz state
  Map<int, String?> userAnswers = {}; // question index -> selected answer
  bool isQuizSubmitted = false;
  int correctAnswers = 0;
  int totalQuestions = 0;
  Map<int, String> questionExplanations = {};
  Map<int, bool> loadingExplanations = {};
  Map<int, bool> firstAttemptWrong = {};
  Map<int, bool> hasRetried = {};

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    try {
      setState(() {
        isProcessing = true;
        error = null;
      });

      final textRecognizer = TextRecognizer();
      final InputImage inputImage = InputImage.fromFile(widget.imageFile);
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      String text = recognizedText.text;

      await textRecognizer.close();

      if (text.isEmpty) {
        setState(() {
          error = 'No text found in the image. Please try another image.';
          isProcessing = false;
        });
        return;
      }

      setState(() {
        extractedText = text;
        isProcessing = false;
      });

      // Generate key concepts and practice questions
      _generateKeyConcepts(text);
      _generatePracticeQuestions(text);
    } catch (e) {
      setState(() {
        error = 'Failed to process image: $e';
        isProcessing = false;
      });
    }
  }

  void _generateKeyConcepts(String text) {
    // Simple algorithm to extract key concepts
    List<String> sentences = text.split(RegExp(r'[.!?]+'));
    sentences = sentences.where((s) => s.trim().isNotEmpty).toList();

    // Take first 5-7 important sentences as key concepts
    keyConcepts = sentences.take(6).map((s) => s.trim()).toList();
  }

  void _generatePracticeQuestions(String text) {
    practiceQuestions = [];

    // Extract sentences and filter meaningful ones
    List<String> sentences = text.split(RegExp(r'[.!?]+'));
    sentences = sentences.where((s) => s.trim().length > 15).toList();

    // Extract key terms (capitalized words, numbers, important terms)
    List<String> keyTerms = _extractKeyTerms(text);

    // Generate different types of questions
    int questionType = 0;

    for (int i = 0; i < sentences.length && practiceQuestions.length < 5; i++) {
      String sentence = sentences[i].trim();

      // Skip very short or very long sentences
      if (sentence.length < 20 || sentence.length > 200) continue;

      List<String> words = sentence.split(RegExp(r'\s+'));

      if (words.length >= 4) {
        // Rotate through question types
        int qType = questionType % 3;

        if (qType == 0 && keyTerms.isNotEmpty) {
          // Type 1: Fill-in-the-blank with actual key terms
          practiceQuestions.add(
            _createFillInBlankQuestion(sentence, keyTerms, words),
          );
        } else if (qType == 1) {
          // Type 2: True/False question
          practiceQuestions.add(_createTrueFalseQuestion(sentence, text));
        } else if (qType == 2) {
          // Type 3: Comprehension MCQ based on sentence content
          practiceQuestions.add(
            _createComprehensionQuestion(sentence, sentences, keyTerms),
          );
        }

        questionType++;
      }
    }

    // If we couldn't generate enough questions, add more fill-in-the-blank
    if (practiceQuestions.isEmpty && sentences.isNotEmpty) {
      for (
        int i = 0;
        i < sentences.length && practiceQuestions.length < 3;
        i++
      ) {
        String sentence = sentences[i].trim();
        List<String> words = sentence.split(RegExp(r'\s+'));
        if (words.length >= 4) {
          practiceQuestions.add(
            _createFillInBlankQuestion(sentence, [], words),
          );
        }
      }
    }
  }

  List<String> _extractKeyTerms(String text) {
    List<String> keyTerms = [];

    // Extract capitalized words (potential important terms)
    RegExp capitalizedWord = RegExp(r'\b[A-Z][a-z]+\b');
    Iterable<Match> matches = capitalizedWord.allMatches(text);

    for (Match match in matches) {
      String word = match.group(0)!;
      // Filter out common words
      if (!_isCommonWord(word) && !keyTerms.contains(word)) {
        keyTerms.add(word);
      }
    }

    // Extract numbers with units (dates, measurements, etc.)
    RegExp numberPattern = RegExp(
      r'\b\d+(\.\d+)?\s*(years|days|hours|minutes|percent|million|billion|cm|kg|m)?\b',
    );
    matches = numberPattern.allMatches(text);

    for (Match match in matches) {
      String term = match.group(0)!;
      if (!keyTerms.contains(term)) {
        keyTerms.add(term);
      }
    }

    return keyTerms.take(20).toList(); // Limit to 20 key terms
  }

  bool _isCommonWord(String word) {
    const commonWords = [
      'The',
      'This',
      'That',
      'These',
      'Those',
      'What',
      'Which',
      'Who',
      'When',
      'Where',
      'Why',
      'How',
      'And',
      'But',
      'For',
      'Not',
      'You',
      'All',
      'Can',
      'Had',
      'Her',
      'Was',
      'One',
      'Our',
      'Out',
      'Day',
      'Get',
      'Has',
      'Him',
      'His',
      'May',
      'New',
      'Now',
      'Old',
      'See',
      'Two',
      'Way',
      'Who',
      'Boy',
      'Did',
      'Its',
      'Let',
      'Put',
      'Say',
      'She',
      'Too',
      'Use',
      'I',
      'A',
      'An',
      'In',
      'To',
      'Is',
      'It',
      'Of',
      'On',
      'As',
      'At',
      'By',
      'Or',
      'So',
      'If',
      'Do',
      'Be',
      'He',
      'Me',
      'We',
      'They',
      'Them',
      'Their',
      'There',
      'Here',
      'From',
      'With',
      'About',
      'Between',
      'Through',
      'During',
      'Before',
      'After',
      'Above',
      'Below',
      'Up',
      'Down',
      'Only',
      'Very',
      'Just',
    ];
    return commonWords.contains(word);
  }

  Map<String, dynamic> _createFillInBlankQuestion(
    String sentence,
    List<String> keyTerms,
    List<String> words,
  ) {
    // Try to find a key term in the sentence
    String? targetWord;

    for (String term in keyTerms) {
      if (sentence.contains(term)) {
        targetWord = term;
        break;
      }
    }

    // If no key term found, pick a meaningful word (not common words)
    if (targetWord == null) {
      for (String word in words) {
        String cleanWord = word.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
        if (cleanWord.length > 3 && !_isCommonWord(cleanWord)) {
          targetWord = cleanWord;
          break;
        }
      }
    }

    // Fallback: pick middle word
    if (targetWord == null) {
      int index = words.length ~/ 2;
      targetWord = words[index].replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    }

    // Create blank
    String blankSentence = sentence.replaceAll(targetWord, '________');

    // Generate wrong options from other key terms or similar words
    List<String> wrongOptions = [];
    for (String term in keyTerms) {
      if (term != targetWord && term.length > 3 && wrongOptions.length < 3) {
        wrongOptions.add(term);
      }
    }

    // Fill remaining with variations
    while (wrongOptions.length < 3) {
      wrongOptions.add('Option ${wrongOptions.length + 1}');
    }

    List<String> options = [targetWord, ...wrongOptions.take(3)];
    options.shuffle(); // Randomize order

    return {
      'question': 'Fill in the blank: "$blankSentence"',
      'options': options,
      'correct': targetWord,
      'type': 'Fill in the Blank',
    };
  }

  Map<String, dynamic> _createTrueFalseQuestion(
    String sentence,
    String fullText,
  ) {
    // Create a True/False question by slightly modifying the sentence
    List<String> words = sentence.split(RegExp(r'\s+'));

    // 50% chance to make it False by changing a word
    bool isTrue = DateTime.now().millisecondsSinceEpoch % 2 == 0;

    String questionSentence = sentence;
    String correctAnswer = 'True';

    if (!isTrue) {
      // Change a key word to make it false
      for (int i = 0; i < words.length; i++) {
        String word = words[i];
        String cleanWord = word.replaceAll(RegExp(r'[^a-zA-Z]'), '');

        if (cleanWord.length > 4 && !_isCommonWord(cleanWord)) {
          // Replace with a different word
          words[i] = word.replaceAll(cleanWord, 'different');
          break;
        }
      }
      questionSentence = words.join(' ');
      correctAnswer = 'False';
    }

    return {
      'question': 'True or False: "$questionSentence"',
      'options': ['True', 'False'],
      'correct': correctAnswer,
      'type': 'True/False',
    };
  }

  Map<String, dynamic> _createComprehensionQuestion(
    String sentence,
    List<String> allSentences,
    List<String> keyTerms,
  ) {
    // Find what/who/when/where questions from the sentence
    String question = '';
    String correctAnswer = '';

    // Try to extract a fact and create a question
    if (sentence.contains(' is ') || sentence.contains(' are ')) {
      List<String> parts = sentence.split(RegExp(r' is | are '));
      if (parts.length == 2) {
        String subject = parts[0].trim();
        String predicate = parts[1].trim();

        // Remove trailing punctuation from predicate
        predicate = predicate.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '').trim();

        question = 'What is true about $subject?';
        correctAnswer = predicate;

        // Generate wrong answers from other sentences
        List<String> wrongAnswers = [];
        for (String otherSentence in allSentences) {
          if (otherSentence != sentence && otherSentence.contains(' is ')) {
            List<String> otherParts = otherSentence.split(' is ');
            if (otherParts.length == 2) {
              String otherPredicate = otherParts[1]
                  .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '')
                  .trim();
              if (otherPredicate != correctAnswer &&
                  otherPredicate.length > 3) {
                wrongAnswers.add(otherPredicate);
              }
            }
          }
          if (wrongAnswers.length >= 3) break;
        }

        // Fill with generic wrong answers if needed
        while (wrongAnswers.length < 3) {
          wrongAnswers.add('Not mentioned in text');
        }

        List<String> options = [correctAnswer, ...wrongAnswers.take(3)];
        options.shuffle();

        return {
          'question': question,
          'options': options,
          'correct': correctAnswer,
          'type': 'Comprehension',
        };
      }
    }

    // Fallback: Create a "according to the text" question
    if (keyTerms.isNotEmpty) {
      String term = keyTerms[0];
      question = 'According to the text, what is mentioned about $term?';
      correctAnswer = sentence;

      List<String> wrongAnswers = [];
      for (int i = 1; i < allSentences.length && wrongAnswers.length < 3; i++) {
        if (allSentences[i] != sentence && allSentences[i].trim().length > 20) {
          wrongAnswers.add(allSentences[i].trim());
        }
      }

      while (wrongAnswers.length < 3) {
        wrongAnswers.add('Not mentioned in the text');
      }

      List<String> options = [correctAnswer, ...wrongAnswers.take(3)];
      options.shuffle();

      return {
        'question': question,
        'options': options,
        'correct': correctAnswer,
        'type': 'Comprehension',
      };
    }

    // Ultimate fallback
    return _createFillInBlankQuestion(
      sentence,
      keyTerms,
      sentence.split(RegExp(r'\s+')),
    );
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: extractedText));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Text copied to clipboard!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    }
  }

  Future<void> _downloadAsTxt() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/scanned_text.txt');
      await file.writeAsString(extractedText);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to: ${file.path}'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scanAnother() {
    Navigator.pop(context);
  }

  void _selectAnswer(int questionIndex, String answer) {
    if (isQuizSubmitted && firstAttemptWrong[questionIndex] != true) return; 

    setState(() {
      userAnswers[questionIndex] = answer;
      // If they were in retry mode and picked a new answer, we can clear the wrong flag 
      // when they submit again, or just let them pick.
    });
  }

  void _submitQuiz() {
    // Check if all questions are answered
    if (userAnswers.length < practiceQuestions.length) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Incomplete Quiz'),
          content: Text(
            'You have answered ${userAnswers.length} out of ${practiceQuestions.length} questions. Please answer all questions before submitting.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Calculate score
    int correct = 0;
    for (int i = 0; i < practiceQuestions.length; i++) {
      if (userAnswers[i] == practiceQuestions[i]['correct']) {
        correct++;
      }
    }

    setState(() {
      isQuizSubmitted = true;
      correctAnswers = correct;
      totalQuestions = practiceQuestions.length;
    });

    // Check first attempt wrong - don't show explanation yet, let user retry
    for (int i = 0; i < practiceQuestions.length; i++) {
      if (userAnswers[i] != practiceQuestions[i]['correct']) {
        if (hasRetried[i] == true) {
          // User already tried once, now show AI explanation
          _fetchExplanation(i);
        } else {
          // First wrong attempt - mark it and allow retry
          firstAttemptWrong[i] = true;
        }
      }
    }

    // Show result dialog
    _showResultDialog();
  }

  void _submitRetry(int index) {
    if (userAnswers[index] == practiceQuestions[index]['correct']) {
      setState(() {
        firstAttemptWrong[index] = false;
        hasRetried[index] = true;
        _recalculateScore();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Correct this time! Well done!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() {
        firstAttemptWrong[index] = false; // Now show the real result
        hasRetried[index] = true;
        _recalculateScore();
        _fetchExplanation(index); // Now show explanation
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Still not quite right. Check the explanation below!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _recalculateScore() {
    int correct = 0;
    for (int i = 0; i < practiceQuestions.length; i++) {
      if (userAnswers[i] == practiceQuestions[i]['correct']) {
       correct++;
      }
    }
    setState(() {
      correctAnswers = correct;
    });
  }

  Future<void> _fetchExplanation(int index) async {
    if (questionExplanations.containsKey(index)) return;

    setState(() {
      loadingExplanations[index] = true;
    });

    try {
      final explanation = await AiExplanationService.getExplanation(
        question:practiceQuestions[index]['question'],
        userAnswer: userAnswers[index] ?? 'No answer',
        correctAnswer: practiceQuestions[index]['correct'],
        context: "The content of the lesson was: ${extractedText.substring(0, extractedText.length > 500 ? 500 : extractedText.length)}",
      );

      if (mounted) {
        setState(() {
          questionExplanations[index] = explanation;
          loadingExplanations[index] = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loadingExplanations[index] = false;
        });
      }
    }
  }

  void _showResultDialog() {
    double percentage = (correctAnswers / totalQuestions * 100);
    String message;
    IconData icon;
    Color color;

    if (percentage >= 80) {
      message = 'Excellent! Great job!';
      icon = Icons.emoji_events;
      color = const Color(0xFF4CAF50);
    } else if (percentage >= 60) {
      message = 'Good work! Keep practicing!';
      icon = Icons.thumb_up;
      color = const Color(0xFF2196F3);
    } else if (percentage >= 40) {
      message = 'Not bad! Room for improvement!';
      icon = Icons.trending_up;
      color = const Color(0xFFFF9800);
    } else {
      message = 'Keep studying! You\'ll do better!';
      icon = Icons.school;
      color = const Color(0xFFE91E63);
    }

    int pendingRetries = firstAttemptWrong.values.where((v) => v).length;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 64, color: color),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              if (pendingRetries > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Text(
                      'You have $pendingRetries questions to retry!',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'Your Score',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                '$correctAnswers / $totalQuestions',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _resetQuiz();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2196F3),
                        side: const BorderSide(color: Color(0xFF2196F3)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(pendingRetries > 0 ? Icons.refresh : Icons.visibility),
                      label: Text(pendingRetries > 0 ? 'Retry Now' : 'Review'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetQuiz() {
    setState(() {
      isQuizSubmitted = false;
      userAnswers = {};
      correctAnswers = 0;
      totalQuestions = 0;

      questionExplanations = {};
      loadingExplanations = {};
      // Regenerate questions by calling AI again

      // Regenerate questions for variety

      if (extractedText.isNotEmpty) {
        _generatePracticeQuestions(extractedText);
      }
    });
  }

  Future<void> _trySimilarQuestion(int index) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final newQuestion = await AiExplanationService.getSimilarQuestion(
        originalQuestion: practiceQuestions[index]['question'],
        questionType: practiceQuestions[index]['type'] ?? 'MCQ',
        context: "The content of the lesson was: ${extractedText.substring(0, extractedText.length > 500 ? 500 : extractedText.length)}",
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        if (newQuestion.isNotEmpty) {
          _showNewQuestionDialog(newQuestion);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate a new question.')),
        );
      }
    }
  }

  void _showNewQuestionDialog(Map<String, dynamic> question) {
    String? localUserAnswer;
    bool isAnswerCorrect = false;
    bool showResult = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.purple),
                    SizedBox(width: 8),
                    Text(
                      'AI Generated Practice',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  question['question'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ...((question['options'] as List<dynamic>).map((option) {
                  String opt = option.toString();
                  bool isSelected = localUserAnswer == opt;
                  bool isCorrect = opt == question['correct'];

                  Color borderColor = isSelected ? Colors.purple : Colors.grey.shade300;
                  if (showResult) {
                    if (isCorrect) borderColor = Colors.green;
                    else if (isSelected) borderColor = Colors.red;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: showResult ? null : () {
                        setDialogState(() {
                          localUserAnswer = opt;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor, width: 2),
                          color: isSelected ? borderColor.withOpacity(0.1) : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(opt)),
                            if (showResult && isCorrect) const Icon(Icons.check, color: Colors.green),
                            if (showResult && isSelected && !isCorrect) const Icon(Icons.close, color: Colors.red),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList()),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!showResult)
                      ElevatedButton(
                        onPressed: localUserAnswer == null ? null : () {
                          setDialogState(() {
                            showResult = true;
                            isAnswerCorrect = localUserAnswer == question['correct'];
                          });
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                        child: const Text('Check'),
                      )
                    else
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                        child: const Text('Close'),
                      ),
                  ],
                ),
                if (showResult)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      isAnswerCorrect ? '🎉 Correct! Well done!' : '💡 Keep practicing!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isAnswerCorrect ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Scan Results',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        actions: [
          if (!isProcessing && extractedText.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.white),
              onPressed: _copyToClipboard,
              tooltip: 'Copy Text',
            ),
        ],
      ),
      body: isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF4CAF50),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Processing Image...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            )
          : error != null
          ? _buildErrorView()
          : _buildResultView(),
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              error ?? 'An error occurred',
              style: const TextStyle(fontSize: 16, color: Color(0xFF333333)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _processImage,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Image Preview
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.file(
              widget.imageFile,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Extracted Text Section
        _buildSectionCard(
          title: 'Extracted Text',
          icon: Icons.text_fields,
          color: const Color(0xFF2196F3),
          child: Text(
            extractedText,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Color(0xFF333333),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Key Concepts Section
        if (keyConcepts.isNotEmpty)
          _buildSectionCard(
            title: 'Key Concepts',
            icon: Icons.lightbulb,
            color: const Color(0xFFFF9800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: keyConcepts.map((concept) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFFFF9800),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          concept,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 16),

        // Practice Questions Section
        if (practiceQuestions.isNotEmpty)
          _buildSectionCard(
            title: 'Practice Questions',
            icon: Icons.quiz,
            color: const Color(0xFF9C27B0),
            child: Column(
              children: [
                // Quiz Progress
                if (!isQuizSubmitted)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.track_changes,
                          color: Color(0xFF9C27B0),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Answered: ${userAnswers.length} / ${practiceQuestions.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9C27B0),
                          ),
                        ),
                        const Spacer(),
                        if (userAnswers.length == practiceQuestions.length)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Ready to Submit!',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                // Questions
                ...practiceQuestions.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> question = entry.value;
                  return _buildQuestionCard(index + 1, question, index);
                }),

                // Submit Button
                if (!isQuizSubmitted)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 16),
                    child: ElevatedButton.icon(
                      onPressed: _submitQuiz,
                      icon: const Icon(Icons.check_circle, size: 24),
                      label: const Text(
                        'Submit Quiz',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9C27B0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 24),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _scanAnother,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan Another'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _downloadAsTxt,
                icon: const Icon(Icons.download),
                label: const Text('Save Results'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    int number,
    Map<String, dynamic> question,
    int questionIndex,
  ) {
    String questionType = question['type'] ?? 'MCQ';
    Color typeColor = _getQuestionTypeColor(questionType);
    IconData typeIcon = _getQuestionTypeIcon(questionType);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: typeColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$number',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question['question'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(typeIcon, size: 14, color: typeColor),
                const SizedBox(width: 4),
                Text(
                  questionType,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: typeColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...((question['options'] as List<String>).asMap().entries.map((
            entry,
          ) {
            int index = entry.key;
            String option = entry.value;
            bool isCorrect = option == question['correct'];
            bool isSelected = userAnswers[questionIndex] == option;
            bool showResult = isQuizSubmitted && firstAttemptWrong[questionIndex] != true;

            // Determine colors based on state
            Color borderColor;
            Color backgroundColor;

            if (showResult) {
              if (isCorrect) {
                borderColor = const Color(0xFF4CAF50);
                backgroundColor = const Color(
                  0xFF4CAF50,
                ).withValues(alpha: 0.1);
              } else if (isSelected && !isCorrect) {
                borderColor = const Color(0xFFE91E63);
                backgroundColor = const Color(
                  0xFFE91E63,
                ).withValues(alpha: 0.1);
              } else {
                borderColor = Colors.grey.shade300;
                backgroundColor = Colors.white;
              }
            } else if (isSelected) {
              borderColor = const Color(0xFF2196F3);
              backgroundColor = const Color(0xFF2196F3).withValues(alpha: 0.1);
            } else {
              borderColor = Colors.grey.shade300;
              backgroundColor = Colors.white;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => _selectAnswer(questionIndex, option),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: borderColor,
                      width: isSelected || (showResult && isCorrect) ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: showResult
                              ? (isCorrect
                                    ? const Color(0xFF4CAF50)
                                    : (isSelected
                                          ? const Color(0xFFE91E63)
                                          : Colors.transparent))
                              : (isSelected
                                    ? const Color(0xFF2196F3)
                                    : Colors.transparent),
                          border: Border.all(
                            color: showResult
                                ? (isCorrect
                                      ? const Color(0xFF4CAF50)
                                      : (isSelected
                                            ? const Color(0xFFE91E63)
                                            : Colors.grey.shade400))
                                : (isSelected
                                      ? const Color(0xFF2196F3)
                                      : Colors.grey.shade400),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: showResult
                              ? Icon(
                                  isCorrect
                                      ? Icons.check
                                      : (isSelected ? Icons.close : null),
                                  size: 16,
                                  color: Colors.white,
                                )
                              : (isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : Text(
                                        String.fromCharCode(65 + index),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? const Color(0xFF2196F3)
                                              : Colors.grey.shade600,
                                        ),
                                      )),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 14,
                            color: showResult
                                ? (isCorrect
                                      ? const Color(0xFF4CAF50)
                                      : (isSelected
                                            ? const Color(0xFFE91E63)
                                            : const Color(0xFF333333)))
                                : (isSelected
                                      ? const Color(0xFF2196F3)
                                      : const Color(0xFF333333)),
                            fontWeight:
                                (isSelected || (showResult && isCorrect))
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          })),

          // Retry Button for first wrong attempt
          if (isQuizSubmitted && firstAttemptWrong[questionIndex] == true)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _submitRetry(questionIndex),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),

          // Show AI explanation after submission (only if not in retry mode)
          if (isQuizSubmitted && firstAttemptWrong[questionIndex] != true)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.psychology,
                    color: Color(0xFF2196F3),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Tutor Explanation:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (loadingExplanations[questionIndex] == true)
                          const Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        else
                          Text(
                            questionExplanations[questionIndex] ?? _generateExplanation(question),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF333333),
                              height: 1.4,
                            ),
                          ),
                        if (userAnswers[questionIndex] != question['correct'])
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: TextButton.icon(
                              onPressed: () => _trySimilarQuestion(questionIndex),
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text(
                                'Try Similar Question',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.purple,
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getQuestionTypeColor(String type) {
    switch (type) {
      case 'Fill in the Blank':
        return const Color(0xFF2196F3); // Blue
      case 'True/False':
        return const Color(0xFFFF9800); // Orange
      case 'Comprehension':
        return const Color(0xFF9C27B0); // Purple
      default:
        return const Color(0xFF607D8B); // Grey
    }
  }

  IconData _getQuestionTypeIcon(String type) {
    switch (type) {
      case 'Fill in the Blank':
        return Icons.edit;
      case 'True/False':
        return Icons.toggle_on;
      case 'Comprehension':
        return Icons.question_answer;
      default:
        return Icons.help;
    }
  }

  String _generateExplanation(Map<String, dynamic> question) {
    String type = question['type'] ?? 'MCQ';
    String correct = question['correct'];
    String userAnswer =
        userAnswers[practiceQuestions.indexOf(question)] ?? 'Not answered';
    bool isCorrect = userAnswer == correct;

    String result = isCorrect
        ? '✓ Correct! '
        : '✗ Incorrect. The correct answer is: "$correct". ';

    switch (type) {
      case 'Fill in the Blank':
        result += isCorrect
            ? 'You correctly identified the missing term.'
            : 'This term is mentioned in the scanned text and is important for understanding the context.';
        break;
      case 'True/False':
        result += isCorrect
            ? 'You correctly identified whether the statement is true or false.'
            : 'Review the scanned text to understand why this statement is $correct.toLowerCase().';
        break;
      case 'Comprehension':
        result += isCorrect
            ? 'Great comprehension! You understood the key concept from the text.'
            : 'This information is directly stated in the scanned text. Try reading more carefully.';
        break;
      default:
        result +=
            'This answer is based on the content from your scanned study material.';
    }

    return result;
  }
}