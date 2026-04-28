const express = require('express');
const router = express.Router();
const { getUserStats } = require('../controllers/statsController');
const { protect } = require('../middleware/authMiddleware');

router.get('/:userId', protect, getUserStats);

module.exports = router;
