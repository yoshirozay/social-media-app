const functions = require("firebase-functions");

const didTakePostScreenshot = require("../../services/Posts");

exports.didTakePostScreenshot = functions.https.onCall((postInformation) => {
  /**
     * Returns post data
     * @param {string} postInformation Contains post metadata
     * @return {any} The firestore response
     */
  function loadMessage(postInformation) {
    return new Promise(function(resolve, reject) {
      resolve(postInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load message data."));
    });
  }
  return loadMessage()
      .then(() => {
        const newPostInformation = {
          postID: postInformation["postID"],
          postAuthor: postInformation["postAuthor"],
          currentUser: postInformation["currentUser"],
          didTakePostScreenshot: postInformation["didTakePostScreenshot"],
        };
        didTakePostScreenshot.didTakePostScreenshot({newPostInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
