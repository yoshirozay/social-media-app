const functions = require("firebase-functions");

const acceptTagInvitation = require("../../services/Tags");

exports.acceptTagInvitation = functions.https.onCall((inviteInformation) => {
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
        const newInviteInformation = {
          documentID: inviteInformation["documentID"],
          tagID: inviteInformation["tagID"],
          acceptingUser: inviteInformation["acceptingUser"],
          sentBy: inviteInformation["sentBy"],
        };
        acceptTagInvitation.acceptTagInvitation({newInviteInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
