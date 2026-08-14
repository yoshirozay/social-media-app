const functions = require("firebase-functions");

const featureRequest = require("../../services/Profile");

exports.featureRequest = functions.https.onCall((featureInformation) => {
  /**
     * Returns post data
     * @param {string} featureInformation Contains post metadata
     * @return {any} The firestore response
     */
  function loadData(featureInformation) {
    return new Promise(function(resolve, reject) {
      resolve(featureInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load post data."));
    });
  }
  console.log(`featureInformation = ${JSON.stringify(featureInformation)}`);
  return loadData()
      .then(() => {
        const newFeatureInformation = {
          id: featureInformation["id"],
          currentUser: featureInformation["currentUser"],
          message: featureInformation["message"],
        };
        featureRequest.featureRequest({newFeatureInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
