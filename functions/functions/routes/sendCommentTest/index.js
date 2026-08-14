const functions = require("firebase-functions");

const sendCommentTest = require("../../services/Comment");

exports.sendCommentTest = functions.https.onCall((commentInformation) => {
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
          commentID: commentInformation["commentID"],
          postID: commentInformation["postID"],
          thumbnailUrl: commentInformation["thumbnailUrl"],
          videoUrl: commentInformation["videoUrl"],
          audioUrl: commentInformation["audioUrl"],
          photoLink: commentInformation["photoLink"],
          otherUserID: commentInformation["otherUserID"],
          friendsWhoCommented: commentInformation["friendsWhoCommented"],
          token: commentInformation["token"],
          nameOfSendingUser: commentInformation["nameOfSendingUser"],
          isGIF: commentInformation["isGIF"],
        };
        sendCommentTest.sendCommentTest({newCommentInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
