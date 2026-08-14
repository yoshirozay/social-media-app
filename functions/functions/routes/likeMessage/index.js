const functions = require("firebase-functions");

const likeMessage = require("../../services/Messages");

exports.likeMessage = functions.https.onCall((likeInformation) => {
  /**
       * Returns like data
       * @param {string} likeInformation Contains like metadata
       * @return {any} The firestore response
       */
  function loadLike(likeInformation) {
    return new Promise(function(resolve, reject) {
      resolve(likeInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load like data."));
    });
  }
  console.log(`likeInformation = ${JSON.stringify(likeInformation)}`);
  return loadLike()
      .then(() => {
        const newLikeInformation = {
          sentBy: likeInformation["sentBy"],
          messageID: likeInformation["messageID"],
          otherUserID: likeInformation["otherUserID"],
          chatUID: likeInformation["chatUID"],
          token: likeInformation["token"],
          nameOfSendingUser: likeInformation["nameOfSendingUser"],
        };
        likeMessage.likeMessage({newLikeInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
