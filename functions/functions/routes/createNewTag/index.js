const functions = require("firebase-functions");

const createNewTag = require("../../services/Tags");

exports.createNewTag = functions.https.onCall((tagInformation) => {
  /**
     * Returns post data
     * @param {string} tagInformation Contains post metadata
     * @return {any} The firestore response
     */
  function loadData(tagInformation) {
    return new Promise(function(resolve, reject) {
      resolve(tagInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load post data."));
    });
  }
  console.log(`Information = ${JSON.stringify(tagInformation)}`);
  return loadData()
      .then(() => {
        const newTagInformation = {
          tagID: tagInformation["tagID"],
          name: tagInformation["name"],
          description: tagInformation["description"],
          createdBy: tagInformation["createdBy"],
        };
        createNewTag.createNewTag({newTagInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
