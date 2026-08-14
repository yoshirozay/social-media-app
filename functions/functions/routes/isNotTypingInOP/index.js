const functions = require("firebase-functions");

const isNotTypingInOP = require("../../services/Posts");

exports.isNotTypingInOP = functions.https.onCall((postInformation) => {
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
          isNotTypingInOP.isNotTypingInOP({newPostInformation})
              .then((r) => console.log(r))
              .catch((err) => console.error(err));
          return {
            something: "returned",
          };
      });
});
