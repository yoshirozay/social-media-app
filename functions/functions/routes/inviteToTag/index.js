const functions = require("firebase-functions");

const inviteToTag = require("../../services/Tags");

exports.inviteToTag = functions.https.onCall((inviteInformation) => {
  /**
     * Returns invite data
     * @param {string} inviteInformation Contains invite metadata
     * @return {any} The firestore response
     */
  function loadData(inviteInformation) {
    return new Promise(function(resolve, reject) {
      resolve(inviteInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load post data."));
    });
  }
  console.log(`tagInformation = ${JSON.stringify(inviteInformation)}`);
  return loadData()
      .then(() => {
        inviteInformation.forEach((item) => {
          const newInviteInformation = {
            tagID: item["tagID"],
            sentTo: item["sentTo"],
            creatorID: item["creatorID"],
          };
          inviteToTag.inviteToTag({newInviteInformation})
              .then((r) => console.log(r))
              .catch((err) => console.error(err));
          return {
            something: "returned",
          };
        });
      });
});
