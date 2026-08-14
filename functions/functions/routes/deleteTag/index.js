const functions = require("firebase-functions");

const deleteTag = require("../../services/Tags");

exports.deleteTag = functions.https.onCall((tagInformation) => {
  /**
       * Returns like data
       * @param {string} postInformation Contains post metadata
       * @return {any} The firestore response
       */
  function loadLike(tagInformation) {
    return new Promise(function(resolve, reject) {
      resolve(tagInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load like data."));
    });
  }
  console.log(`tagInformation = ${JSON.stringify(tagInformation)}`);
  return loadLike()
      .then(() => {
        const newTagInformation = {
          tagCreator: tagInformation["tagCreator"],
          tagID: tagInformation["tagID"],
        };
        deleteTag.deleteTag({newTagInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
