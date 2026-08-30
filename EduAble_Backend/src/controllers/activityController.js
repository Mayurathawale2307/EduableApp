const Activity = require('../models/Activity');
const LearningProfile = require('../models/LearningProfile');

// Record a new activity
exports.recordActivity = async (req, res, next) => {
  try {
    const { activityType, details, performance, metadata } = req.body;

    if (!activityType) {
      return res.status(400).json({ message: 'Activity type is required' });
    }

    const activity = await Activity.create({
      userId: req.user._id,
      activityType,
      details: details || {},
      performance: performance || {},
      metadata: metadata || {},
    });

    // Update learning profile asynchronously
    updateLearningProfile(req.user._id).catch(err => {
      console.error('Error updating learning profile:', err);
    });

    res.status(201).json({
      success: true,
      activity,
      message: 'Activity recorded successfully',
    });
  } catch (error) {
    next(error);
  }
};

// Get user activities with filters
exports.getUserActivities = async (req, res, next) => {
  try {
    const { activityType, limit = 50, days = 30 } = req.query;
    
    const query = { userId: req.user._id };
    if (activityType) {
      query.activityType = activityType;
    }

    // Filter by date
    const dateLimit = new Date();
    dateLimit.setDate(dateLimit.getDate() - parseInt(days));
    query.createdAt = { $gte: dateLimit };

    const activities = await Activity.find(query)
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .lean();

    res.json({
      success: true,
      activities,
      count: activities.length,
    });
  } catch (error) {
    next(error);
  }
};

// Get learning profile
exports.getLearningProfile = async (req, res, next) => {
  try {
    let profile = await LearningProfile.findOne({ userId: req.user._id });

    if (!profile) {
      // Create default profile if doesn't exist
      profile = await LearningProfile.create({
        userId: req.user._id,
      });
    }

    res.json({
      success: true,
      profile,
    });
  } catch (error) {
    next(error);
  }
};

// Get personalized recommendations
exports.getRecommendations = async (req, res, next) => {
  try {
    const profile = await LearningProfile.findOne({ userId: req.user._id });

    if (!profile) {
      return res.json({
        success: true,
        recommendations: [],
        message: 'Complete some activities to get personalized recommendations',
      });
    }

    res.json({
      success: true,
      recommendations: profile.recommendations,
      weakAreas: profile.weaknesses,
      strongAreas: profile.strengths,
      preferredDifficulty: profile.preferredDifficulty,
    });
  } catch (error) {
    next(error);
  }
};

// Get progress analytics
exports.getProgressAnalytics = async (req, res, next) => {
  try {
    const { days = 30 } = req.query;
    
    const dateLimit = new Date();
    dateLimit.setDate(dateLimit.getDate() - parseInt(days));

    // Get activities in date range
    const activities = await Activity.find({
      userId: req.user._id,
      createdAt: { $gte: dateLimit },
    }).sort({ createdAt: 1 }).lean();

    // Calculate analytics
    const analytics = {
      totalActivities: activities.length,
      byType: {},
      averageScore: 0,
      trend: [],
      studyTime: 0,
      improvement: 0,
    };

    // Group by type
    activities.forEach(activity => {
      const type = activity.activityType;
      if (!analytics.byType[type]) {
        analytics.byType[type] = { count: 0, totalScore: 0, totalTime: 0 };
      }
      analytics.byType[type].count++;
      analytics.byType[type].totalScore += activity.performance?.score || 0;
      analytics.byType[type].totalTime += activity.performance?.timeSpent || 0;
    });

    // Calculate average score
    const activitiesWithScores = activities.filter(a => a.performance?.total > 0);
    if (activitiesWithScores.length > 0) {
      const totalAccuracy = activitiesWithScores.reduce((sum, a) => {
        return sum + (a.performance.score / a.performance.total * 100);
      }, 0);
      analytics.averageScore = totalAccuracy / activitiesWithScores.length;
    }

    // Calculate total study time
    analytics.studyTime = activities.reduce((sum, a) => {
      return sum + (a.performance?.timeSpent || 0);
    }, 0);

    // Create trend data (group by day)
    const dailyMap = {};
    activities.forEach(activity => {
      const date = new Date(activity.createdAt).toISOString().split('T')[0];
      if (!dailyMap[date]) {
        dailyMap[date] = { date, activities: 0, score: 0, count: 0 };
      }
      dailyMap[date].activities++;
      if (activity.performance?.total > 0) {
        dailyMap[date].score += (activity.performance.score / activity.performance.total * 100);
        dailyMap[date].count++;
      }
    });

    analytics.trend = Object.values(dailyMap).map(d => ({
      ...d,
      averageScore: d.count > 0 ? d.score / d.count : 0,
    }));

    res.json({
      success: true,
      analytics,
    });
  } catch (error) {
    next(error);
  }
};

