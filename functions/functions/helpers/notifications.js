const admin = require("firebase-admin");
const { intersect, getUser } = require("./functions");

function sendNotification(token, payload, options) {
  return new Promise((resolve, reject) => {
    console.log("token for sending notification ", token);
    admin
      .messaging()
      .sendToDevice(token, payload, options)
      .then(() => {
        resolve("push notification successfully sent");
      })
      .catch((e) => reject("push notification error => ", e));
  });
}
function sendApns(message, userId) {
  return new Promise((resolve, reject) => {
    admin
      .messaging()
      .send(message)
      .then((response) => {
        console.log("Successfully sent message:", response);
        if (userId !== null && userId !== undefined && userId !== "") {
          updateNotificationBadgeCount(userId);
        }
        resolve("push notification successfully sent");
      })
      .catch((error) => {
        console.log("Error sending message:", error);
        reject(error);
      });
  });
}

function getPostNotificationBody(name, post) {
  if (
    post.content != ""
  ) {
    return `${name}: ${post.content}`;
  }
  else if (
    post.videoUrl != undefined
  ) {
    return `${name} shared a video!`;
  }
  else if (
    post.photoLink != undefined
  ) {
    return `${name} shared a photo!`;
  }  else if (
    post.audioUrl != undefined
  ) {
    return `${name} shared an audio message!`;
  } else {
  return `${name}: ${post.content}`;
  }
}
function getCommentNotificationTitle(user, post) {
  if (
    post.content != ""
  ) {
    return `${post.content}`;
  }
  else if (
    post.videoUrl != undefined
  ) {
    return `${user.name}'s video`;
  }
  else if (
    post.photoLink != undefined 
  ) {
    return `${user.name}'s photo`;
  } else if (
    post.audioUrl != undefined 
  ) {
    return `${user.name}'s audio`;
  }else {
  return `${post.content}`;
  }
}
function getCommentNotificationBody(name, comment) {
  if (
    comment.videoUrl != undefined
    ) {
    return `${name} sent a video`;
  } 
  else if (
    comment.photoLink != undefined
  ) {
    return `${name} sent a photo`;
  } else if (
    comment.isGIF === true
    ) {
    return `${name} sent a GIF`;
  } else if (
    comment.audioUrl != undefined
  ) {
  return `${name} sent an audio message`;
  } else {
  return `${name}: ${comment.comment}`;
  }
}
function getGroupMessageNotificationBody(name, message) {
  if (
    message.videoUrl != undefined
    ) {
    return `${name} sent a video`;
  } 
  else if (
    message.photoLink != undefined
  ) {
    return `${name} sent a photo`;
  } else if (
    message.isGIF === true
    ) {
    return `${name} sent a GIF`;
  } 
  else if (
    message.audioUrl != undefined
  ) {
    return `${name} sent an audio message`;
  } else {
  return `${name}: ${message.message}`;
  }
}
function sendNewPostNotificationToMultipleUsers(post, sender, receivers) {
  let postTags = [];
  if (post.hasOwnProperty("tags")) {
    postTags = post["tags"];
  }
  console.log("post tags => ", postTags);
  let notificationsPromises = [];

  receivers.forEach((user) => {
    if (postTags.length > 0) {
      if (
        intersect(postTags, user.myTagsAccess).length > 0 &&
        user.token !== null &&
        user.token !== undefined &&
        user.settings.momentNotifications == true
      ) {
        const message = {
          notification: {
            title: "Moment",
            body: getPostNotificationBody(sender.name, post),
          },
          data: {
            type: "POST_CREATION",
            authorId: sender.uid || "",
            postId: post.postId || "",
          },
          token: user.token,
        };

        notificationsPromises.push(sendApns(message, user.uid));
      }
    } else {
      if (
        user.token !== null &&
        user.token !== undefined &&
        user.settings.momentNotifications == true
      ) {
        const message = {
          notification: {
            title: "Moment",
            body: getPostNotificationBody(sender.name, post),
          },
          data: {
            type: "POST_CREATION",
            authorId: sender.uid || "",
            postId: post.postId || "",
          },
          apns: {
            headers: {
              "apns-priority": "10",
            },
            payload: {
              aps: {
                sound: "default",
              },
            },
          },
          token: user.token,
        };

        notificationsPromises.push(sendApns(message, user.uid));
      }
    }
  });

  return Promise.all(notificationsPromises)
    .then(() => {
      console.log("push notifications for new post sent successfully");
    })
    .catch((e) => {
      console.log("sending notifications for new post error ", e);
    });
}
function sendNewCommentNotificationToMultipleUsers(
  post,
  comment,
  sender,
  receivers,
  postCreatorUser,
  postId
) {
  let postTags = [];
  if (post.hasOwnProperty("tags")) {
    postTags = post["tags"];
  }
  console.log("post tags => ", postTags);
  let notificationsPromises = [];

  receivers.forEach((user) => {
    if (postTags.length > 0) {
      if (
        intersect(postTags, user.myTagsAccess).length > 0 &&
        user.token !== null &&
        user.token !== undefined &&
        user.settings.commentNotifications == true
      ) {
        const message = {
          notification: {
            title: getCommentNotificationTitle(postCreatorUser, post),
            body: getCommentNotificationBody(sender.name, comment),
          },
          data: {
            type: "COMMENT_CREATION",
            postId: postId || "",
            comment: comment.comment || "",
            commentAuthorId: sender.uid || "",
            postAuthorId: post.sentBy || "",
          },
          apns: {
            headers: {
              "apns-priority": "10",
            },
            payload: {
              aps: {
                threadId: postId,
                sound: "default",
              },
            },
          },
          token: user.token,
        };

        notificationsPromises.push(sendApns(message, user.uid));
      }
    } else {
      if (
        user.token !== null &&
        user.token !== undefined &&
        user.settings.commentNotifications == true
      ) {
        const message = {
          notification: {
            title: getCommentNotificationTitle(postCreatorUser, post),
            body: getCommentNotificationBody(sender.name, comment),
          },
          data: {
            type: "COMMENT_CREATION",
            postId: postId || "",
            comment: comment.comment || "",
            commentAuthorId: sender.uid || "",
            postAuthorId: post.sentBy || "",
          },
          apns: {
            headers: {
              "apns-priority": "10",
            },
            payload: {
              aps: {
                threadId: postId,
                sound: "default",
              },
            },
          },
          token: user.token,
        };

        notificationsPromises.push(sendApns(message, user.uid));
      }
    }
  });

  return Promise.all(notificationsPromises)
    .then(() => {
      console.log("push notifications for new post sent successfully");
    })
    .catch((e) => {
      console.log("sending notifications for new post error ", e);
    });
}

