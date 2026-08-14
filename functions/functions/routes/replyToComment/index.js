const functions = require("firebase-functions");

const replyToComment = require("../../services/Comment");

exports.replyToComment = functions.https.onCall((commentInformation) => {
  /**
       * Returns like data
       * @param {string} commentInformation Contains like metadata
       * @return {any} The firestore response
       */
  function loadLike(commentInformation) {
    return new Promise(function(resolve, reject) {
      resolve(commentInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load like data."));
    });
  }
  console.log(`likeInformation = ${JSON.stringify(commentInformation)}`);
  return loadLike()
      .then(() => {
        const newCommentInformation = {
          sentBy: commentInformation["sentBy"],
          comment: commentInformation["comment"],
          commentID: commentInformation["commentID"],
          postID: commentInformation["postID"],
          webLink: commentInformation["webLink"],
          postOwnerID: commentInformation["postOwnerID"],
          otherUserID: commentInformation["otherUserID"],
          token: commentInformation["token"],
          postOwnerToken: commentInformation["postOwnerToken"],
          nameOfSendingUser: commentInformation["nameOfSendingUser"],
          friendsWhoCommented: commentInformation["friendsWhoCommented"],
        };
        replyToComment.replyToComment({newCommentInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
