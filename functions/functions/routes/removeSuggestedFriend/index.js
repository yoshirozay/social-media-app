const functions = require("firebase-functions");

const removeSuggestedFriend = require("../../services/Friends");

exports.removeSuggestedFriend = functions.https.onCall((removedInformation) => {
  /**
     * Returns post data
     * @param {string} removedInformation Contains post metadata
     * @return {any} The firestore response
     */
  function loadData(removedInformation) {
    return new Promise(function(resolve, reject) {
      resolve(removedInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load post data."));
    });
  }
  console.log(`removedInformation = ${JSON.stringify(removedInformation)}`);
  return loadData()
      .then(() => {
        const newRemovedInformation = {
          currentUser: removedInformation["currentUser"],
          removedUserID: removedInformation["removedUserID"],
        };
        removeSuggestedFriend.removeSuggestedFriend({newRemovedInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
