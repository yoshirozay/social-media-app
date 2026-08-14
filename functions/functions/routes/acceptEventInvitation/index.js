const functions = require("firebase-functions");

const acceptEventInvitation = require("../../services/Events");

exports.acceptEventInvitation = functions.https.onCall((eventInformation) => {
  /**
     * Returns post data
     * @param {string} eventInformation Contains post metadata
     * @return {any} The firestore response
     */
  function loadData(eventInformation) {
    return new Promise(function(resolve, reject) {
      resolve(eventInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load post data."));
    });
  }
  console.log(`eventInformation = ${JSON.stringify(eventInformation)}`);
  return loadData()
      .then(() => {
        const newEventInformation = {
          sentBy: eventInformation["sentBy"],
          eventID: eventInformation["eventID"],
          eventName: eventInformation["eventName"],
          userID: eventInformation["userID"],
          nameOfSendingUser: eventInformation["nameOfSendingUser"],
          sentByUserToken: eventInformation["sentByUserToken"],
        };
        acceptEventInvitation.acceptEventInvitation({newEventInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
