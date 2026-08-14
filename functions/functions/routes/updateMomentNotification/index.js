const functions = require("firebase-functions");

const updateMomentNotification = require("../../services/Settings");

exports.updateMomentNotification = functions.https.onCall((profileInformation) => {
  /**
   * Returns profile information update
   * @param {string} profileInformation Contains profile metadata
   * @return {any} The firestore response
   */
  function loadData(profileInformation) {
    return new Promise(function(resolve, reject) {
      resolve(profileInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load profile information."));
    });
  }
  console.log(`profileInformation = ${JSON.stringify(profileInformation)}`);
  return loadData()
      .then(() => {
        const newProfileInformation = {
          momentNotifications: profileInformation["momentNotifications"],
          uid: profileInformation["uid"],
        };
        updateMomentNotification.updateMomentNotification({newProfileInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
