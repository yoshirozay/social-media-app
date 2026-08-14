const functions = require("firebase-functions");

const likeComment = require("../../services/Comment");

exports.likeComment = functions.https.onCall((likeInformation) => {
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
          commentID: likeInformation["commentID"],
          postID: likeInformation["postID"],
          webLink: likeInformation["webLink"],
          postOwnerID: likeInformation["postOwnerID"],
          otherUserID: likeInformation["otherUserID"],
          token: likeInformation["token"],
          nameOfSendingUser: likeInformation["nameOfSendingUser"],
        };
        likeComment.likeComment({newLikeInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
