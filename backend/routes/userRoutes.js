const express = require("express");
const router = express.Router();

// usercontroller
// Corrected the casing of 'authMiddleware' in the require path to lowercase 'a'
// This assumes your middleware file is named 'authMiddleware.js' (lowercase 'a')
const authMiddleWare = require("../middleware/authMiddleware");
const {
  register,
  login,
  checkUser,
  getFullName,
  getUserStats,
  getAllUserNamesAndProfessions,
  deleteUser,
} = require("../controller/userController");

router.post("/register", register);
router.post("/login", login);
router.get("/getAllUserNamesAndProfessions", getAllUserNamesAndProfessions);
router.get("/check", authMiddleWare, checkUser);
router.get("/getFullName", authMiddleWare, getFullName);
router.get("/getUserStats", getUserStats);
router.delete("/:userid", deleteUser);

module.exports = router;
