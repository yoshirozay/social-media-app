const functions = require("firebase-functions");

const deleteSavedPost = require("../../services/Posts");

exports.deleteSavedPost = functions.https.onCall((postInformation) => {
  /**
       * Returns like data
       * @param {string} postInformation Contains post metadata
       * @return {any} The firestore response
       */
  function loadLike(postInformation) {
    return new Promise(function(resolve, reject) {
      resolve(postInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load like data."));
    });
  }
  console.log(`postInformation = ${JSON.stringify(postInformation)}`);
  return loadLike()
      .then(() => {
        const savedPostInformation = {
          currentUser: postInformation["currentUser"],
          postID: postInformation["postID"],
          postAuthor: postInformation["postAuthor"],
        };
        deleteSavedPost.deleteSavedPost({savedPostInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
