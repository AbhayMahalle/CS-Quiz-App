const express = require('express');
const router = express.Router();
const { getLeaderboard } = require('../controllers/leaderboardController');

// Leaderboard is public
router.get('/', getLeaderboard);

module.exports = router;
