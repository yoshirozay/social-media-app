const functions = require("firebase-functions");

const sendEventMessage = require("../../services/Events");

exports.sendEventMessage = functions.https.onCall((messageInformation) => {
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
          message: messageInformation["message"],
          messageID: messageInformation["messageID"],
          eventID: messageInformation["eventID"],
          thumbnailUrl: messageInformation["thumbnailUrl"],
          videoUrl: messageInformation["videoUrl"],
          audioUrl: messageInformation["audioUrl"],
          photoLink: messageInformation["photoLink"],
          nameOfSendingUser: messageInformation["nameOfSendingUser"],
          isGIF: messageInformation["isGIF"],
          conversationID: messageInformation["conversationID"],
          eventName: messageInformation["eventName"],
          attendingFriendTokens: messageInformation["attendingFriendTokens"],
        };
        sendEventMessage.sendEventMessage({newMessageInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
