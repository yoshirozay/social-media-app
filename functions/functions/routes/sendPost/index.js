const functions = require("firebase-functions");

const sendPosts = require("../../services/Posts");

exports.sendPost = functions.https.onCall((postInformation) => {
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
          sentBy: postInformation["sentBy"],
          content: postInformation["content"],
          postID: postInformation["postID"],
          thumbnailUrl: postInformation["thumbnailUrl"],
          videoUrl: postInformation["videoUrl"],
          photoLink: postInformation["photoLink"],
        };
        sendPosts.create({newPostInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
