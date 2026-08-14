/* eslint-disable require-jsdoc */
// const {DB, bucket} = require("./Firestore");
const {DB} = require("./Firestore");
const crypto = require("crypto");
const admin = require("firebase-admin");
async function sendNotificationToHostIDs(event, getUserToken) {
  const snapshot = await DB.collection("AllEvents").doc(event["eventID"])
  .collection("Hosts")
  .get()
  if (snapshot.empty) {
    console.log('No matching documents.');
    return;
  }
  snapshot.forEach(doc => {
    return getUserToken(doc.id)
      .then((user) => {
        console.log(`token = ${user}`);
        const message = {
          notification: {
            title: `${event["eventName"]}`,
            body: `${event["nameOfSendingUser"]} wants to attend your event`,
          },
          data: {
            type: "NEW_EVENT",
            eventID: event["eventID"]|| "",
            authorId: event["userID"] || "",
          },
          apns: {
            headers: {
                'apns-priority': '10',
            },
            payload: {
                aps: {
                    threadId: event["eventID"],
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

}
async function sendNotificationToAttendingUsers(event, notificationBody, getUserToken) {
  const snapshot = await DB.collection("AllEvents").doc(event["eventID"])
  .collection("AttendingUsers")
  .get()
  if (snapshot.empty) {
    console.log('No matching documents.');
    return;
  }
  snapshot.forEach(doc => {
    return getUserToken(doc.id)
      .then((user) => {
        console.log(`token = ${user}`);
        const message = {
          notification: {
            title: `${event["eventName"]}`,
            // body: `The event was cancelled.`,
            body: `${notificationBody}`,
          },
          apns: {
            headers: {
                'apns-priority': '10',
            },
            payload: {
                aps: {
                    threadId: event["eventID"],
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

}
function getMessageNotificationBody(name, message) {
  if (
    message["videoUrl"] != undefined
    ) {
    return `${name} sent a video`;
  } 
  else if (
    message["photoLink"] != undefined
  ) {
    return `${name} sent a photo`;
  } else if (
    message["isGIF"] === true
    ) {
    return `${name} sent a GIF`;
  } else if (
    message["audioUrl"] != undefined
  ) {
    return `${name} sent an audio message`;
  } else {
  return `${name}: ${message.message}`;
  }
}
class EventService {
  constructor() {
    this.collection = DB.collection("MyEvents");
    this.secondCollection = DB.collection("AllEvents");
    this.thirdCollection = DB.collection("EventInvitations");
  }
  
  createEvent({newEventInformation}) {
    const startTime = new Date(newEventInformation["eventTimeStart"])
    const currentTime = new Date();
    const oneDayCheck = startTime.setSeconds(startTime.getSeconds() - 60 * 60 * 24);
    const oneDayDateObj = new Date(oneDayCheck);
    let firstNotification = false
    if (oneDayDateObj < currentTime) {
      firstNotification = true
    }
      return this.secondCollection.doc(newEventInformation["eventID"])
          .set({
            "createdBy": newEventInformation["createdBy"],
            "eventID": newEventInformation["eventID"],
            "eventName": newEventInformation["eventName"],
            "eventDescription": newEventInformation["eventDescription"],
            "eventTimeStart":  new Date(newEventInformation["eventTimeStart"]),
            "location": newEventInformation["location"],
            "firstNotification": firstNotification,
            "secondNotification": false,
            "hasCompleted": false,
            "createdAt": new Date()})
          .then(() => {
            newEventInformation["hostIDs"].forEach((item) => {
            return this.secondCollection.doc(newEventInformation["eventID"])
                .collection("AttendingUsers")
                .doc(item)
                .set({
                  "userID": newEventInformation["createdBy"],
                  "invitedBy": newEventInformation["createdBy"],
                  "eventID": newEventInformation["eventID"]
                })
              })
          })
          .then(() => {
            newEventInformation["hostIDs"].forEach((item) => {
              return this.secondCollection.doc(newEventInformation["eventID"])
                  .collection("Hosts")
                  .doc(item)
                  .set({
                    "eventID": newEventInformation["eventID"],
                    "host": true
                  })
            })
          })
          .then(() => {
            newEventInformation["hostIDs"].forEach((item) => {
              return this.collection.doc(item)
                  .collection("Events")
                  .doc(newEventInformation["eventID"])
                  .set({
                    "eventID": newEventInformation["eventID"],
                    "attending": true,
                    "host": true
                  })
            })
          })
          .then(() => {
            newEventInformation["invitedUsers"].forEach((item) => {
              return this.thirdCollection.doc(item)
                  .collection("InvitedEvents")
                  .doc(newEventInformation["eventID"])
                  .set({
                    "eventID": newEventInformation["eventID"],
                    "sentBy": newEventInformation["createdBy"],
                    "nameOfSendingUser": newEventInformation["nameOfSendingUser"],
                    "eventName": newEventInformation["eventName"],
                    "sentAt": new Date()})
            })
          })
            .then(() => {
              newEventInformation["invitedUsers"].forEach((item) => {
                return this.secondCollection.doc(newEventInformation["eventID"])
                    .collection("InvitedUsers")
                    .doc(item)
                    .set({
                    "userID": item,
                    "invitedBy": newEventInformation["createdBy"],
                    "eventID": newEventInformation["eventID"]
                    })
              })
            })
          .then(() => {
              return this.secondCollection.doc(newEventInformation["eventID"])
                  .collection("EventConversation")
                  .doc(newEventInformation["conversationID"])
                  .set({"conversationID":newEventInformation["conversationID"]})
          });
  }
  addEventHost({newEventInformation}){
    return this.secondCollection.doc(newEventInformation["eventID"])
        .collection("Hosts")
        .doc(newEventInformation["userID"])
        .set({
          "eventID": newEventInformation["eventID"],
          "host": true
        })
        .then(() => {
            return this.collection.doc(newEventInformation["userID"])
                .collection("Events")
                .doc(newEventInformation["eventID"])
                .set({
                  "eventID": newEventInformation["eventID"],
                  "host": true
                })
        })
        .then(() => {
          const message = {
            notification: {
              title: `${newEventInformation["eventName"]}`,
              body: `${newEventInformation["nameOfSendingUser"]} made you a Host!`,
            },
            data: {
              type: "NEW_EVENT",
              eventID: newEventInformation["eventID"],
              authorId: newEventInformation["userID"] || "",
            },
            apns: {
              headers: {
                  'apns-priority': '10',
              },
              payload: {
                  aps: {
                      threadId: newEventInformation["eventID"],
                      sound: 'default',
                  }
              },
          },
            token: newEventInformation["token"]
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
  }
  sendEventInvitation({newEventInformation}){
    return this.thirdCollection.doc(newEventInformation["userID"])
        .collection("InvitedEvents")
        .doc(newEventInformation["eventID"])
        .set({
          "eventID": newEventInformation["eventID"],
          "sentBy": newEventInformation["sentBy"],
          "nameOfSendingUser": newEventInformation["nameOfSendingUser"],
          "eventName": newEventInformation["eventName"],
          "sentAt": new Date()})
        .then(() => {
          return this.secondCollection.doc(newEventInformation["eventID"])
              .collection("InvitedUsers")
              .doc(newEventInformation["userID"])
              .set({
              "userID": newEventInformation["userID"],
              "invitedBy": newEventInformation["sentBy"],
              "eventID": newEventInformation["eventID"]
              })
        })
  }
  acceptEventInvitation({newEventInformation}){
    const message = {
      notification: {
        title: `${newEventInformation["eventName"]}`,
        body: `${newEventInformation["nameOfSendingUser"]} is going!`,
      },
      data: {
        type: "NEW_EVENT",
        eventID: newEventInformation["eventID"],
        authorId: newEventInformation["userID"] || "",
      },
      apns: {
        headers: {
            'apns-priority': '10',
        },
        payload: {
            aps: {
                threadId: newEventInformation["eventID"],
                sound: 'default',
            }
        },
    },
      token: newEventInformation["sentByUserToken"]
    };
    return this.thirdCollection.doc(newEventInformation["userID"])
        .collection("InvitedEvents")
        .doc(newEventInformation["eventID"])
        .delete()
        .then(() => {
          return this.secondCollection.doc(newEventInformation["eventID"])
            .collection("InvitedUsers")
            .doc(newEventInformation["userID"])
            .delete()
        })
        .then(() => {
          return this.collection.doc(newEventInformation["userID"])
            .collection("Events")
            .doc(newEventInformation["eventID"])
            .set({
              "eventID": newEventInformation["eventID"],
              "attending": true,
            }, {merge: true})
        })
        .then(() => {
          return this.secondCollection.doc(newEventInformation["eventID"])
            .collection("AttendingUsers")
            .doc(newEventInformation["userID"])
            .set({
            "userID": newEventInformation["userID"],
            "invitedBy": newEventInformation["sentBy"],
            "eventID": newEventInformation["eventID"]
            })
        })
        .then(() => {
          return this.secondCollection.doc(newEventInformation["eventID"])
          .collection("NotAttendingUsers")
          .doc(newEventInformation["userID"])
          .delete()
        })
        .then(() => {
          if (newEventInformation["sentByUserToken"] != "") {
          admin.messaging().send(message)
              .then((response) => {
                // Response is a message ID string.
                console.log("Successfully sent message:", response);
              })
              .catch((error) => {
                console.log("Error sending message:", error);
              });
            }
        })
  }
  declineEventInvitation({newEventInformation}){
    return this.secondCollection.doc(newEventInformation["eventID"])
        .collection("NotAttendingUsers")
        .doc(newEventInformation["userID"])
        .set({
        "userID": newEventInformation["userID"],
        "invitedBy": newEventInformation["sentBy"],
        "eventID": newEventInformation["eventID"]
        })
        .then(() => {
          return this.secondCollection.doc(newEventInformation["eventID"])
            .collection("InvitedUsers")
            .doc(newEventInformation["userID"])
            .delete()
        })
        .then(() => {
          return this.secondCollection.doc(newEventInformation["eventID"])
            .collection("AttendingUsers")
            .doc(newEventInformation["userID"])
            .delete()
        })
  }
  cancelEventInvitation({newEventInformation}){
    return this.thirdCollection.doc(newEventInformation["userID"])
        .collection("InvitedEvents")
        .doc(newEventInformation["eventID"])
        .delete()
        .then(() => {
          return this.secondCollection.doc(newEventInformation["eventID"])
              .collection("InvitedUsers")
              .doc(newEventInformation["userID"])
              .delete()
        })
  }
  removeFromEvent({newEventInformation}){
    return this.secondCollection.doc(newEventInformation["eventID"])
      .collection("AttendingUsers")
      .doc(newEventInformation["userID"])
      .delete()
      .then(() => {
        return this.collection.doc(newEventInformation["userID"])
          .collection("Events")
          .doc(newEventInformation["eventID"])
          .delete()
      })
  }
  sendEventMessage({newMessageInformation}){
    console.log(`newMessageInformation = ${newMessageInformation}`);
    const subscribingUserID = {};
    subscribingUserID[newMessageInformation["sentBy"]] = new Date();
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
    return this.secondCollection.doc(newMessageInformation["eventID"])
        .collection("EventConversation")
        .doc(newMessageInformation["conversationID"])
        .collection("Messages")
        .doc(newMessageInformation["messageID"])
        .set(messageInformation)
        .then(() => {
          return this.secondCollection.doc(newMessageInformation["eventID"])
              .collection("EventConversation")
              .doc("Subscribed")
              .set(subscribingUserID, {merge: true});
        })
        .then(() => {  
          newMessageInformation["attendingFriendTokens"].forEach((item) => {
            const messageData = newMessageInformation
            const name = newMessageInformation["nameOfSendingUser"]
            const eventName = newMessageInformation["eventName"]
            const message = {
              notification: {
                title: `Event: ${eventName}`,
                body: getMessageNotificationBody(name, messageData),
                // body: `${newMessageInformation["message"]}`,
              },
              data: {
                type: "NEW_EVENT_MESSAGE",
                eventID: newMessageInformation["eventID"],
                authorId: newMessageInformation["sentBy"] || "",
                conversationID: newMessageInformation["conversationID"] || "",
              },
              apns: {
                headers: {
                    'apns-priority': '10',
                },
                payload: {
                    aps: {
                        threadId: newMessageInformation["conversationID"],
                    }
                },
            },
              token: `${item}`,
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
  }
  likeEventMessage({newMessageInformation}) {
    return this.secondCollection.doc(newMessageInformation["eventID"])
        .collection("EventConversation")
        .doc(newMessageInformation["conversationID"])
        .collection("Messages")
        .doc(newMessageInformation["messageID"])
        .collection("Likes")
        .doc(newMessageInformation["sentBy"])
        .set({
          "sentBy": newMessageInformation["sentBy"],
          "time": new Date()});
  }
  async checkIfEventIsOverScheduled(getUserToken) {
    const snapshot = await this.secondCollection.where('hasCompleted', '==', false).get()
    if (snapshot.empty) {
      console.log('No matching documents.');
      return;
    }
    snapshot.forEach(doc => {
      let eventDetail = doc.data();
      let eventName = eventDetail.eventName
      let date = eventDetail.eventTimeStart
      let isDeleted = eventDetail.isDeleted || false
      let firstNotification = eventDetail.firstNotification || false
      let secondNotification = eventDetail.secondNotification || false
      const newDate = date.toDate()
      const adjustedTimeAsMs = newDate.setSeconds(newDate.getSeconds() + 60 * 60 * 12);
      const adjustedDateObj = new Date(adjustedTimeAsMs);
      const oneDayNotification = newDate.setSeconds(newDate.getSeconds() - 60 * 60 * 24);
      const oneDayDateObj = new Date(oneDayNotification);
      const oneHourNotification = newDate.setSeconds(newDate.getSeconds() - 60 * 60 * 1);
      const oneHourDateObj = new Date(oneHourNotification);
      const currentTime = new Date();
      if (adjustedDateObj < currentTime) {
        return this.secondCollection.doc(doc.id)
            .set({
              hasCompleted: true,
            },{merge: true})
      }
      if (firstNotification == false && oneDayDateObj < currentTime && isDeleted == false) {
        return this.secondCollection.doc(doc.id)
            .set({
              firstNotification: true,
            },{merge: true})
            .then(() => {
              const notificationBody = `Starts in 24 hours!`
              const event = {};
              event["eventID"] = doc.id
              event["eventName"] = eventName,
              sendNotificationToAttendingUsers(event, notificationBody, getUserToken)
            })
      }
      if (secondNotification == false && oneHourDateObj < currentTime && isDeleted == false) {
        return this.secondCollection.doc(doc.id)
            .set({
              secondNotification: true,
            },{merge: true})
            .then(() => {
              const notificationBody = `Starts in less than an hour!`
              const event = {};
              event["eventID"] = doc.id
              event["eventName"] = eventName,
              sendNotificationToAttendingUsers(event, notificationBody, getUserToken)
            })
      }
    })

  }
  updateEventDetails({newEventInformation}) {
    return this.secondCollection.doc(newEventInformation["eventID"])
        .set({
          "eventName": newEventInformation["eventName"],
          "eventDescription": newEventInformation["eventDescription"],
          "eventTimeStart":  new Date(newEventInformation["eventTimeStart"]),
          "location": newEventInformation["location"],
        }, {merge: true})
        .then(() => {
          if (newEventInformation["newEventTime"] === true) {
            newEventInformation["allAttendingTokens"].forEach((item) => {
              const eventName = newEventInformation["eventName"]
              const message = {
                notification: {
                  title: `${eventName}`,
                  body: `New time: ${newEventInformation["newEventTimeString"]}`
                },
                data: {
                  type: "NEW_EVENT",
                  eventID: newEventInformation["eventID"],
                },
                apns: {
                  headers: {
                      'apns-priority': '10',
                  },
                  payload: {
                      aps: {
                          threadId: newEventInformation["eventID"],
                      }
                  },
              },
                token: `${item}`,
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
          }
        })
  }
  requestToJoinEvent({newEventInformation, getUserToken}) {
    return this.secondCollection.doc(newEventInformation["eventID"])
      .collection("RequestToJoin")
      .doc(newEventInformation["userID"])
      .set({
      "userID": newEventInformation["userID"],
      "message": newEventInformation["message"],
      "eventID": newEventInformation["eventID"],
      "eventName": newEventInformation["eventName"],
      "sentByUserToken": newEventInformation["sentByUserToken"],
      "nameOfSendingUser": newEventInformation["nameOfSendingUser"]
      }, {merge: true})
      .then(() => {
        const event = {};
        event["eventID"] = newEventInformation["eventID"]
        event["eventName"] = newEventInformation["eventName"],
        event["nameOfSendingUser"] = newEventInformation["nameOfSendingUser"]
        event["userID"] = newEventInformation["userID"],
        sendNotificationToHostIDs(event, getUserToken)
      })
  }
  acceptEventRequest({newEventInformation}) {
    const message = {
      notification: {
        title: `${newEventInformation["eventName"]}`,
        body: `Congrats, you can join the party!`,
      },
      data: {
        type: "NEW_EVENT",
        eventID: newEventInformation["eventID"],
        authorId: newEventInformation["currentUser"] || "",
      },
      apns: {
        headers: {
            'apns-priority': '10',
        },
        payload: {
            aps: {
                threadId: newEventInformation["eventID"],
                sound: 'default',
            }
        },
    },
      token: newEventInformation["token"]
    };
    return this.secondCollection.doc(newEventInformation["eventID"])
      .collection("RequestToJoin")
      .doc(newEventInformation["userID"])
      .delete()
      .then(() => {
        return this.secondCollection.doc(newEventInformation["eventID"])
          .collection("AttendingUsers")
          .doc(newEventInformation["userID"])
          .set({
          "userID": newEventInformation["userID"],
          "invitedBy": newEventInformation["currentUser"],
          "eventID": newEventInformation["eventID"]
          })
      })
      .then(() => {
        return this.collection.doc(newEventInformation["userID"])
          .collection("Events")
          .doc(newEventInformation["eventID"])
          .set({
            "eventID": newEventInformation["eventID"],
            "attending": true,
          }, {merge: true})
      })
      .then(() => {
        return this.secondCollection.doc(newEventInformation["eventID"])
          .collection("InvitedUsers")
          .doc(newEventInformation["userID"])
          .delete()
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
      })
  }
  declineEventRequest({newEventInformation}) {
    return this.secondCollection.doc(newEventInformation["eventID"])
      .collection("RequestToJoin")
      .doc(newEventInformation["userID"])
      .delete()
  }
  deleteEvent({newEventInformation, getUserToken}) {
    return this.secondCollection.doc(newEventInformation["eventID"])
      .set({
        "isDeleted": true
      }, {merge: true})
      .then(() => {
        const notificationBody = `The event was cancelled.`
        const event = {};
        event["eventID"] = newEventInformation["eventID"]
        event["eventName"] = newEventInformation["eventName"],
        sendNotificationToAttendingUsers(event, notificationBody, getUserToken)
      })
  }
}

const createEvent = new EventService();
module.exports = createEvent;

