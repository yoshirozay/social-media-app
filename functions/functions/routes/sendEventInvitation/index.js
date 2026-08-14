const functions = require("firebase-functions");

const sendEventInvitation = require("../../services/Events");

exports.sendEventInvitation = functions.https.onCall((eventInformation) => {
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
        eventInformation.forEach((item) => {
          const newEventInformation = {
            sentBy: item["sentBy"],
            eventID: item["eventID"],
            userID: item["userID"],
            nameOfSendingUser: item["nameOfSendingUser"],
            eventName: item["eventName"],
          };
          sendEventInvitation.sendEventInvitation({newEventInformation})
              .then((r) => console.log(r))
              .catch((err) => console.error(err));
          return {
            something: "returned",
          };
        });
      });
});
