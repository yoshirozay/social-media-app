const functions = require("firebase-functions");

const deletePost = require("../../services/Posts");

exports.deletePost = functions.https.onCall((postInformation) => {
  /**
     * Returns post data
     * @param {string} postInformation Contains post metadata
     * @return {any} The firestore response
     */
  function loadData(postInformation) {
    return new Promise(function(resolve, reject) {
      resolve(postInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load post data."));
    });
  }
  console.log(`postInformation = ${JSON.stringify(postInformation)}`);
  return loadData()
      .then(() => {
        const newPostInformation = {
          currentUser: postInformation["currentUser"],
          postID: postInformation["postID"],
          isThereAPhoto: postInformation["isThereAPhoto"],
          isThereAVideo: postInformation["isThereAVideo"],
          isThereAudio: postInformation["isThereAudio"],
        };
        deletePost.delete({newPostInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
