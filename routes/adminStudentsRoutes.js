const express = require("express");
const controller = require("../controllers/adminStudentsController");

const router = express.Router();

router.post("/students", controller.createStudent);
router.get("/students", controller.listStudents);
router.get("/students/:id", controller.getStudent);
router.put("/students/:id", controller.updateStudent);
router.patch("/students/:id/status", controller.updateStudentStatus);

module.exports = router;
