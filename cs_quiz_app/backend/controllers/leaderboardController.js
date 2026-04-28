const User = require('../models/User');

// @desc    Get top 50 users for leaderboard
// @route   GET /api/leaderboard
// @access  Public
const getLeaderboard = async (req, res) => {
  try {
    // Top 50 users sorted by total score, then accuracy, then quizzes played
    const topUsers = await User.find()
      .select('-password -__v -createdAt -updatedAt') // hide sensitive/extra data
      .sort({ totalScore: -1, accuracy: -1, quizzesPlayed: -1 })
      .limit(50);

    res.json(topUsers);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getLeaderboard,
};
