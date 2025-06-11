const dbConnection = require("../db/dbConfig");
const { StatusCodes } = require("http-status-codes");

// Get answers for a specific question
const getAnswer = async (req, res) => {
  const { questionid } = req.params; // Get questionid from URL parameters
  try {
    const [answers] = await dbConnection.query(
      `SELECT a.answerid, a.userid, a.questionid, a.answer_text as answer, 
              u.username, u.profession, u.firstname, u.lastname 
       FROM answers a 
       JOIN users u ON a.userid = u.userid 
       WHERE a.questionid = ? ORDER BY a.created_at DESC`,
      [questionid]
    );

    console.log(`Found ${answers.length} answers for question ${questionid}`);

    return res.status(StatusCodes.OK).json({
      message: `Answers for question ${questionid} retrieved successfully`,
      answers: answers,
    });
  } catch (error) {
    console.error("Error getting answers for question:", error);
    return res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({
      message: "An unexpected error occurred",
      error: error.message,
    });
  }
};

// Post a new answer
const postAnswer = async (req, res) => {
  const { questionid, answer } = req.body;
  const userid = req.user.userid; // Get userid from auth middleware
  console.log("Received post answer request:", { questionid, answer, userid });

  if (!answer) {
    return res
      .status(StatusCodes.BAD_REQUEST)
      .json({ message: "Please provide answer" });
  }

  try {
    const [result] = await dbConnection.query(
      "INSERT INTO answers (userid, questionid, answer_text) VALUES (?, ?, ?)",
      [userid, questionid, answer]
    );

    console.log("Answer posted successfully:", result);

    return res
      .status(StatusCodes.CREATED)
      .json({ message: "Answer posted successfully" });
  } catch (error) {
    console.error("Error posting answer:", error);
    return res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({
      message: "An unexpected error occurred",
      error: error.message,
    });
  }
};

// Get all answers
const getAllAnswers = async (req, res) => {
  try {
    console.log("Fetching all answers...");
    const [answers] = await dbConnection.query(
      `SELECT a.answerid, a.userid, a.questionid, a.answer_text as answer, 
              u.username, u.profession, u.firstname, u.lastname 
       FROM answers a 
       JOIN users u ON a.userid = u.userid`
    );
    
    console.log(`Found ${answers.length} total answers`);
    
    return res.status(StatusCodes.OK).json({
      message: "All answers retrieved successfully",
      answers: answers,
      totalAnswers: answers.length
    });
  } catch (error) {
    console.error("Error getting all answers:", error);
    return res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({
      message: "An unexpected error occurred",
      error: error.message
    });
  }
};

// Get answer statistics
const getAnswerStats = async (req, res) => {
  try {
    const [[{ totalAnswers }]] = await dbConnection.query(
      "SELECT COUNT(*) AS totalAnswers FROM answers"
    );

    return res.status(StatusCodes.OK).json({
      message: "Total answers count retrieved successfully",
      totalAnswers,
    });
  } catch (error) {
    console.error("Error counting answers:", error.message);
    return res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({
      message: "An unexpected error occurred while counting answers",
      error: error.message,
    });
  }
};

// Edit an existing answer
const editAnswer = async (req, res) => {
  const { answerid } = req.params;
  const { content } = req.body;
  const { userid, role_id } = req.user; // coming from auth middleware

  if (!content) {
    return res.status(StatusCodes.BAD_REQUEST).json({
      message: "Please provide content to update",
    });
  }

  try {
    // Fetch the answer to make sure it exists
    const [existing] = await dbConnection.query(
      "SELECT * FROM answers WHERE answerid = ?",
      [answerid]
    );

    if (!existing || existing.length === 0) {
      return res.status(StatusCodes.NOT_FOUND).json({
        message: "Answer not found",
      });
    }

    // Check ownership or admin access
    if (existing[0].userid !== userid && role_id !== 1) {
      return res.status(StatusCodes.FORBIDDEN).json({
        message: "You can only edit your own answers",
      });
    }

    // Check if the content is actually different to avoid unnecessary updates
    if (existing[0].answer_text === content) {
      return res.status(StatusCodes.OK).json({
        message: "Nothing to update (content is identical)",
      });
    }

    // Perform update
    await dbConnection.query(
      "UPDATE answers SET answer_text = ? WHERE answerid = ?",
      [content, answerid]
    );

    return res.status(StatusCodes.OK).json({
      message: "Answer updated successfully",
    });
  } catch (error) {
    console.error("Error updating answer:", error.message);
    return res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({
      message: "An unexpected error occurred",
      error: error.message,
    });
  }
};

module.exports = {
  getAnswer,
  postAnswer,
  getAnswerStats,
  editAnswer,
  getAllAnswers
};
