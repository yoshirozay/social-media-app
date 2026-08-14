const functions = require("firebase-functions");

const AppPasswordService = require("../../services/AppPassword");

exports.doesPasswordExist = functions.https.onCall((password) => {
  return AppPasswordService.doesPasswordExist(password);
});
