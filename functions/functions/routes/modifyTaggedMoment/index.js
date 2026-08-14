const functions = require("firebase-functions");

const modifyTaggedMoment = require("../../services/Posts");

exports.modifyTaggedMoment = functions.https.onCall((postInformation) => {
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
        const newPostInformation = {
          sentBy: postInformation["sentBy"],
          content: postInformation["content"],
          postID: postInformation["postID"],
          time: postInformation["time"],
          tags: postInformation["tags"],
          thumbnailUrl: postInformation["thumbnailUrl"],
          videoUrl: postInformation["videoUrl"],
          audioUrl: postInformation["audioUrl"],
          photoLink: postInformation["photoLink"],
          deletePhoto: postInformation["deletePhoto"],
          deleteVideo: postInformation["deleteVideo"],
          deleteAudio: postInformation["deleteAudio"],
          oldFolderName: postInformation["oldFolderName"],
        };
        modifyTaggedMoment.modifyTaggedMoment({newPostInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
