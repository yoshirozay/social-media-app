const functions = require("firebase-functions");
const userNameService = require("../../services/UserName");

exports.checkUserNameAvailability = functions.https.onCall((userName) => {
  return userNameService.checkUserNameAvailability(userName);
});
