const functions = require("firebase-functions");

const friendsListPreference = require("../../services/Settings");


exports.friendsListPreference = functions.https.onCall((settingsInfo) => {
  /**
   * Returns settings information update
   * @param {string} settingsInfo Contains settings metadata
   * @return {any} The firestore response
   */
  function loadData(settingsInfo) {
    return new Promise(function(resolve, reject) {
      resolve(settingsInfo);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load profile information."));
    });
  }
  console.log(`settingsInformation = ${JSON.stringify(settingsInfo)}`);
  return loadData()
      .then(() => {
        const newSettingsInformation = {
          friendsListView: settingsInfo["friendsListView"],
          uid: settingsInfo["uid"],
        };
        friendsListPreference.friendsListPreference({newSettingsInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
