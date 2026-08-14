/* eslint-disable require-jsdoc */
// const {DB, bucket} = require("./Firestore");
const {DB, deleteField} = require("./Firestore");
const crypto = require("crypto");
const admin = require("firebase-admin");

class CommentService {
  constructor() {
    this.collection = DB.collection("Posts");
    this.secondCollection = DB.collection("Notifications");
    this.thirdCollection = DB.collection("CommentSubscription");
  }
  /**
     * Creates a new comment.
     * @param {string} sentBy The user who sent the comment
     * @param {string} comment The content of the comment
     * @param {string} postID The ID of the post
     * @param {string} otherUserID The ID of the user who wrote the post
     * @return {any} The firestore response
     */
  create({newCommentInformation}) {
    const sendingUser = `${newCommentInformation["nameOfSendingUser"]}`;
    const message = {
      notification: {
        body: `${sendingUser} commented on your moment`,
      },
      token: `${newCommentInformation["token"]}`,
    };
    this.commentID = crypto.randomBytes(16).toString("hex");
    this.notificationID = crypto.randomBytes(16).toString("hex");
    const otherID = newCommentInformation["otherUserID"];
    console.log(`otherUserID = ${newCommentInformation["otherUserID"]}`);
    return this.collection.doc(newCommentInformation["otherUserID"])
        .collection("UserPosts")
        .doc(newCommentInformation["postID"])
        .collection("Comments")
        .doc(`${this.commentID}`)
        .set({
          "sentBy": newCommentInformation["sentBy"],
          "comment": newCommentInformation["comment"],
          "time": new Date()})
        .then(() => {
          if (otherID != newCommentInformation["sentBy"]) {
            return this.secondCollection
                .doc(`${newCommentInformation["otherUserID"]}`)
                .collection("MyNotifications")
                .doc(`${this.notificationID}`)
                .set({
                  "id": `${this.notificationID}`,
                  "resourceID": `comment:${newCommentInformation["postID"]}`,
                  "sentFromUser": `${newCommentInformation["sentBy"]}`,
                  "originalAuthor": `${newCommentInformation["otherUserID"]}`,
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
          }
        })
        .then(() => {
          newCommentInformation["friendsWhoCommented"].forEach((item) => {
            this.newNotificationID = crypto.randomBytes(16).toString("hex");
            return this.secondCollection
                .doc(item)
                .collection("MyNotifications")
                .doc(`${this.newNotificationID}`)
                .set({
                  "id": `${this.newNotificationID}`,
                  "resourceID": `alsoC:${newCommentInformation["postID"]}`,
                  "sentFromUser": `${newCommentInformation["sentBy"]}`,
                  "originalAuthor": `${newCommentInformation["otherUserID"]}`,
                  "createdAt": new Date()});
          });
        });
  }
  sendCommentTest({newCommentInformation}) {
    const sendingUser = `${newCommentInformation["nameOfSendingUser"]}`;
    this.commentID = crypto.randomBytes(16).toString("hex");
    this.notificationID = crypto.randomBytes(16).toString("hex");
    const otherID = newCommentInformation["otherUserID"];
    console.log(`otherUserID = ${newCommentInformation["otherUserID"]}`);
    let commentInformation = {};
    if (newCommentInformation["photoLink"] != undefined) {
      commentInformation = {
        "sentBy": newCommentInformation["sentBy"],
        "comment": newCommentInformation["comment"],
        "photoLink": newCommentInformation["photoLink"],
        "updatedAt": new Date(),
        "time": new Date(),
      };
    } else if (newCommentInformation["videoUrl"] != undefined) {
      commentInformation = {
        "sentBy": newCommentInformation["sentBy"],
        "comment": newCommentInformation["comment"],
        "videoUrl": newCommentInformation["videoUrl"],
        "thumbnailUrl": newCommentInformation["thumbnailUrl"],
        "updatedAt": new Date(),
        "time": new Date(),
      };
    } else if (newCommentInformation["isGIF"] != false) {
      commentInformation = {
        "sentBy": newCommentInformation["sentBy"],
        "comment": newCommentInformation["comment"],
        "isGIF": newCommentInformation["isGIF"],
        "updatedAt": new Date(),
        "time": new Date(),
      };
    } else if (newCommentInformation["audioUrl"] != undefined) {
      commentInformation = {
        "sentBy": newCommentInformation["sentBy"],
        "comment": newCommentInformation["comment"],
        "audioUrl": newCommentInformation["audioUrl"],
        "updatedAt": new Date(),
        "time": new Date(),
      };
    } else {
      commentInformation = {
        "sentBy": newCommentInformation["sentBy"],
        "comment": newCommentInformation["comment"],
        "updatedAt": new Date(),
        "time": new Date(),
      };
    }
    return this.collection.doc(newCommentInformation["otherUserID"])
        .collection("UserPosts")
        .doc(newCommentInformation["postID"])
        .collection("Comments")
        .doc(`${newCommentInformation["commentID"]}`)
        .set(commentInformation)
        .then(() => {
          if (otherID != newCommentInformation["sentBy"]) {
            return this.secondCollection
                .doc(`${newCommentInformation["otherUserID"]}`)
                .collection("MyNotifications")
                .doc(`${this.notificationID}`)
                .set({
                  "id": `${this.notificationID}`,
                  "resourceID": `comment:${newCommentInformation["postID"]}`,
                  "sentFromUser": `${newCommentInformation["sentBy"]}`,
                  "originalAuthor": `${newCommentInformation["otherUserID"]}`,
                  "createdAt": new Date()})
          }
        })
        .then(() => {
          return this.collection.doc(newCommentInformation["otherUserID"])
              .collection("UserPosts")
              .doc(newCommentInformation["postID"])
              .set({
                "updatedAt": new Date()}, {merge: true});
        })
        .then(() => {
          newCommentInformation["friendsWhoCommented"].forEach((item) => {
            this.newNotificationID = crypto.randomBytes(16).toString("hex");
            return this.secondCollection
                .doc(item)
                .collection("MyNotifications")
                .doc(`${this.newNotificationID}`)
                .set({
                  "id": `${this.newNotificationID}`,
                  "resourceID": `alsoC:${newCommentInformation["postID"]}`,
                  "sentFromUser": `${newCommentInformation["sentBy"]}`,
                  "originalAuthor": `${newCommentInformation["otherUserID"]}`,
                  "createdAt": new Date()});
          });
        });
  }
  likeComment({newLikeInformation}) {
    const sendingUser = `${newLikeInformation["nameOfSendingUser"]}`;
    const message = {
      notification: {
        title: `speakEZ`,
        body: `${sendingUser} liked your comment`,
      },
      data: {
        type: "NEW_COMMENT_LIKE",
        authorId: newLikeInformation["postOwnerID"],
        postId: newLikeInformation["postID"],
        userID: newLikeInformation["sentBy"],
        postAuthorId: newLikeInformation["postOwnerID"],
      },
      apns: {
        headers: {
          "apns-priority": "10",
        },
        payload: {
          aps: {
            threadId: newLikeInformation["postID"],
          },
        },
      },
      token: `${newLikeInformation["token"]}`,
    };
    this.notificationID = crypto.randomBytes(16).toString("hex");
    return this.collection.doc(newLikeInformation["postOwnerID"])
        .collection("UserPosts")
        .doc(newLikeInformation["postID"])
        .collection("Comments")
        .doc(newLikeInformation["commentID"])
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
                "resourceID": `likedComment:${newLikeInformation["postID"]}`,
                "sentFromUser": `${newLikeInformation["sentBy"]}`,
                "nameOfSendingUser": newLikeInformation["nameOfSendingUser"],
                "originalAuthor": `${newLikeInformation["postOwnerID"]}`,
                "webLink": newLikeInformation["webLink"],
                "createdAt": new Date()});
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

  likeCommentReply({newLikeInformation}) {
    const sendingUser = `${newLikeInformation["nameOfSendingUser"]}`;
    const message = {
      notification: {
        body: `${sendingUser} liked your comment`,
      },
      token: `${newLikeInformation["token"]}`,
    };
    this.notificationID = crypto.randomBytes(16).toString("hex");
    return this.collection.doc(newLikeInformation["postOwnerID"])
        .collection("UserPosts")
        .doc(newLikeInformation["postID"])
        .collection("Comments")
        .doc(newLikeInformation["originalCommentID"])
        .collection("Comments")
        .doc(newLikeInformation["commentID"])
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
                "resourceID": `likedComment:${newLikeInformation["postID"]}`,
                "sentFromUser": `${newLikeInformation["sentBy"]}`,
                "nameOfSendingUser": newLikeInformation["nameOfSendingUser"],
                "originalAuthor": `${newLikeInformation["postOwnerID"]}`,
                "webLink": newLikeInformation["webLink"],
                "createdAt": new Date()});
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

