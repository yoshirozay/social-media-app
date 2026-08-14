const functions = require("firebase-functions");

const isTypingInOC = require("../../services/Messages");

exports.isTypingInOC = functions.https.onCall((messageInformation) => {
  /**
   * Returns profile messageInformation update
   * @param {string} messageInformation Contains profile metadata
   * @return {any} The firestore response
   */
  function loadData(messageInformation) {
    return new Promise(function(resolve, reject) {
      resolve(messageInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load profile information."));
    });
  }
  console.log(`messageInformation = ${JSON.stringify(messageInformation)}`);
  return loadData()
      .then(() => {
        messageInformation.forEach((item) => {
          if (item["typingUser"] != item["otherUser"]) {
          const newMessageInformation = {
            typingUser: item["typingUser"],
            otherUser: item["otherUser"],
            chatUID: item["chatUID"],
          };
          isTypingInOC.isTypingInOC({newMessageInformation})
              .then((r) => console.log(r))
              .catch((err) => console.error(err));
          return {
            something: "returned",
          };
        };
        });
      });
});
