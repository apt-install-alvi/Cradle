const express = require('express');
const router = express.Router();
const EducationController = require('./education.controller');
const { protect } = require('../../common/middlewares/authMiddleware');

router.get('/', protect, EducationController.getArticles);
router.get('/:id', protect, EducationController.getArticleById);

module.exports = router;
