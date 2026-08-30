const mongoose = require('mongoose');

const learningProfileSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
      index: true,
    },
    strengths: {
      type: [String],
      default: [],
    },
    weaknesses: {
      type: [String],
      default: [],
    },
    learningStyle: {
      type: String,
      enum: ['visual', 'auditory', 'kinesthetic', 'reading', 'mixed'],
      default: 'mixed',
    },
    preferredDifficulty: {
      type: Number,
      default: 5,
      min: 1,
      max: 10,
    },
    performanceTrend: {
      type: mongoose.Schema.Types.Mixed,
      default: {
        last7Days: [],
        last30Days: [],
        overall: 'stable',
      },
    },
    recommendations: {
      type: [String],
      default: [],
    },
    insights: {
      type: mongoose.Schema.Types.Mixed,
      default: {},
    },
    lastUpdated: {
      type: Date,
      default: Date.now,
    },
    totalStudyHours: {
      type: Number,
      default: 0,
    },
    engagementScore: {
      type: Number,
      default: 0,
      min: 0,
      max: 100,
    },
    activityStats: {
      totalQuizzes: { type: Number, default: 0 },
      totalGames: { type: Number, default: 0 },
      totalScans: { type: Number, default: 0 },
      totalAIChats: { type: Number, default: 0 },
      totalStudySessions: { type: Number, default: 0 },
      averageScore: { type: Number, default: 0 },
      bestStreak: { type: Number, default: 0 },
    },
  },
  {
    timestamps: true,
  }
);

learningProfileSchema.index({ userId: 1 });

const LearningProfile = mongoose.model('LearningProfile', learningProfileSchema);
module.exports = LearningProfile;
