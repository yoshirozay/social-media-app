const functions = require("firebase-functions");

const readNotification = require("../../services/Notification");

exports.readNotification = functions.https.onCall((notificationInfo) => {
  /**
       * Returns notification data
       * @param {string} notificationInformation Contains notification metadata
       * @return {any} The firestore response
       */
  function loadNotification(notificationInformation) {
    return new Promise(function(resolve, reject) {
      resolve(notificationInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load notification data."));
    });
  }
  console.log(`notificationInfo = ${JSON.stringify(notificationInfo)}`);
  return loadNotification()
      .then(() => {
        notificationInfo.forEach((item) => {
          const newNotificationInformation = {
            id: item["id"],
            resourceID: item["resourceID"],
            sentFromUser: item["sentFromUser"],
            nameOfSendingUser: item["nameOfSendingUser"],
            originalAuthor: item["originalAuthor"],
            sentTo: item["sentTo"],
            webLink: item["webLink"],
            nameOfSharedFriend: item["nameOfSharedFriend"],
            createdAt: Date.parse(item["createdTime"]),
            currentUser: item["currentUser"],
          };
          readNotification.create({newNotificationInformation})
              .then((r) => console.log(r))
              .catch((err) => console.error(err));
          return {
            something: "returned",
          };
        });
      });
});
