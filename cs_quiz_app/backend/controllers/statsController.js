const QuizResult = require('../models/QuizResult');
const User = require('../models/User');

// @desc    Get user advanced stats
// @route   GET /api/stats/:userId
// @access  Private
const getUserStats = async (req, res) => {
  try {
    // Only allow users to fetch their own stats (or add admin logic)
    if (req.params.userId !== req.user.id) {
      return res.status(403).json({ message: 'Forbidden' });
    }

    const userId = req.user.id;
    const user = await User.findById(userId).select('-password');
    if (!user) {
       return res.status(404).json({ message: 'User not found' });
    }

    const allResults = await QuizResult.find({ userId }).sort({ date: 1 }); // Oldest to newest
    
    // Calculate best score, etc.
    let bestScore = 0;
    const categoryPerformance = {}; // { "OOP": { totalScore: x, count: y } }

    allResults.forEach(result => {
       if (result.score > bestScore) {
         bestScore = result.score;
       }
       if (!categoryPerformance[result.category]) {
         categoryPerformance[result.category] = { totalScore: 0, count: 0 };
       }
       categoryPerformance[result.category].totalScore += result.score;
       categoryPerformance[result.category].count += 1;
    });

    // Format category performance
    const formattedCategoryPerf = [];
    for (const [cat, data] of Object.entries(categoryPerformance)) {
      formattedCategoryPerf.push({
        category: cat,
        averageScore: (data.totalScore / data.count),
      });
    }

    // Determine weak vs strong
    formattedCategoryPerf.sort((a, b) => b.averageScore - a.averageScore);
    const strongTopics = formattedCategoryPerf.slice(0, 2);
    const weakTopics = formattedCategoryPerf.slice(-2).reverse();

    res.json({
      userStats: {
        totalQuizzesPlayed: user.quizzesPlayed,
        averageScore: user.quizzesPlayed > 0 ? (user.totalScore / user.quizzesPlayed) : 0,
        bestScore,
        accuracy: user.accuracy,
      },
      categoryPerformance: formattedCategoryPerf,
      strongTopics,
      weakTopics,
      recentResults: allResults.slice(-10).reverse() // Last 10
    });

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getUserStats,
};
