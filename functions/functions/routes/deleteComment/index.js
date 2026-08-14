const functions = require("firebase-functions");

const deleteComment = require("../../services/Comment");

exports.deleteComment = functions.https.onCall((commentInformation) => {
  /**
       * Returns comment data
       * @param {string} commentInformation Contains comment metadata
       * @return {any} The firestore response
       */
  function loadComment(commentInformation) {
    return new Promise(function(resolve, reject) {
      resolve(commentInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load comment data."));
    });
  }
  console.log(`commentInformation = ${JSON.stringify(commentInformation)}`);
  return loadComment()
      .then(() => {
        const newCommentInformation = {
          sentBy: commentInformation["sentBy"],
          commentID: commentInformation["commentID"],
          postID: commentInformation["postID"],
          postOwnerID: commentInformation["otherUserID"],
        };
        deleteComment.deleteComment({newCommentInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