function sendMessageNotificationToGroupUsers(
  messageData,
  sender,
  receivers,
  chat,
  userChat,
  chatId,
  messageId
) {
  let usersPromises = [];
  let notificationsPromises = [];

  receivers.forEach((id) => {
    if (id !== sender.uid) {
      usersPromises.push(getUser(id));
    }
  });
  return Promise.all(usersPromises)
    .then((users) => {
      console.log(`messageData = ${JSON.stringify(messageData)}`)
      users.forEach((user) => {
        if (user.token !== null && user.token !== undefined) {
          const message = {
            notification: {
              title: `${messageData.groupName}`,
              body: getGroupMessageNotificationBody(sender.name, messageData),
            },
            data: {
              type: "NEW_GROUP_MESSAGE",
              chatId: chatId || "",
              messageId: messageId || "",
              userImage: sender.webLink || "",
            },
            apns: {
              headers: {
                "apns-priority": "10",
              },
              payload: {
                aps: {
                  threadId: chatId,
                  sound: "default",
                },
              },
            },
            token: user.token,
          };

          notificationsPromises.push(sendApns(message, user.uid));
        }
      });
      return Promise.all(notificationsPromises)
        .then(() => {
          console.log(
            "push notifications for new group message sent successfully"
          );
        })
        .catch((e) => {
          console.log("sending notifications for new group message error ", e);
        });
    })
    .catch((e) => {
      console.log("getting users for new group message error ", e);
    });
}

function updateNotificationBadgeCount(userId) {
  admin
    .firestore()
    .collection("Badge")
    .doc(userId)
    .update({ badgeCount: admin.firestore.FieldValue.increment(1) })
    .then(() => {})
    .catch((e) => {
      console.log("increase badge count error", error);
    });
}

module.exports = {
  sendNewPostNotificationToMultipleUsers,
  sendNotification,
  sendMessageNotificationToGroupUsers,
  sendNewCommentNotificationToMultipleUsers,
  sendApns,
};
