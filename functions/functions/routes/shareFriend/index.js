
const functions = require("firebase-functions");

const shareFriend = require("../../services/Friends");

exports.shareFriend = functions.https.onCall((notificationInfo) => {
  /**
       * Returns notification data
       * @param {string} notificationInfo Contains notification metadata
       * @return {any} The firestore response
       */
  function loadNotification(notificationInfo) {
    return new Promise(function(resolve, reject) {
      resolve(notificationInfo);
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
            sentTo: item["sentTo"],
            webLink: item["webLink"],
            nameOfSharedFriend: item["nameOfSharedFriend"],
            sharedFriendID: item["sharedFriendID"],
            createdAt: new Date(),
            token: item["token"],
          };
          shareFriend.shareFriend({newNotificationInformation})
              .then((r) => console.log(r))
              .catch((err) => console.error(err));
          return {
            something: "returned",
          };
        });
      });
});