  replyToComment({newCommentInformation}) {
    const sendingUser = `${newCommentInformation["nameOfSendingUser"]}`;
    const message = {
      notification: {
        body: `${sendingUser} replied to your comment`,
      },
      token: `${newCommentInformation["token"]}`,
    };
    const message2 = {
      notification: {
        body: `${sendingUser} replied to a comment on your moment`,
      },
      token: `${newCommentInformation["postOwnerToken"]}`,
    };
    this.notificationID = crypto.randomBytes(16).toString("hex");
    this.commentID = crypto.randomBytes(16).toString("hex");
    const otherID = newCommentInformation["otherUserID"];
    return this.collection.doc(newCommentInformation["postOwnerID"])
        .collection("UserPosts")
        .doc(newCommentInformation["postID"])
        .collection("Comments")
        .doc(newCommentInformation["commentID"])
        .collection("Comments")
        .doc(this.commentID)
        .set({
          "sentBy": newCommentInformation["sentBy"],
          "comment": newCommentInformation["comment"],
          "time": new Date()})
        .then(() => {
          if (otherID != newCommentInformation["sentBy"]) {
            // stops user from getting notification when replying to own comment
            const resource = `commentReply:${newCommentInformation["postID"]}`;
            const nameOfSending = newCommentInformation["nameOfSendingUser"];
            return this.secondCollection
                .doc(`${newCommentInformation["otherUserID"]}`)
                .collection("MyNotifications")
                .doc(`${this.notificationID}`)
                .set({
                  "id": `${this.notificationID}`,
                  "resourceID": resource,
                  "sentFromUser": `${newCommentInformation["sentBy"]}`,
                  "nameOfSendingUser": nameOfSending,
                  "originalAuthor": `${newCommentInformation["postOwnerID"]}`,
                  "webLink": newCommentInformation["webLink"],
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
          }
        })
        .then(() => {
          const originalOwner = newCommentInformation["postOwnerID"];
          const nameOfSendingUser = newCommentInformation["nameOfSendingUser"];
          if (originalOwner != newCommentInformation["sentBy"]) {
            // stops user from getting notification if they are post owner
            if (originalOwner != newCommentInformation["otherUserID"]) {
            /* stop double notification if the post owner
            is the person you are replying to */
              return this.secondCollection
                  .doc(`${newCommentInformation["postOwnerID"]}`)
                  .collection("MyNotifications")
                  .doc(`${this.notificationID}`)
                  .set({
                    "id": `${this.notificationID}`,
                    "resourceID": `comment:${newCommentInformation["postID"]}`,
                    "sentFromUser": `${newCommentInformation["sentBy"]}`,
                    "nameOfSendingUser": nameOfSendingUser,
                    "originalAuthor": `${newCommentInformation["postOwnerID"]}`,
                    "webLink": newCommentInformation["webLink"],
                    "createdAt": new Date()})
                  .then(() => {
                    admin.messaging().send(message2)
                        .then((response) => {
                          // Response is a message ID string.
                          console.log("Successfully sent message:", response);
                        })
                        .catch((error) => {
                          console.log("Error sending message:", error);
                        });
                  });
            }
          }
        })
        .then(() => {
          newCommentInformation["friendsWhoCommented"].forEach((item) => {
            this.newNotificationID = crypto.randomBytes(16).toString("hex");
            return this.secondCollection
                .doc(item)
                .collection("MyNotifications")
                .doc(`${this.newNotificationID}`)
                .set({
                  "id": `${this.newNotificationID}`,
                  "resourceID": `alsoC:${newCommentInformation["postID"]}`,
                  "sentFromUser": `${newCommentInformation["sentBy"]}`,
                  "originalAuthor": `${newCommentInformation["postOwnerID"]}`,
                  "createdAt": new Date()});
          });
        });
  }
  deleteComment({newCommentInformation}) {
    return this.collection.doc(newCommentInformation["postOwnerID"])
        .collection("UserPosts")
        .doc(newCommentInformation["postID"])
        .collection("Comments")
        .doc(newCommentInformation["commentID"])
        .collection("Comments")
        .get()
        .then((res) => {
          res.forEach((element) => {
            element.ref.delete();
          });
        }).then(() => {
          return this.collection.doc(newCommentInformation["postOwnerID"])
              .collection("UserPosts")
              .doc(newCommentInformation["postID"])
              .collection("Comments")
              .doc(newCommentInformation["commentID"])
              .set({
                "isDeleted": true}, {merge: true})
              .then(() => {
              return this.collection.doc(newCommentInformation["postOwnerID"])
                  .collection("UserPosts")
                  .doc(newCommentInformation["postID"])
                  .collection("Comments")
                  .doc(newCommentInformation["commentID"]).delete();
                  });
        })

  }
  deleteCommentReply({newCommentInformation}) {
    return this.collection.doc(newCommentInformation["postOwnerID"])
        .collection("UserPosts")
        .doc(newCommentInformation["postID"])
        .collection("Comments")
        .doc(newCommentInformation["ogCommentID"])
        .collection("Comments")
        .doc(newCommentInformation["commentReplyID"]).delete();
  }
  subscribeToPost({newPostInformation}) {
    const postID = {};
    postID[newPostInformation["postID"]] = newPostInformation["originalAuthor"];
    return this.thirdCollection.doc(newPostInformation["currentUser"])
    .set(postID, {merge: true})
  }
  unsubscribeToPost({newPostInformation}) {
    const postID = {};
    postID[newPostInformation["postID"]] = deleteField();
    return this.thirdCollection.doc(newPostInformation["currentUser"])
    .update(postID);
  }
}

const sendComment = new CommentService();
module.exports = sendComment;
