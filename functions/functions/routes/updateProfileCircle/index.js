const functions = require("firebase-functions");

const updateProfileCircle = require("../../services/Profile");

exports.updateProfileCircle = functions.https.onCall((circleInformation) => {
  /**
       * Returns like data
       * @param {string} circleInformation Contains post metadata
       * @return {any} The firestore response
       */
  function loadLike(circleInformation) {
    return new Promise(function(resolve, reject) {
      resolve(circleInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load like data."));
    });
  }
  console.log(`circleInformation = ${JSON.stringify(circleInformation)}`);
  return loadLike()
      .then(() => {
        const newCircleInformation = {
          currentUser: circleInformation["currentUser"],
          profileCircle: circleInformation["color"],
        };
        updateProfileCircle.updateProfileCircle({newCircleInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
