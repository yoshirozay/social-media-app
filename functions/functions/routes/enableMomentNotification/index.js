const functions = require("firebase-functions");

const enableMomentNotification = require("../../services/Settings");


exports.enableMomentNotification = functions.https.onCall((userInformation) => {
  /**
   * Returns settings information update
   * @param {string} settingsInfo Contains settings metadata
   * @return {any} The firestore response
   */
  function loadData(userInformation) {
    return new Promise(function(resolve, reject) {
      resolve(userInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load profile information."));
    });
  }
  console.log(`userInformation = ${JSON.stringify(userInformation)}`);
  return loadData()
      .then(() => {
        const newUserInformation = {
          uid: userInformation["uid"],
          friendID: userInformation["friendID"],
        };
        enableMomentNotification.enableMomentNotification({newUserInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
