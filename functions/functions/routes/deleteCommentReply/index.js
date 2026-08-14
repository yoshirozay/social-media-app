const functions = require("firebase-functions");

const deleteCommentReply = require("../../services/Comment");

exports.deleteCommentReply = functions.https.onCall((commentInformation) => {
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
          ogCommentID: commentInformation["ogCommentID"],
          commentReplyID: commentInformation["commentReplyID"],
          postID: commentInformation["postID"],
          postOwnerID: commentInformation["otherUserID"],
        };
        deleteCommentReply.deleteCommentReply({newCommentInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
