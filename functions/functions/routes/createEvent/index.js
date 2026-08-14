const functions = require("firebase-functions");

const createEvent = require("../../services/Events");

exports.createEvent = functions.https.onCall((eventInformation) => {
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
          createdBy: eventInformation["createdBy"],
          hostIDs: eventInformation["hostIDs"],
          eventID: eventInformation["eventID"],
          eventName: eventInformation["eventName"],
          eventDescription: eventInformation["eventDescription"],
          eventTimeStart: eventInformation["eventTimeStart"],
          // eventTimeEnd: eventInformation["eventTimeEnd"],
          eventImage: eventInformation["eventImage"],
          conversationID: eventInformation["conversationID"],
          invitedUsers: eventInformation["invitedUsers"],
          location: eventInformation["location"],
          nameOfSendingUser: eventInformation["nameOfSendingUser"],
        };
        createEvent.createEvent({newEventInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
