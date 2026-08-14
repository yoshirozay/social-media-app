const functions = require("firebase-functions");

const updateBadge = require("../../services/Profile");

exports.updateBadge = functions.https.onCall((badgeInformation) => {
  /**
   * Returns profile information update
   * @param {string} badgeInformation Contains profile metadata
   * @return {any} The firestore response
   */
  function loadData(badgeInformation) {
    return new Promise(function(resolve, reject) {
      resolve(badgeInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load profile information."));
    });
  }
  console.log(`badgeInformation = ${JSON.stringify(badgeInformation)}`);
  return loadData()
      .then(() => {
        const newBadgeInformation = {
          uid: badgeInformation["uid"]
        };
        updateBadge.updateBadge({newBadgeInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
