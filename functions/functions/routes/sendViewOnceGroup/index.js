const functions = require("firebase-functions");

const sendViewOnceGroup = require("../../services/Messages");

exports.sendViewOnceGroup = functions.https.onCall((messageInformation) => {
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
          thumbnailUrl: messageInformation["thumbnailUrl"],
          videoUrl: messageInformation["videoUrl"],
          photoLink: messageInformation["photoLink"],
          alreadyViewOnce: messageInformation["alreadyViewOnce"],
          groupName: messageInformation["groupName"],
          nameOfSendingUser: messageInformation["nameOfSendingUser"],
        };
        sendViewOnceGroup.sendViewOnceGroup({newMessageInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
