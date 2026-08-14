/* eslint-disable require-jsdoc */
// const {DB, bucket} = require("./Firestore");
const {DB, deleteField} = require("./Firestore");
const admin = require("firebase-admin");

class FriendService {
  constructor() {
    this.collection = DB.collection("Notifications");
    this.secondCollection = DB.collection("Friends");
    this.thirdCollection = DB.collection("ReportedUsers");
    this.fourthCollection = DB.collection("RemovedSuggestedFriends")
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
  shareFriend({newNotificationInformation}) {
    const sendingUser = `${newNotificationInformation["nameOfSendingUser"]}`;
    const message = {
      notification: {
        title: `speakEZ`,
        body: `${sendingUser} shared a friend with you`,
        // body: "2:45",
      },
      data: {
        type: "NEW_FRIEND_REQUEST",
        userID: newNotificationInformation["sharedFriendID"],
      },
      apns: {
        headers: {
            'apns-priority': '10',
        },
        payload: {
            aps: {
                sound: 'default',
            }
        },
    },
      token: `${newNotificationInformation["token"]}`,
    };
    let notificationInfo = {};
    notificationInfo = {
      "resourceID": `${newNotificationInformation["resourceID"]}`,
      "sentFromUser": `${newNotificationInformation["sentFromUser"]}`,
      "nameOfSharedFriend": newNotificationInformation["nameOfSharedFriend"],
      "webLink": newNotificationInformation["webLink"],
      "createdAt": new Date(),
    };
    return this.collection.doc(newNotificationInformation["sentTo"])
        .collection("MyNotifications")
        .doc(newNotificationInformation["id"])
        .set(notificationInfo)
        .then(() => {
          admin.messaging().send(message)
              .then((response) => {
                // Response is a message ID string.
                console.log("Successfully sent message:", response);
              })
              .catch((error) => {
                console.log("Error sending message:", error);
              });
        });
  }
  deleteFriend({newDeleteInformation}) {
    const deleteFriend = {};
    deleteFriend[newDeleteInformation["deletedUser"]] = deleteField();
    const deleteMe = {};
    deleteMe[newDeleteInformation["currentUser"]] = deleteField();
    return this.secondCollection
        .doc(newDeleteInformation["currentUser"])
        .update(deleteFriend)
        .then(() => {
          return this.secondCollection
              .doc(newDeleteInformation["deletedUser"])
              .update(deleteMe);
        });
  }
  reportUser({newReportInformation}) {
    return this.thirdCollection
        .doc(newReportInformation["reportedUserID"])
        .collection("Reports")
        .doc(newReportInformation["currentUser"])
        .collection("MyReports")
        .doc(newReportInformation["reportID"])
        .set({
          "message": newReportInformation["message"],
          "createdAt": new Date()}, {merge: true});
  }
  removeSuggestedFriend({newRemovedInformation}) {
    const otherUserId = {};
    otherUserId[newRemovedInformation["removedUserID"]] = new Date();
    const currentUserId = {};
    currentUserId[newRemovedInformation["currentUser"]] = new Date();
    return this.fourthCollection
        .doc(newRemovedInformation["currentUser"])
        .set(otherUserId, {merge: true})
        .then(() => {
          return this.fourthCollection
              .doc(newRemovedInformation["removedUserID"])
              .set(currentUserId, {merge: true})
        })
  }
}

const shareFriend = new FriendService();
module.exports = shareFriend;
