const functions = require("firebase-functions");

const hasDoneIntroduction = require("../../services/Settings");

exports.hasDoneIntroduction = functions.https.onCall((videoInformation) => {
  /**
     * Returns message data
     * @param {string} videoInformation Contains message metadata
     * @return {any} The firestore response
     */
  function loadMessage(videoInformation) {
    return new Promise(function(resolve, reject) {
      resolve(videoInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load message data."));
    });
  }
  return loadMessage()
      .then(() => {
        const newVideoInformation = {
          userID: videoInformation["userID"],
        };
        hasDoneIntroduction.hasDoneIntroduction({newVideoInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