// Helper function to update learning profile
async function updateLearningProfile(userId) {
  try {
    // Get all activities for this user
    const activities = await Activity.find({ userId }).sort({ createdAt: -1 }).lean();
    
    if (activities.length === 0) return;

    // Calculate statistics
    const stats = {
      strengths: [],
      weaknesses: [],
      totalScore: 0,
      totalCount: 0,
      totalTime: 0,
      byType: {},
    };

    // Analyze activities
    const topicPerformance = {};
    
    activities.forEach(activity => {
      const type = activity.activityType;
      if (!stats.byType[type]) {
        stats.byType[type] = { count: 0, score: 0 };
      }
      stats.byType[type].count++;
      
      if (activity.performance?.total > 0) {
        const accuracy = (activity.performance.score / activity.performance.total) * 100;
        stats.totalScore += accuracy;
        stats.totalCount++;
        stats.totalTime += activity.performance.timeSpent || 0;

        // Track topic performance
        const topic = activity.details?.topic || activity.details?.gameType || type;
        if (!topicPerformance[topic]) {
          topicPerformance[topic] = { total: 0, count: 0 };
        }
        topicPerformance[topic].total += accuracy;
        topicPerformance[topic].count++;
      }
    });

    // Determine strengths and weaknesses
    Object.entries(topicPerformance).forEach(([topic, data]) => {
      const avgAccuracy = data.total / data.count;
      if (avgAccuracy >= 70 && data.count >= 2) {
        stats.strengths.push(topic);
      } else if (avgAccuracy < 50 && data.count >= 2) {
        stats.weaknesses.push(topic);
      }
    });

    // Calculate average difficulty
    const recentActivities = activities.slice(0, 10);
    const avgDifficulty = recentActivities.reduce((sum, a) => {
      return sum + (a.performance?.difficultyLevel || 5);
    }, 0) / recentActivities.length;

    // Determine learning style (simplified - can be enhanced with AI)
    const learningStyle = determineLearningStyle(activities);

    // Generate recommendations
    const recommendations = generateRecommendations(stats, topicPerformance);

    // Update or create profile
    const profileData = {
      strengths: stats.strengths.slice(0, 10),
      weaknesses: stats.weaknesses.slice(0, 10),
      learningStyle,
      preferredDifficulty: Math.round(avgDifficulty),
      recommendations,
      lastUpdated: new Date(),
      totalStudyHours: stats.totalTime / 3600,
      engagementScore: calculateEngagementScore(activities),
      activityStats: {
        totalQuizzes: stats.byType.quiz?.count || 0,
        totalGames: stats.byType.game?.count || 0,
        totalScans: stats.byType.scan?.count || 0,
        totalAIChats: stats.byType.ai_chat?.count || 0,
        totalStudySessions: stats.byType.study_session?.count || 0,
        averageScore: stats.totalCount > 0 ? stats.totalScore / stats.totalCount : 0,
        bestStreak: calculateBestStreak(activities),
      },
      performanceTrend: {
        overall: calculateOverallTrend(activities),
      },
    };

    await LearningProfile.findOneAndUpdate(
      { userId },
      profileData,
      { upsert: true, new: true }
    );
  } catch (error) {
    console.error('Error updating learning profile:', error);
  }
}

// Helper: Determine learning style from activity patterns
function determineLearningStyle(activities) {
  // Simplified logic - can be enhanced with ML/AI
  const scanCount = activities.filter(a => a.activityType === 'scan').length;
  const chatCount = activities.filter(a => a.activityType === 'ai_chat').length;
  const gameCount = activities.filter(a => a.activityType === 'game').length;
  
  if (scanCount > gameCount && scanCount > chatCount) return 'visual';
  if (chatCount > scanCount && chatCount > gameCount) return 'reading';
  if (gameCount > scanCount && gameCount > chatCount) return 'kinesthetic';
  return 'mixed';
}

