/* eslint-disable require-jsdoc */
// const {DB, bucket} = require("./Firestore");
const {DB} = require("./Firestore");
const admin = require("firebase-admin");
const crypto = require("crypto");
function getMessageNotificationBody(name, message) {
  if (
    message["videoUrl"] != undefined
    ) {
    return `Sent a video`;
  } 
  else if (
    message["photoLink"] != undefined
  ) {
    return `Sent a photo`;
  } else if (
    message["isGIF"] === true
    ) {
    return `Sent a GIF`;
  } else if (
    message["audioUrl"] != undefined
  ) {
    return `Sent an audio message`;
  } else {
  return `${message.message}`;
  }
}
class MessageService {
  constructor() {
    this.firstCollection = DB.collection("ChatMessages");
    this.secondCollection = DB.collection("Chats");
    this.thirdCollection = DB.collection("UserChats");
  }
  /**
     * Sends a new message.
     * @param {string} sentBy The user who sent the message
     * @param {string} message The content of the message
     * @param {string} time The time the message was sent
     * @param {string} chatUID The ID of the users conversation
     * @param {string} otherUserID The ID of the other user in the conversation
     * @return {any} The firestore response
     */
  send({newMessageInformation}) {
    const name = newMessageInformation["nameOfSendingUser"]
    const messageData = newMessageInformation
    const message = {
      notification: {
        title: `${newMessageInformation["nameOfSendingUser"]}`,
        body: getMessageNotificationBody(name, messageData),
        // body: `${newMessageInformation["message"]}`,
      },
      data: {
        type: "NEW_PRIVATE_MESSAGE",
        chatId: newMessageInformation["chatUID"],
        messageId: newMessageInformation["messageUID"] || "",
        authorId: newMessageInformation["sentBy"] || "",
        notificationBody: newMessageInformation["message"] || "",
      },
      apns: {
        headers: {
            'apns-priority': '10',
        },
        payload: {
            aps: {
                threadId: newMessageInformation["chatUID"],
                sound: 'default',
            }
        },
    },
      token: `${newMessageInformation["token"]}`,
    };
    console.log(`chatUID = ${newMessageInformation["chatUID"]}`);
    console.log(`sentBy = ${newMessageInformation["sentBy"]}`);
    console.log(`VIDEOURL = ${newMessageInformation["videoUrl"]}`);
    let messageInformation = {};
    if (newMessageInformation["photoLink"] != undefined) {
      messageInformation = {
        "sentBy": newMessageInformation["sentBy"],
        "message": newMessageInformation["message"],
        "photoLink": newMessageInformation["photoLink"],
        "time": new Date(),
      };
    } else if (newMessageInformation["videoUrl"] != undefined) {
      messageInformation = {
        "sentBy": newMessageInformation["sentBy"],
        "message": newMessageInformation["message"],
        "videoUrl": newMessageInformation["videoUrl"],
        "thumbnailUrl": newMessageInformation["thumbnailUrl"],
        "time": new Date(),
      };
    } else if (newMessageInformation["isGIF"] != false)  {
      messageInformation = {
        "sentBy": newMessageInformation["sentBy"],
        "message": newMessageInformation["message"],
        "isGIF": newMessageInformation["isGIF"],
        "time": new Date(),
      };
    } else if (newMessageInformation["audioUrl"] != undefined)  {
      messageInformation = {
        "sentBy": newMessageInformation["sentBy"],
        "audioUrl": newMessageInformation["audioUrl"],
        "message": newMessageInformation["message"],
        "time": new Date(),
      };
    } else {
      messageInformation = {
        "sentBy": newMessageInformation["sentBy"],
        "message": newMessageInformation["message"],
        "time": new Date(),
      };
    }
    return this.firstCollection.doc(newMessageInformation["chatUID"])
        .collection("ChatMessagess")
        .doc(`${newMessageInformation["messageUID"]}`)
        .set(messageInformation)
        .then(() => {
          return this.secondCollection.doc(newMessageInformation["chatUID"])
              .set({
                "lastMessageSentUUID": `${newMessageInformation["messageUID"]}`,
                "members": [newMessageInformation["sentBy"],
                  newMessageInformation["otherUserID"]],
                "sentBy": newMessageInformation["sentBy"],
              })
              .then(() => {
                return this.thirdCollection
                    .doc(`${newMessageInformation["otherUserID"]}`)
                    .collection("UserChatss")
                    .doc(newMessageInformation["chatUID"])
                    .set({
                      "newMessage": true}, {merge: true});
              })
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
  create({newMessageInformation}) {
    const message = {
      notification: {
        title: `${newMessageInformation["nameOfSendingUser"]}`,
        body: `${newMessageInformation["message"]}`,
      },
      token: `${newMessageInformation["token"]}`,
    };
    let messageInformation = {};
    if (newMessageInformation["photoLink"] != undefined) {
      messageInformation = {
        "sentBy": newMessageInformation["sentBy"],
        "message": newMessageInformation["message"],
        "photoLink": newMessageInformation["photoLink"],
        "time": new Date(),
      };
    } else if (newMessageInformation["videoUrl"] != undefined) {
      messageInformation = {
        "sentBy": newMessageInformation["sentBy"],
        "message": newMessageInformation["message"],
        "videoUrl": newMessageInformation["videoUrl"],
        "thumbnailUrl": newMessageInformation["thumbnailUrl"],
        "time": new Date(),
      };
    } else {
      messageInformation = {
        "sentBy": newMessageInformation["sentBy"],
        "message": newMessageInformation["message"],
        "time": new Date(),
      };
    }
    console.log(`chatUID = ${newMessageInformation["chatUID"]}`);
    console.log(`sentBy = ${newMessageInformation["sentBy"]}`);
    return this.firstCollection.doc(newMessageInformation["chatUID"])
        .collection("ChatMessagess")
        .doc(`${newMessageInformation["messageUID"]}`)
        .set(messageInformation)
        .then(() => {
          return this.secondCollection.doc(newMessageInformation["chatUID"])
              .set({
                "lastMessageSentUUID": `${newMessageInformation["messageUID"]}`,
                "members": [newMessageInformation["sentBy"],
                  newMessageInformation["otherUserID"]],
                "sentBy": newMessageInformation["sentBy"],
              })
              .then(() => {
                return this.thirdCollection
                    .doc(`${newMessageInformation["otherUserID"]}`)
                    .collection("UserChatss")
                    .doc(newMessageInformation["chatUID"])
                    .set({
                      "user": newMessageInformation["sentBy"],
                      "time": new Date()}, {merge: true});
              })
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
  read({newMessageInformation}) {
    return this.thirdCollection
        .doc(`${newMessageInformation["currentUser"]}`)
        .collection("UserChatss")
        .doc(newMessageInformation["chatUID"])
        .set({
          "newMessage": false}, {merge: true});
  }

  likeMessage({newLikeInformation}) {
    const message = {
      notification: {
        title: `${newLikeInformation["nameOfSendingUser"]}`,
        body: `${newLikeInformation["nameOfSendingUser"]} liked your message`,
      },
      data: {
        type: "NEW_PRIVATE_MESSAGE",
        chatId: newLikeInformation["chatUID"],
      },
      token: `${newLikeInformation["token"]}`,
    };
    console.log(`sendingUser = ${newLikeInformation["nameOfSendingUser"]}`);
    console.log(`sentBy = ${newLikeInformation["sentBy"]}`);
    console.log(`token = ${newLikeInformation["token"]}`);
    this.notificationID = crypto.randomBytes(16).toString("hex");
    return this.firstCollection.doc(newLikeInformation["chatUID"])
        .collection("ChatMessagess")
        .doc(newLikeInformation["messageID"])
        .set({
          "hasBeenLiked": true}, {merge: true})
        .then(() => {
          return this.thirdCollection
              .doc(`${newLikeInformation["otherUserID"]}`)
              .collection("UserChatss")
              .doc(newLikeInformation["chatUID"])
              .set({
                "user": newLikeInformation["sentBy"],
                "newMessage": true,
                "time": new Date()}, {merge: true});
        })
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
  sendViewOnceMessage({newMessageInformation}) {
    const message = {
      notification: {
        title: `${newMessageInformation["nameOfSendingUser"]}`,
        body: `${newMessageInformation["message"]}`,
      },
      token: `${newMessageInformation["token"]}`,
    };
    console.log(`chatUID = ${newMessageInformation["chatUID"]}`);
    console.log(`sentBy = ${newMessageInformation["sentBy"]}`);
    console.log(`VIDEOURL = ${newMessageInformation["videoUrl"]}`);
    let messageInformation = {};
    if (newMessageInformation["photoLink"] != undefined) {
      messageInformation = {
        "sentBy": newMessageInformation["sentBy"],
        "message": newMessageInformation["message"],
        "photoLink": newMessageInformation["photoLink"],
        "alreadyViewOnce": newMessageInformation["alreadyViewOnce"],
        "time": new Date(),
      };
    } else if (newMessageInformation["videoUrl"] != undefined) {
      messageInformation = {
        "sentBy": newMessageInformation["sentBy"],
        "message": newMessageInformation["message"],
        "videoUrl": newMessageInformation["videoUrl"],
        "thumbnailUrl": newMessageInformation["thumbnailUrl"],
        "alreadyViewOnce": newMessageInformation["alreadyViewOnce"],
        "time": new Date(),
      };
    } else {
      messageInformation = {
        "sentBy": newMessageInformation["sentBy"],
        "message": newMessageInformation["message"],
        "alreadyViewOnce": newMessageInformation["alreadyViewOnce"],
        "time": new Date(),
      };
    }
    return this.firstCollection.doc(newMessageInformation["chatUID"])
        .collection("ChatMessagess")
        .doc(`${newMessageInformation["messageUID"]}`)
        .set(messageInformation)
        .then(() => {
          return this.secondCollection.doc(newMessageInformation["chatUID"])
              .set({
                "lastMessageSentUUID": `${newMessageInformation["messageUID"]}`,
                "members": [newMessageInformation["sentBy"],
                  newMessageInformation["otherUserID"]],
                "sentBy": newMessageInformation["sentBy"],
              })
              .then(() => {
                return this.thirdCollection
                    .doc(`${newMessageInformation["otherUserID"]}`)
                    .collection("UserChatss")
                    .doc(newMessageInformation["chatUID"])
                    .set({
                      "newMessage": true}, {merge: true});
              })
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
  createViewOnce({newMessageInformation}) {
    const message = {
      notification: {
        title: `${newMessageInformation["nameOfSendingUser"]}`,
        body: `${newMessageInformation["message"]}`,
      },
      token: `${newMessageInformation["token"]}`,
    };
    let messageInformation = {};
    if (newMessageInformation["photoLink"] != undefined) {
      messageInformation = {
        "sentBy": newMessageInformation["sentBy"],
        "message": newMessageInformation["message"],
        "photoLink": newMessageInformation["photoLink"],
        "alreadyViewOnce": newMessageInformation["alreadyViewOnce"],
        "time": new Date(),
      };
    } else if (newMessageInformation["videoUrl"] != undefined) {
      messageInformation = {
        "sentBy": newMessageInformation["sentBy"],
        "message": newMessageInformation["message"],
        "videoUrl": newMessageInformation["videoUrl"],
        "thumbnailUrl": newMessageInformation["thumbnailUrl"],
        "alreadyViewOnce": newMessageInformation["alreadyViewOnce"],
        "time": new Date(),
      };
    } else {
      messageInformation = {
        "sentBy": newMessageInformation["sentBy"],
        "message": newMessageInformation["message"],
        "alreadyViewOnce": newMessageInformation["alreadyViewOnce"],
        "time": new Date(),
      };
    }
    console.log(`chatUID = ${newMessageInformation["chatUID"]}`);
    console.log(`sentBy = ${newMessageInformation["sentBy"]}`);
    return this.firstCollection.doc(newMessageInformation["chatUID"])
        .collection("ChatMessagess")
        .doc(`${newMessageInformation["messageUID"]}`)
        .set(messageInformation)
        .then(() => {
          return this.secondCollection.doc(newMessageInformation["chatUID"])
              .set({
                "lastMessageSentUUID": `${newMessageInformation["messageUID"]}`,
                "members": [newMessageInformation["sentBy"],
                  newMessageInformation["otherUserID"]],
                "sentBy": newMessageInformation["sentBy"],
              })
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
  didTakeScreenshot({newMessageInformation}) {
    let messageInformation = {};
      messageInformation = {
        "didTakeScreenShot": newMessageInformation["didTakeScreenShot"],
      };
    return this.firstCollection.doc(newMessageInformation["chatUID"])
        .collection("ChatMessagess")
        .doc(`${newMessageInformation["messageUID"]}`)
        .set(messageInformation, {merge: true});
  }
  didViewMessage({newMessageInformation}) {
    let messageInformation = {};
      messageInformation = {
        "alreadyViewOnce": newMessageInformation["alreadyViewOnce"],
      };
    return this.firstCollection.doc(newMessageInformation["chatUID"])
        .collection("ChatMessagess")
        .doc(`${newMessageInformation["messageUID"]}`)
        .set(messageInformation, {merge: true});
  }
  createUserChat({newMessageInformation}) {
    return this.thirdCollection
        .doc(newMessageInformation["currentUser"])
        .collection("UserChatss")
        .doc(newMessageInformation["chatUID"])
        .set({
          "user": newMessageInformation["otherUserID"],
          "time": new Date()}, {merge: true})
        .then(() => {
          return this.thirdCollection
              .doc(newMessageInformation["otherUserID"])
              .collection("UserChatss")
              .doc(newMessageInformation["chatUID"])
              .set({
                "user": newMessageInformation["currentUser"],
                "time": new Date()}, {merge: true});
        });
  };
  createGroupUserChat({newMessageInformation}) {
    console.log(`USERS2 = ${newMessageInformation["users"]}`);
    console.log(`CURRENT USER = ${newMessageInformation["currentUser"]}`);
    console.log(`CHATUID = ${newMessageInformation["chatUID"]}`);
    return this.thirdCollection
        .doc(newMessageInformation["currentUser"])
        .collection("UserChatss")
        .doc(newMessageInformation["chatUID"])
        .set({
          "groupChat": true,
          "name": newMessageInformation["name"],
          "users": newMessageInformation["users"],
          "time": new Date()}, {merge: true})
  };
  sendGroupMessage({newMessageInformation}) {
    console.log(`chatUID = ${newMessageInformation["chatUID"]}`);
    console.log(`sentBy = ${newMessageInformation["sentBy"]}`);
    console.log(`VIDEOURL = ${newMessageInformation["videoUrl"]}`);
    let messageInformation = {};
    if (newMessageInformation["photoLink"] != undefined) {
      messageInformation = {
        "sentBy": newMessageInformation["sentBy"],
        "message": newMessageInformation["message"],
        "photoLink": newMessageInformation["photoLink"],
        "groupName": newMessageInformation["groupName"],
        "nameOfSendingUser": newMessageInformation["nameOfSendingUser"],
        "time": new Date(),
      };
    } else if (newMessageInformation["videoUrl"] != undefined) {
      messageInformation = {
        "sentBy": newMessageInformation["sentBy"],
        "message": newMessageInformation["message"],
        "videoUrl": newMessageInformation["videoUrl"],
        "thumbnailUrl": newMessageInformation["thumbnailUrl"],
        "groupName": newMessageInformation["groupName"],
        "nameOfSendingUser": newMessageInformation["nameOfSendingUser"],
        "time": new Date(),
      };
    } else if (newMessageInformation["isGIF"] != false)  { 
      messageInformation = {
        "sentBy": newMessageInformation["sentBy"],
        "message": newMessageInformation["message"],
        "groupName": newMessageInformation["groupName"],
        "nameOfSendingUser": newMessageInformation["nameOfSendingUser"],
        "isGIF": newMessageInformation["isGIF"],
        "time": new Date(),
      };
    } else if (newMessageInformation["audioUrl"] != undefined)  {
      messageInformation = {
        "sentBy": newMessageInformation["sentBy"],
        "audioUrl": newMessageInformation["audioUrl"],
        "message": newMessageInformation["message"],
        "groupName": newMessageInformation["groupName"],
        "nameOfSendingUser": newMessageInformation["nameOfSendingUser"],
        "time": new Date(),
      };
    } else {
      messageInformation = {
        "sentBy": newMessageInformation["sentBy"],
        "message": newMessageInformation["message"],
        "groupName": newMessageInformation["groupName"],
        "nameOfSendingUser": newMessageInformation["nameOfSendingUser"],
        "time": new Date(),
      };
    }
    return this.firstCollection.doc(newMessageInformation["chatUID"])
        .collection("ChatMessagess")
        .doc(`${newMessageInformation["messageUID"]}`)
        .set(messageInformation)
        .then(() => {
          return this.secondCollection.doc(newMessageInformation["chatUID"])
              .set({
                "lastMessageSentUUID": `${newMessageInformation["messageUID"]}`,
                "sentBy": newMessageInformation["sentBy"],
              })
              // .then(() => {
              //   return this.thirdCollection
              //       .doc(`${newMessageInformation["otherUserID"]}`)
              //       .collection("UserChatss")
              //       .doc(newMessageInformation["chatUID"])
              //       .set({
              //         "newMessage": true}, {merge: true});
              // })
        });
  }
  leaveGroupChat({newMessageInformation}) {
    return this.thirdCollection
        .doc(newMessageInformation["currentUser"])
        .collection("UserChatss")
        .doc(newMessageInformation["chatUID"])
        .delete()
        .then(() => {
          newMessageInformation["users"].forEach((item) => {
            return this.thirdCollection
            .doc(item)
            .collection("UserChatss")
            .doc(newMessageInformation["chatUID"])
            .set({
              "usersWhoLeft": newMessageInformation["usersWhoLeft"],
              "users": newMessageInformation["users"]
            }, {merge: true})
          });
        });
  }
  updateGroupChatName({newMessageInformation}) {
    return this.thirdCollection
    .doc(newMessageInformation["currentUser"])
    .collection("UserChatss")
    .doc(newMessageInformation["chatUID"])
    .update({
      "name": newMessageInformation["name"]
    }, {merge: true})
  }
  addUsersToGroupChat({newMessageInformation}) {
    return this.thirdCollection
    .doc(newMessageInformation["currentUser"])
    .collection("UserChatss")
    .doc(newMessageInformation["chatUID"])
    .set({
      "groupChat": true,
      "name": newMessageInformation["name"],
      "users": newMessageInformation["users"],
      "time": new Date()}, {merge: true})
  }
  sendViewOnceGroup({newMessageInformation}) {
    console.log(`chatUID = ${newMessageInformation["chatUID"]}`);
    console.log(`sentBy = ${newMessageInformation["sentBy"]}`);
    console.log(`VIDEOURL = ${newMessageInformation["videoUrl"]}`);
    let messageInformation = {};
    if (newMessageInformation["photoLink"] != undefined) {
      messageInformation = {
        "sentBy": newMessageInformation["sentBy"],
        "message": newMessageInformation["message"],
        "photoLink": newMessageInformation["photoLink"],
        "alreadyViewOnce": newMessageInformation["alreadyViewOnce"],
        "groupName": newMessageInformation["groupName"],
        "nameOfSendingUser": newMessageInformation["nameOfSendingUser"],
        "time": new Date(),
      };
    } else if (newMessageInformation["videoUrl"] != undefined) {
      messageInformation = {
        "sentBy": newMessageInformation["sentBy"],
        "message": newMessageInformation["message"],
        "videoUrl": newMessageInformation["videoUrl"],
        "thumbnailUrl": newMessageInformation["thumbnailUrl"],
        "alreadyViewOnce": newMessageInformation["alreadyViewOnce"],
        "groupName": newMessageInformation["groupName"],
        "nameOfSendingUser": newMessageInformation["nameOfSendingUser"],
        "time": new Date(),
      };
    } else {
      messageInformation = {
        "sentBy": newMessageInformation["sentBy"],
        "message": newMessageInformation["message"],
        "alreadyViewOnce": newMessageInformation["alreadyViewOnce"],
        "groupName": newMessageInformation["groupName"],
        "nameOfSendingUser": newMessageInformation["nameOfSendingUser"],
        "time": new Date(),
      };
    }
    return this.firstCollection.doc(newMessageInformation["chatUID"])
        .collection("ChatMessagess")
        .doc(`${newMessageInformation["messageUID"]}`)
        .set(messageInformation)
        .then(() => {
          return this.secondCollection.doc(newMessageInformation["chatUID"])
              .set({
                "lastMessageSentUUID": `${newMessageInformation["messageUID"]}`,
                "sentBy": newMessageInformation["sentBy"],
              })
        });
  }
  isTypingInOC({newMessageInformation}) {
    function deleteTypingUser(newMessageInformation) {
      return new Promise((resolve, reject) => {
        DB.collection("UserChats")
          .doc(newMessageInformation["otherUser"])
          .collection("UserChatss")
          .doc(newMessageInformation["chatUID"])
          .collection("IsTyping")
          .doc(newMessageInformation["typingUser"])
          .delete()
          .then(() => {
            resolve();
          })
          .catch((e) => {
            reject(e);
          });
      });
    }
    return this.thirdCollection
      .doc(newMessageInformation["otherUser"])
      .collection("UserChatss")
      .doc(newMessageInformation["chatUID"])
      .collection("IsTyping")
      .doc(newMessageInformation["typingUser"])
      .set({
        "typingUser": newMessageInformation["typingUser"],
        "time": new Date()}, {merge: true})
      .then(() => {
        setTimeout(deleteTypingUser, 15000, newMessageInformation);
      });
  }
  isNotTypingInOC({newMessageInformation}) {
    return this.thirdCollection
      .doc(newMessageInformation["otherUser"])
      .collection("UserChatss")
      .doc(newMessageInformation["chatUID"])
      .collection("IsTyping")
      .doc(newMessageInformation["typingUser"]).delete()
  }
  isTypingInGC({newMessageInformation}) {
    function deleteTypingUser(newMessageInformation) {
      return new Promise((resolve, reject) => {
        DB.collection("UserChats")
          .doc(newMessageInformation["otherUser"])
          .collection("UserChatss")
          .doc(newMessageInformation["chatUID"])
          .collection("IsTyping")
          .doc(newMessageInformation["typingUser"])
          .delete()
          .then(() => {
            resolve();
          })
          .catch((e) => {
            reject(e);
          });
      });
    }
    return this.thirdCollection
      .doc(newMessageInformation["otherUser"])
      .collection("UserChatss")
      .doc(newMessageInformation["chatUID"])
      .collection("IsTyping")
      .doc(newMessageInformation["typingUser"])
      .set({
        "typingUser": newMessageInformation["typingUser"],
        "time": new Date()}, {merge: true})
      .then(() => {
        setTimeout(deleteTypingUser, 15000, newMessageInformation);
      });
  }
  isNotTypingInGC({newMessageInformation}) {
    return this.thirdCollection
      .doc(newMessageInformation["otherUser"])
      .collection("UserChatss")
      .doc(newMessageInformation["chatUID"])
      .collection("IsTyping")
      .doc(newMessageInformation["typingUser"]).delete()
  }
}

const sendMessage = new MessageService();
module.exports = sendMessage;
