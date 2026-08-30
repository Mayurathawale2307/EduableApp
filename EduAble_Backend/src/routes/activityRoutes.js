const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const {
  recordActivity,
  getUserActivities,
  getLearningProfile,
  getRecommendations,
  getProgressAnalytics,
} = require('../controllers/activityController');

const router = express.Router();

// All routes require authentication
router.use(protect);

router.post('/', recordActivity);
router.get('/history', getUserActivities);
router.get('/profile', getLearningProfile);
router.get('/recommendations', getRecommendations);
router.get('/analytics', getProgressAnalytics);

module.exports = router;
