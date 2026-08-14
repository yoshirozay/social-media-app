const functions = require("firebase-functions");

const acceptEventRequest = require("../../services/Events");

exports.acceptEventRequest = functions.https.onCall((eventInformation) => {
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
          currentUser: eventInformation["currentUser"],
          eventID: eventInformation["eventID"],
          eventName: eventInformation["eventName"],
          userID: eventInformation["userID"],
          token: eventInformation["token"],
        };
        acceptEventRequest.acceptEventRequest({newEventInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
