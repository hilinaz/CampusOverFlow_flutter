const express = require("express")
// const { post } = require("./questionRoute");
const router = express.Router()
const authenticate = require("../middleware/authMiddleware");
const {
  postAnswer,
  getAnswer,
  getAnswerStats,
  editAnswer,
  getAllAnswers
  //   getAnswerCount,
} = require("../controller/answerController");

// Specific routes first
router.get("/all", getAllAnswers);  // Get all answers
router.get("/stats", authenticate,getAnswerStats);  // Get answer statistics

// Post a new answer
router.post("/", authenticate, postAnswer);

// Edit an existing answer
router.put("/:answerid", authenticate, editAnswer);

// Get answers for a specific question (must be last)
router.get("/:questionid", getAnswer);

module.exports = router
