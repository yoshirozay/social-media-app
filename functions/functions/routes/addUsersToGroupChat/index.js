const functions = require("firebase-functions");

const addUsersToGroupChat = require("../../services/Messages");

exports.addUsersToGroupChat = functions.https.onCall((messageInformation) => {
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
        messageInformation["users"].forEach((item) => {
          const newMessageInformation = {
            currentUser: item,
            chatUID: messageInformation["chatUID"],
            users: messageInformation["users"],
            name: messageInformation["name"],
          };
          addUsersToGroupChat.addUsersToGroupChat({newMessageInformation})
              .then((r) => console.log(r))
              .catch((err) => console.error(err));
          return {
            something: "returned",
          };
        });
      });
});
