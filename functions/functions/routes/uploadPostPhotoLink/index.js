const functions = require("firebase-functions");

const uploadPostPhotoLink = require("../../services/Posts");

exports.uploadPostPhotoLink = functions.https.onCall((postInformation) => {
  /**
   * Returns profile information update
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
          postAuthor: postInformation["postAuthor"],
          postID: postInformation["postID"],
          photoLink: postInformation["photoLink"],
        };
        uploadPostPhotoLink.uploadPostPhotoLink({newPostInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});