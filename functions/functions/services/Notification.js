/* eslint-disable require-jsdoc */
// const {DB, bucket} = require("./Firestore");
const {DB} = require("./Firestore");

class NotificationService {
  constructor() {
    this.collection = DB.collection("Notifications");
  }
  /**
     * Creates an old notification.
     * @param {string} id The notification id
     * @param {string} currentUser The user who sent the like
     * @param {string} resourceID The ID of the resource (like, friend request)
     * @param {string} sentFromUser The ID of the user who sent the notification
     * @param {string} createdAt The creation time of the notification
     * @return {any} The firestore response
     */
  create({newNotificationInformation}) {
    const time = `${newNotificationInformation["createdAt"]}`;
    console.log(`time = ${JSON.stringify(time)}`);
    console.log(`newNoti = ${JSON.stringify(newNotificationInformation)}`);
    let notificationInformation = {};
    if (newNotificationInformation["nameOfSharedFriend"] != undefined) {
      notificationInformation = {
        "id": `${newNotificationInformation["id"]}`,
        "resourceID": `${newNotificationInformation["resourceID"]}`,
        "sentFromUser": `${newNotificationInformation["sentFromUser"]}`,
        "originalAuthor": `${newNotificationInformation["originalAuthor"]}`,
        "nameOfSharedFriend": newNotificationInformation["nameOfSharedFriend"],
        "webLink": `${newNotificationInformation["webLink"]}`,
        "createdAt": new Date(newNotificationInformation["createdAt"]),
      };
    } else if (newNotificationInformation["nameOfSendingUser"] != undefined) {
      notificationInformation = {
        "id": `${newNotificationInformation["id"]}`,
        "resourceID": `${newNotificationInformation["resourceID"]}`,
        "sentFromUser": `${newNotificationInformation["sentFromUser"]}`,
        "originalAuthor": `${newNotificationInformation["originalAuthor"]}`,
        "nameOfSendingUser": newNotificationInformation["nameOfSendingUser"],
        "webLink": `${newNotificationInformation["webLink"]}`,
        "createdAt": new Date(newNotificationInformation["createdAt"]),
      };
    } else {
      notificationInformation = {
        "id": `${newNotificationInformation["id"]}`,
        "resourceID": `${newNotificationInformation["resourceID"]}`,
        "originalAuthor": `${newNotificationInformation["originalAuthor"]}`,
        "sentFromUser": `${newNotificationInformation["sentFromUser"]}`,
        "createdAt": new Date(newNotificationInformation["createdAt"]),
      };
    }
    return this.collection.doc(newNotificationInformation["currentUser"])
        .collection("OldNotifications")
        .doc(newNotificationInformation["id"])
        .set(notificationInformation)
        .then(() => {
          return this.collection.doc(newNotificationInformation["currentUser"])
              .collection("MyNotifications")
              .doc(newNotificationInformation["id"])
              .delete();
        });
  }
}

const readNotification = new NotificationService();
module.exports = readNotification;
