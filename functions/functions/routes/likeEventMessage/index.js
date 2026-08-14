const functions = require("firebase-functions");

const likeEventMessage = require("../../services/Events");

exports.likeEventMessage = functions.https.onCall((messageInformation) => {
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
  console.log(`messageInformation = ${JSON.stringify(messageInformation)}`);
  return loadMessage()
      .then(() => {
        const newMessageInformation = {
          sentBy: messageInformation["sentBy"],
          messageID: messageInformation["messageID"],
          eventID: messageInformation["eventID"],
          nameOfSendingUser: messageInformation["nameOfSendingUser"],
          conversationID: messageInformation["conversationID"]
        };
        likeEventMessage.likeEventMessage({newMessageInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