// Helper: Generate personalized recommendations
function generateRecommendations(stats, topicPerformance) {
  const recommendations = [];
  
  // Recommend practicing weak areas
  if (stats.weaknesses.length > 0) {
    recommendations.push(`Focus on improving: ${stats.weaknesses.slice(0, 3).join(', ')}`);
  }
  
  // Recommend advancing in strong areas
  if (stats.strengths.length > 0) {
    recommendations.push(`Challenge yourself in: ${stats.strengths.slice(0, 2).join(', ')}`);
  }
  
  // Study time recommendation
  const totalHours = stats.totalTime / 3600;
  if (totalHours < 5) {
    recommendations.push('Try to spend at least 30 minutes daily on learning activities');
  }
  
  // Variety recommendation
  const activityTypes = Object.keys(stats.byType);
  if (activityTypes.length < 3) {
    recommendations.push('Explore different types of activities for well-rounded learning');
  }
  
  return recommendations.length > 0 ? recommendations : ['Keep up the good work!'];
}

// Helper: Calculate engagement score
function calculateEngagementScore(activities) {
  if (activities.length === 0) return 0;
  
  const recentActivities = activities.slice(0, 30);
  const daysSinceFirst = Math.max(1, 
    (new Date() - new Date(recentActivities[recentActivities.length - 1].createdAt)) / (1000 * 60 * 60 * 24)
  );
  
  // Frequency score (0-40)
  const frequency = Math.min(40, (recentActivities.length / daysSinceFirst) * 10);
  
  // Diversity score (0-30)
  const uniqueTypes = new Set(recentActivities.map(a => a.activityType)).size;
  const diversity = (uniqueTypes / 5) * 30;
  
  // Performance improvement score (0-30)
  const recent10 = recentActivities.slice(0, 10).filter(a => a.performance?.total > 0);
  const older10 = recentActivities.slice(10, 20).filter(a => a.performance?.total > 0);
  
  let improvement = 15; // Default middle score
  if (recent10.length > 0 && older10.length > 0) {
    const recentAvg = recent10.reduce((sum, a) => sum + (a.performance.score / a.performance.total), 0) / recent10.length;
    const olderAvg = older10.reduce((sum, a) => sum + (a.performance.score / a.performance.total), 0) / older10.length;
    improvement = Math.min(30, Math.max(0, ((recentAvg - olderAvg) + 0.5) * 30));
  }
  
  return Math.round(frequency + diversity + improvement);
}

// Helper: Calculate best streak
function calculateBestStreak(activities) {
  if (activities.length === 0) return 0;
  
  const activeDays = new Set();
  activities.forEach(a => {
    const date = new Date(a.createdAt).toISOString().split('T')[0];
    activeDays.add(date);
  });
  
  const sortedDays = Array.from(activeDays).sort();
  let maxStreak = 1;
  let currentStreak = 1;
  
  for (let i = 1; i < sortedDays.length; i++) {
    const prevDate = new Date(sortedDays[i - 1]);
    const currDate = new Date(sortedDays[i]);
    const diffDays = (currDate - prevDate) / (1000 * 60 * 60 * 24);
    
    if (diffDays === 1) {
      currentStreak++;
      maxStreak = Math.max(maxStreak, currentStreak);
    } else if (diffDays > 1) {
      currentStreak = 1;
    }
  }
  
  return maxStreak;
}

// Helper: Calculate overall trend
function calculateOverallTrend(activities) {
  if (activities.length < 5) return 'stable';
  
  const recent5 = activities.slice(0, 5).filter(a => a.performance?.total > 0);
  const older5 = activities.slice(5, 10).filter(a => a.performance?.total > 0);
  
  if (recent5.length === 0 || older5.length === 0) return 'stable';
  
  const recentAvg = recent5.reduce((sum, a) => sum + (a.performance.score / a.performance.total), 0) / recent5.length;
  const olderAvg = older5.reduce((sum, a) => sum + (a.performance.score / a.performance.total), 0) / older5.length;
  
  const diff = recentAvg - olderAvg;
  if (diff > 0.1) return 'improving';
  if (diff < -0.1) return 'declining';
  return 'stable';
}
