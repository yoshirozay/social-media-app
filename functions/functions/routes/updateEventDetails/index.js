const functions = require("firebase-functions");

const updateEventDetails = require("../../services/Events");

exports.updateEventDetails = functions.https.onCall((eventInformation) => {
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
          eventID: eventInformation["eventID"],
          eventName: eventInformation["eventName"],
          eventDescription: eventInformation["eventDescription"],
          eventTimeStart: eventInformation["eventTimeStart"],
          eventImage: eventInformation["eventImage"],
          location: eventInformation["location"],
          allAttendingTokens: eventInformation["allAttendingTokens"],
          newEventTime: eventInformation["newEventTime"],
          newEventTimeString: eventInformation["newEventTimeString"],
        };
        updateEventDetails.updateEventDetails({newEventInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
