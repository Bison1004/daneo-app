const express = require("express");
const controller = require("../controllers/lingoloopController");

const router = express.Router();

router.get("/words", controller.listWords);
router.post("/words", controller.createWord);
router.patch("/words/:id", controller.updateReview);
router.post("/speech/score", controller.speechScore);
router.post("/chat", controller.chat);
router.get("/progress", controller.progress);

module.exports = router;
