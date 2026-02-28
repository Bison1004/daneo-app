const express = require("express");
const controller = require("../controllers/studentAccessController");

const router = express.Router();

router.post("/student/verify-key", controller.verifyStudentKey);

module.exports = router;
