const functions = require("firebase-functions");

const uploadWebLink = require("../../services/CreateProfile");

exports.uploadWebLink = functions.https.onCall((profileInformation) => {
  /**
   * Returns profile information update
   * @param {string} profileInformation Contains profile metadata
   * @return {any} The firestore response
   */
  function loadData(profileInformation) {
    return new Promise(function(resolve, reject) {
      resolve(profileInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load profile information."));
    });
  }
  console.log(`profileInformation = ${JSON.stringify(profileInformation)}`);
  return loadData()
      .then(() => {
        const newProfileInformation = {
          webLink: profileInformation["webLink"],
          uid: profileInformation["uid"],
        };
        uploadWebLink.uploadWebLink({newProfileInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
