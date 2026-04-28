const Question = require('../models/Question');
const QuizResult = require('../models/QuizResult');
const User = require('../models/User');

// @desc    Get questions by category dynamically sized
// @route   GET /api/quiz/:category?limit=10
// @access  Private
const getQuestions = async (req, res) => {
  try {
    const category = req.params.category;
    // Default to 10 if not provided
    const limit = parseInt(req.query.limit) || 10; 

    // Aggregate to fetch random questions for that category
    const questions = await Question.aggregate([
      { $match: { category: category } },
      { $sample: { size: limit } }
    ]);

    if (questions.length === 0) {
      return res.status(404).json({ message: `No questions found for category: ${category}` });
    }

    res.json(questions);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Submit a quiz result
// @route   POST /api/quiz/submit
// @access  Private
const submitQuiz = async (req, res) => {
  try {
    const { category, score, correctAnswers, wrongAnswers, totalQuestions, timeTaken } = req.body;

    // Save result
    const quizResult = await QuizResult.create({
      userId: req.user.id,
      category,
      score,
      correctAnswers,
      wrongAnswers,
      totalQuestions,
      timeTaken,
    });

    // Update global user stats
    const user = await User.findById(req.user.id);
    if (user) {
      user.totalScore += score;
      user.quizzesPlayed += 1;
      
      const prevTotalQuestions = (user.quizzesPlayed - 1) * totalQuestions; // approximate past weight
      // A more robust way: re-calculate accuracy across all historic quizzes 
      const allResults = await QuizResult.find({ userId: req.user.id });
      let totalCorrect = 0;
      let totalOverall = 0;
      allResults.forEach(result => {
        totalCorrect += result.correctAnswers;
        totalOverall += result.totalQuestions;
      });
      user.accuracy = totalOverall > 0 ? (totalCorrect / totalOverall) * 100 : 0;
      
      await user.save();
    }

    res.status(201).json(quizResult);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getQuestions,
  submitQuiz,
};
