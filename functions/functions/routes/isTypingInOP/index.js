const functions = require("firebase-functions");

const isTypingInOP = require("../../services/Posts");

exports.isTypingInOP = functions.https.onCall((postInformation) => {
  /**
   * Returns profile messageInformation update
   * @param {string} postInformation Contains profile metadata
   * @return {any} The firestore response
   */
  function loadData(postInformation) {
    return new Promise(function(resolve, reject) {
      resolve(postInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load profile information."));
    });
  }
  console.log(`postInformation = ${JSON.stringify(postInformation)}`);
  return loadData()
      .then(() => {
          const newPostInformation = {
            typingUser: postInformation["typingUser"],
            originalAuthor: postInformation["originalAuthor"],
            postID: postInformation["postID"],
          };
          isTypingInOP.isTypingInOP({newPostInformation})
              .then((r) => console.log(r))
              .catch((err) => console.error(err));
          return {
            something: "returned",
          };
      });
});
