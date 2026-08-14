/* eslint-disable require-jsdoc */
// const {DB, bucket} = require("./Firestore");
const {DB} = require("./Firestore");
const crypto = require("crypto");
const admin = require("firebase-admin");

class LikeService {
  constructor() {
    this.collection = DB.collection("Posts");
    this.secondCollection = DB.collection("Notifications");
  }
  /**
     * Creates a new like.
     * @param {string} sentBy The user who sent the like
     * @param {string} postID The ID of the post
     * @param {string} otherUserID The ID of the user who wrote the post
     * @return {any} The firestore response
     */
  create({newLikeInformation}) {
    const message = {
      notification: {
        title: `speakEZ`,
        body: `${newLikeInformation["nameOfSendingUser"]} liked your moment`,
      },
      data: {
        type: "NEW_POST_LIKE",
        authorId: newLikeInformation["otherUserID"],
        postId: newLikeInformation["postID"],
        userID: newLikeInformation["sentBy"],
        postAuthorId: newLikeInformation["otherUserID"],
      },
      apns: {
        headers: {
            'apns-priority': '10',
        },
        payload: {
            aps: {
              threadId: newLikeInformation["postID"],
            }
        },
    },
      token: `${newLikeInformation["token"]}`,
    };
    console.log(`sentBy = ${newLikeInformation["sentBy"]}`);
    this.notificationID = crypto.randomBytes(16).toString("hex");
    return this.collection.doc(newLikeInformation["otherUserID"])
        .collection("UserPosts")
        .doc(newLikeInformation["postID"])
        .collection("Likes")
        .doc(newLikeInformation["sentBy"])
        .set({
          "sentBy": newLikeInformation["sentBy"],
          "time": new Date()})
        .then(() => {
          return this.secondCollection
              .doc(`${newLikeInformation["otherUserID"]}`)
              .collection("MyNotifications")
              .doc(`${this.notificationID}`)
              .set({
                "id": `${this.notificationID}`,
                "resourceID": `like:${newLikeInformation["postID"]}`,
                "sentFromUser": `${newLikeInformation["sentBy"]}`,
                "originalAuthor": `${newLikeInformation["otherUserID"]}`,
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
}

const sendLike = new LikeService();
module.exports = sendLike;
