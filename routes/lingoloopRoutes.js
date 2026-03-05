const express = require("express");
const controller = require("../controllers/lingoloopController");
const authController = require("../controllers/lingoloopAuthController");
const { enforceLingoloopAccess, attachLingoloopUser, requireLingoloopUser } = require("../middleware/lingoloopAuth");
const { lingoloopGeneralRateLimit, lingoloopChatDailyLimit } = require("../middleware/lingoloopRateLimit");

const router = express.Router();

router.use(enforceLingoloopAccess);
router.use(lingoloopGeneralRateLimit);
router.use(attachLingoloopUser);

router.post("/auth/guest", authController.createGuestSession);

router.use(requireLingoloopUser);

router.get("/words", controller.listWords);
router.post("/words", controller.createWord);
router.patch("/words/:id", controller.updateReview);
router.post("/speech/score", controller.speechScore);
router.post("/chat", lingoloopChatDailyLimit, controller.chat);
router.get("/progress", controller.progress);
router.get("/quiz/question", controller.getQuizQuestion);
router.post("/quiz/submit", controller.submitQuizAnswer);

module.exports = router;
