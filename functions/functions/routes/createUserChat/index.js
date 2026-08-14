const functions = require("firebase-functions");

const createUserChat = require("../../services/Messages");

exports.createUserChat = functions.https.onCall((messageInformation) => {
  /**
     * Returns message data
     * @param {string} messageInformation Contains message metadata
     * @return {any} The firestore response
     */
  function loadMessage(messageInformation) {
    return new Promise(function(resolve, reject) {
      resolve(messageInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load message data."));
    });
  }
  return loadMessage()
      .then(() => {
        const newMessageInformation = {
          currentUser: messageInformation["currentUser"],
          chatUID: messageInformation["chatUID"],
          otherUserID: messageInformation["otherUserID"],
        };
        createUserChat.createUserChat({newMessageInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
