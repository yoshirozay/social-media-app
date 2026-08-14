/* eslint-disable require-jsdoc */
// const {DB, bucket} = require("./Firestore");
const {DB} = require("./Firestore");
const admin = require("firebase-admin");

class MentionService {
  constructor() {
    this.collection = DB.collection("Notifications");
  }
  /**
     * Creates a new notification for mentioned users
     * @param {string} sentBy The user who sent the post
     * @param {string} sentTo The user who was mentioned
     * @return {any} The firestore response
     */
  postMention({newMentionInformation}) {
    console.log(`resourceID = ${newMentionInformation["resourceID"]}`);
    console.log(`newMentionInfo = ${newMentionInformation}`);
    const sendingUser = `${newMentionInformation["nameOfSendingUser"]}`;
    const message = {
      notification: {
        title: `speakEZ`,
        body: `${sendingUser} mentioned you in a Moment`,
      },
      data: {
        type: "NEW_POST_MENTION",
        authorId: newMentionInformation["sentBy"] || "",
        postAuthorId: newMentionInformation["sentBy"] || "",
        userID: newMentionInformation["sentBy"] || "",
        postId: newMentionInformation["resourceID"] || "",
      },
      apns: {
        headers: {
            'apns-priority': '10',
        },
        payload: {
            aps: {
              threadId: newMentionInformation["resourceID"] || "",
              sound: 'default',
            }
        },
    },
      token: `${newMentionInformation["token"]}`,
    };
    let mentionInformation = {};
    mentionInformation = {
      "id": newMentionInformation["id"],
      "resourceID": `postMention:${newMentionInformation["resourceID"]}`,
      "sentFromUser": `${newMentionInformation["sentBy"]}`,
      "originalAuthor": `${newMentionInformation["sentBy"]}`,
      "createdAt": new Date(),
    };
    return this.collection.doc(newMentionInformation["sentTo"])
        .collection("MyNotifications")
        .doc(`${newMentionInformation["id"]}`)
        .set(mentionInformation)
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
  commentMention({newMentionInformation}) {
    console.log(`resourceID = ${newMentionInformation["resourceID"]}`);
    const sendingUser = `${newMentionInformation["nameOfSendingUser"]}`;
    const message = {
      notification: {
        title: `speakEZ`,
        body: `${sendingUser} mentioned you in a comment`,
      },
      data: {
        type: "NEW_COMMENT_MENTION",
        authorId: newMentionInformation["originalAuthor"] || "",
        postAuthorId: newMentionInformation["originalAuthor"] || "",
        userID: newMentionInformation["sentBy"] || "",
        postId: newMentionInformation["resourceID"] || "",
      },
      apns: {
        headers: {
            'apns-priority': '10',
        },
        payload: {
            aps: {
                sound: 'default',
                threadId: newMentionInformation["resourceID"] || "",
            }
        },
    },
      token: `${newMentionInformation["token"]}`,
    };
    let mentionInformation = {};
    mentionInformation = {
      "id": newMentionInformation["id"],
      "resourceID": `commentMention:${newMentionInformation["resourceID"]}`,
      "sentFromUser": `${newMentionInformation["sentBy"]}`,
      "originalAuthor": `${newMentionInformation["originalAuthor"]}`,
      "createdAt": new Date(),
    };
    return this.collection.doc(newMentionInformation["sentTo"])
        .collection("MyNotifications")
        .doc(`${newMentionInformation["id"]}`)
        .set(mentionInformation)
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
}

const postMention = new MentionService();
module.exports = postMention;
