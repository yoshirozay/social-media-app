/* eslint-disable indent */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {
  getUserToken,
} = require("../../helpers/functions");
const { user } = require("firebase-functions/lib/providers/auth");

exports.eventInvitationNotification = functions.firestore
  .document("EventInvitations/{userID}/InvitedEvents/{eventID}")
  .onWrite((change, context) => {
    const data = change.after.data();
    const nameOfSendingUser = data.nameOfSendingUser
    const eventName = data.eventName
    console.log(`eventName = ${eventName}`);
    const sentTo = context.params.userID;
    const eventID = data.eventID
    const sentBy = data.sentBy
    console.log(`eventID = ${eventID}`);
    
    return getUserToken(sentTo)
      .then((user) => {
        const message = {
          notification: {
            title: `${eventName}`,
            body: `${nameOfSendingUser} invited you to an event!`,
          },
          data: {
            type: "NEW_EVENT",
            eventID: eventID || "",
            authorId: sentBy || "",
          },
          apns: {
            headers: {
                'apns-priority': '10',
            },
            payload: {
                aps: {
                    threadId: eventID,
                    sound: 'default',
                }
            },
        },
          token: user
        };
        admin.messaging().send(message)
        .then((response) => {
          // Response is a message ID string.
          console.log("Successfully sent message:", response);
        })
        .catch((error) => {
          console.log("Error sending message:", error);
        });
      })
  })