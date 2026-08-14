const functions = require("firebase-functions");

const silence = require("../../services/Profile");

exports.silence = functions.https.onCall((silenceInformation) => {
  /**
   * Returns profile information update
   * @param {string} silenceInformation Contains profile metadata
   * @return {any} The firestore response
   */
  function loadData(silenceInformation) {
    return new Promise(function(resolve, reject) {
      resolve(silenceInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load profile information."));
    });
  }
  console.log(`silenceInformation = ${JSON.stringify(silenceInformation)}`);
  return loadData()
      .then(() => {
        const newSilenceInformation = {
          currentUser: silenceInformation["currentUser"],
          silencedUser: silenceInformation["silencedUser"],
        };
        silence.silence({newSilenceInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
