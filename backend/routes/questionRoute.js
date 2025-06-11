const express = require("express")
const router = express.Router()
const authenticate = require("../middleware/authMiddleware");

const {
  createQuestion,
  getAllQuestion,
  singleQuestion,
  getSeachedQuestion,
  countQuestions,
  deleteQuestion,
  updateQuestion
} = require("../controller/questionController");




// Create a new question
router.post("/", createQuestion)
router.get("/", getAllQuestion)
router.get("/countQuestions", countQuestions);
router.get("/:question_id", singleQuestion)
router.get("/search/:search", getSeachedQuestion)
router.delete("/:questionid", deleteQuestion)
router.patch("/:questionid", authenticate, updateQuestion);


module.exports = router
