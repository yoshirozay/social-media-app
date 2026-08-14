const functions = require("firebase-functions");

const likeCommentReply = require("../../services/Comment");

exports.likeCommentReply = functions.https.onCall((likeInformation) => {
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
          originalCommentID: likeInformation["originalCommentID"],
          postID: likeInformation["postID"],
          webLink: likeInformation["webLink"],
          postOwnerID: likeInformation["postOwnerID"],
          otherUserID: likeInformation["otherUserID"],
          token: likeInformation["token"],
          commentID: likeInformation["commentID"],
          nameOfSendingUser: likeInformation["nameOfSendingUser"],
        };
        likeCommentReply.likeCommentReply({newLikeInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
