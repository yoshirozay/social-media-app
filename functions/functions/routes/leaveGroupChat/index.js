const functions = require("firebase-functions");

const leaveGroupChat = require("../../services/Messages");

exports.leaveGroupChat = functions.https.onCall((messageInformation) => {
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
        console.log(`MESSAGEINFO = ${messageInformation}`);
        const newMessageInformation = {
          currentUser: messageInformation["currentUser"],
          chatUID: messageInformation["chatUID"],
          usersWhoLeft: messageInformation["usersWhoLeft"],
          users: messageInformation["users"],
        };
        leaveGroupChat.leaveGroupChat({newMessageInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
