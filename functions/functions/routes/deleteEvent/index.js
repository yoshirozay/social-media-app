const functions = require("firebase-functions");

const deleteEvent = require("../../services/Events");
const {
  getUserToken,
} = require("../../helpers/functions");

exports.deleteEvent = functions.https.onCall((eventInformation) => {
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
          eventName: eventInformation["eventName"]
        };
        deleteEvent.deleteEvent({newEventInformation, getUserToken})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
