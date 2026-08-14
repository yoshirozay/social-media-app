const functions = require("firebase-functions");

const sendMessages = require("../../services/Messages");

exports.sendMessage = functions.https.onCall((messageInformation) => {
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
          sentBy: messageInformation["sentBy"],
          message: messageInformation["message"],
          messageUID: messageInformation["messageUID"],
          chatUID: messageInformation["chatUID"],
          otherUserID: messageInformation["otherUserID"],
          token: messageInformation["token"],
          thumbnailUrl: messageInformation["thumbnailUrl"],
          videoUrl: messageInformation["videoUrl"],
          audioUrl: messageInformation["audioUrl"],
          photoLink: messageInformation["photoLink"],
          nameOfSendingUser: messageInformation["nameOfSendingUser"],
          isGIF: messageInformation["isGIF"],
        };
        sendMessages.send({newMessageInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
