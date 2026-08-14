const functions = require("firebase-functions");

const didViewMessage = require("../../services/Messages");

exports.didViewMessage = functions.https.onCall((messageInformation) => {
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
          messageUID: messageInformation["messageUID"],
          chatUID: messageInformation["chatUID"],
          alreadyViewOnce: messageInformation["alreadyViewOnce"],
        };
        didViewMessage.didViewMessage({newMessageInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
