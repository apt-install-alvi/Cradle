const express = require('express');
const router = express.Router();
const VitalsController = require('./vitals.controller');
const { protect } = require('../../common/middlewares/authMiddleware');

router.use(protect);

router.get('/', VitalsController.getVitals);
router.post('/', VitalsController.logVital);
router.patch('/:id', VitalsController.updateVital);
router.delete('/:id', VitalsController.deleteVital);

router.get('/settings', VitalsController.getSettings);
router.post('/settings', VitalsController.updateSettings);

module.exports = router;
