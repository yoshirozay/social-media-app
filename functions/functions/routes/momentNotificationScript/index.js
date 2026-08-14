const functions = require("firebase-functions");

const momentNotificationScript = require("../../services/Settings");


exports.momentNotificationScript = functions.https.onCall((userInformation) => {
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
          friendIDs: userInformation["friendIDs"],
        };
        momentNotificationScript.momentNotificationScript({newUserInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
