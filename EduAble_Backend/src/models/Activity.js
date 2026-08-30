const mongoose = require('mongoose');

const activitySchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    activityType: {
      type: String,
      enum: ['quiz', 'game', 'scan', 'ai_chat', 'study_session'],
      required: true,
    },
    details: {
      type: mongoose.Schema.Types.Mixed,
      default: {},
    },
    performance: {
      score: { type: Number, default: 0 },
      total: { type: Number, default: 0 },
      accuracy: { type: Number, default: 0 },
      timeSpent: { type: Number, default: 0 }, // in seconds
      difficultyLevel: { type: Number, default: 1, min: 1, max: 10 },
      errors: { type: Number, default: 0 },
    },
    metadata: {
      device: { type: String, default: 'unknown' },
      platform: { type: String, default: 'unknown' },
      timestamp: { type: Date, default: Date.now },
    },
  },
  {
    timestamps: true,
  }
);

// Index for faster queries
activitySchema.index({ userId: 1, createdAt: -1 });
activitySchema.index({ userId: 1, activityType: 1 });

const Activity = mongoose.model('Activity', activitySchema);
module.exports = Activity;
