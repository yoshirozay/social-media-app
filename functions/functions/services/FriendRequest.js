/* eslint-disable require-jsdoc */
const {DB, deleteField} = require("./Firestore");
const crypto = require("crypto");
const admin = require("firebase-admin");

class FriendRequestService {
  constructor() {
    this.collection = DB.collection("FriendRequests");
    this.newCollection = DB.collection("Friends");
    this.secondCollection = DB.collection("Notifications");
    this.thirdCollection = DB.collection("UserChats");
    this.fourthCollection = DB.collection("RemovedSuggestedFriends")
    this.fifthCollection = DB.collection("UserInfo");
  }

  /**
     * Creates a friend request between the currently logged in user
     * and the specified user ID
     * @param {string} userId The user to add
     * @param {string} formattedUID The current user
     * @return {any} The firestore response
     */
  create({newRequestInfo, currentUser}) {
    const name = newRequestInfo["nameOfSendingUser"];
    const message = {
      notification: {
        title: 'speakEZ',
        body: `${name} sent you a friend request`,
        // body: "2:45",
      },
      data: {
        type: "NEW_FRIEND_REQUEST",
        userID: currentUser || "",
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
      token: `${newRequestInfo["token"]}`,
    };
    this.notificationID = crypto.randomBytes(16).toString("hex");
    const friendRequestDocument = {};
    friendRequestDocument[currentUser] = "";
    return this.collection.doc(newRequestInfo["id"])
        .set(friendRequestDocument, {merge: true})
        .then(() => {
          return this.collection.doc(newRequestInfo["id"])
              .collection("NewRequests")
              .doc("NewRequests")
              .set({
                "newRequest": true,
              });
        })
        .then(() => {
          return this.secondCollection
              .doc(newRequestInfo["id"])
              .collection("MyNotifications")
              .doc(`${this.notificationID}`)
              .set({
                "id": `${this.notificationID}`,
                "resourceID": `friendRequest:${currentUser}`,
                "sentFromUser": `${currentUser}`,
                "newFriendRequest": true,
                "createdAt": new Date()})
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
        });
  }
  readFriendRequests({newRequestInfo}) {
    return this.collection.doc(newRequestInfo["id"])
        .collection("NewRequests")
        .doc("NewRequests")
        .set({
          "newRequest": false,
        }, {merge: true});
  }

  /**
     * Accepts friend request between the currently logged in user
     * and the specified user ID
     * @param {string} userId The user to add
     * @param {string} formattedUID The current user
     * @return {any} The firestore response
     */
  accept({newRequestInfo, currentUser}) {
    const name = newRequestInfo["nameOfSendingUser"];
    const message = {
      notification: {
        title: 'speakEZ',
        body: `${name} accepted your friend request`,
        // body: "2:45",
      },
      data: {
        type: "NEW_FRIEND_REQUEST",
        userID: currentUser || "",
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
      token: `${newRequestInfo["token"]}`,
    };
    this.notificationID = crypto.randomBytes(16).toString("hex");
    const acceptingUserId = {};
    acceptingUserId[currentUser] = "test";
    return this.newCollection.doc(newRequestInfo["id"])
        .set(acceptingUserId, {merge: true})
        .then(() => {
          const userWhoSentTheRequestId = {};
          userWhoSentTheRequestId[newRequestInfo["id"]] = "test";
          return this.newCollection
              .doc(currentUser)
              .set(userWhoSentTheRequestId, {merge: true});
        }).then(() => {
          const deleteFromFriendRequestsList = {};
          deleteFromFriendRequestsList[newRequestInfo["id"]] = deleteField();
          return this.collection
              .doc(currentUser)
              .update(deleteFromFriendRequestsList);
        }).then(() => {
          return this.secondCollection
              .doc(newRequestInfo["id"])
              .collection("MyNotifications")
              .doc(`${this.notificationID}`)
              .set({
                "id": `${this.notificationID}`,
                "resourceID": `acceptedRequest:${currentUser}`,
                "sentFromUser": `${currentUser}`,
                "createdAt": new Date()})
        }).then(() => {
            return this.thirdCollection
                .doc(currentUser)
                .collection("UserChatss")
                .doc(this.notificationID)
                .set({
                  "user": newRequestInfo["id"],
                  "time": new Date()}, {merge: true})
                .then(() => {
                  return this.thirdCollection
                    .doc(`${newRequestInfo["id"]}`)
                    .collection("UserChatss")
                    .doc(this.notificationID)
                    .set({
                      "user": currentUser,
                      "time": new Date()}, {merge: true});
                    }) 
        }).then(() => {
            const newUserId = {};
            newUserId[newRequestInfo["id"]] = true;
            return this.fifthCollection.doc(currentUser)
                .collection("Settings")
                .doc("MomentNotifications")
                .set(newUserId, {merge: true})
                .then(() => {
                  return this.fifthCollection.doc(currentUser)
                      .collection("Settings")
                      .doc("CommentNotifications")
                      .set(newUserId, {merge: true})
                }).then(() => {
                const currentUserID = {};
                currentUserID[currentUser] = true;
                return this.fifthCollection.doc(newRequestInfo["id"])
                    .collection("Settings")
                    .doc("MomentNotifications")
                    .set(currentUserID, {merge: true})
                    .then(() => {
                      return this.fifthCollection.doc(newRequestInfo["id"])
                          .collection("Settings")
                          .doc("CommentNotifications")
                          .set(currentUserID, {merge: true})
                    });
                  })
        }).then(() => {
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

  /**
     * Cancels a friend request between the currently logged in user
     * and the specified user ID
     * @param {string} userId The user to add
     * @param {string} formattedUID The current user
     * @return {any} The firestore response
     */
  cancel({userId, formattedUID}) {
    const otherUserId = {};
    otherUserId[formattedUID] = new Date();
    const currentUserId = {};
    currentUserId[userId] = new Date();
    return this.fourthCollection
        .doc(userId)
        .set(otherUserId, {merge: true})
        .then(() => {
          return this.fourthCollection
              .doc(formattedUID)
              .set(currentUserId, {merge: true})
         })
        .then(() => {
        const friendRequestDocument = {};
        friendRequestDocument[formattedUID] = deleteField();
          return this.collection.doc(userId).update(friendRequestDocument)
    })
  }
}

const friendRequests = new FriendRequestService();

module.exports = friendRequests;
