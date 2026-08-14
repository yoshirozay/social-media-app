const functions = require("firebase-functions");

const deleteAccount = require("../../services/Settings");

exports.deleteAccount = functions.https.onCall((accountInformation) => {
  /**
     * Returns post data
     * @param {string} accountInformation Contains post metadata
     * @return {any} The firestore response
     */
  function loadData(accountInformation) {
    return new Promise(function(resolve, reject) {
      resolve(accountInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load post data."));
    });
  }
  console.log(`accountInformation = ${JSON.stringify(accountInformation)}`);
  return loadData()
      .then(() => {
        const newAccountInformation = {
          userID: accountInformation["userID"],
        };
        deleteAccount.deleteAccount({newAccountInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
