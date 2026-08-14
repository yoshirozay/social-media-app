
const functions = require("firebase-functions");

const deleteFriend = require("../../services/Friends");

exports.deleteFriend = functions.https.onCall((deleteInfo) => {
  /**
       * Returns notification data
       * @param {string} deleteInfo Contains notification metadata
       * @return {any} The firestore response
       */
  function loadNotification(deleteInfo) {
    return new Promise(function(resolve, reject) {
      resolve(deleteInfo);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load notification data."));
    });
  }
  console.log(`deleteInfo = ${JSON.stringify(deleteInfo)}`);
  return loadNotification()
      .then(() => {
        const newDeleteInformation = {
          deletedUser: deleteInfo["deletedUser"],
          currentUser: deleteInfo["currentUser"],
        };
        deleteFriend.deleteFriend({newDeleteInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});

