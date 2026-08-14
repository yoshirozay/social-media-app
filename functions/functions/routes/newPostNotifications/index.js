/* eslint-disable indent */
const functions = require("firebase-functions");
const { getUserFriends, getUser } = require("../../helpers/functions");
const {
  sendNewPostNotificationToMultipleUsers,
} = require("../../helpers/notifications");

exports.sendNotificationsOnNewPost = functions.firestore
  .document("Posts/{userId}/UserPosts/{postId}")
  .onCreate(async (snap, context) => {
    const post = snap.data();
    const postId = context.params.postId;
    if (postId !== undefined && post.sentBy !== null) {
      post.postId = postId;
      const { sentBy } = post;
      return getUser(sentBy)
        .then((creator) => {
          console.log("creator => ", JSON.stringify(creator));
          return getUserFriends(sentBy)
            .then((receivers) => {
              console.log("receivers ", JSON.stringify(receivers));
              console.log("post => ", JSON.stringify(post));
              return sendNewPostNotificationToMultipleUsers(
                post,
                creator,
                receivers
              )
                .then(() => {
                  console.log(
                    "sendNewPostNotificationToMultipleUsers successful"
                  );
                })
                .catch((e) =>
                  console.log(
                    "sendNewPostNotificationToMultipleUsers error => ",
                    e
                  )
                );
            })
            .catch((e) => console.log("receivers error =>", e));
        })
        .catch((e) => console.log("creator error => ", e));
    } else {
      return null;
    }
  });
