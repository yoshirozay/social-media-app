const functions = require("firebase-functions");

const sendComment = require("../../services/Comment");

exports.sendComment = functions.https.onCall((commentInformation) => {
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
  const friends = commentInformation["friendsWhoCommented"];
  console.log(`commentInformation = ${JSON.stringify(commentInformation)}`);
  console.log(`friendIDS = ${JSON.stringify(friends)}`);
  return loadComment()
      .then(() => {
        const newCommentInformation = {
          sentBy: commentInformation["sentBy"],
          comment: commentInformation["comment"],
          postID: commentInformation["postID"],
          otherUserID: commentInformation["otherUserID"],
          friendsWhoCommented: commentInformation["friendsWhoCommented"],
          token: commentInformation["token"],
          nameOfSendingUser: commentInformation["nameOfSendingUser"],
        };
        sendComment.create({newCommentInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
