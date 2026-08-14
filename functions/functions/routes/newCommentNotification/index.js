/* eslint-disable indent */
const functions = require("firebase-functions");
const {
  getUserFriends,
  getUsersForCommentNotification,
  getUser,
  getPost,
} = require("../../helpers/functions");
const {
  sendNewCommentNotificationToMultipleUsers,
} = require("../../helpers/notifications");

exports.sendNotificationsOnNewComment = functions.firestore
  .document("Posts/{userId}/UserPosts/{postId}/Comments/{commentId}")
  .onCreate(async (snap, context) => {
    const comment = snap.data();
    const postId = context.params.postId;
    const postCreator = context.params.userId;
    const commentId = context.params.commentId;
    let post = null;
    let postCreatorUser = null;
    await getUser(postCreator);
    try {
      post = await getPost(postCreator, postId);
      postCreatorUser = await getUser(postCreator);
    } catch (e) {
      console.log(e);
      return;
    }
    console.log("post is ", JSON.stringify(post));
    console.log("comment is ", JSON.stringify(comment));
    console.log("postCreator is ", JSON.stringify(postCreatorUser));

    if (commentId !== undefined && comment.sentBy !== null) {
      comment.commentId = commentId;
      const { sentBy } = comment;

      return getUser(sentBy)
        .then((creator) => {
          console.log("creator => ", JSON.stringify(creator));
          return getUsersForCommentNotification(postId, sentBy, creator)
            .then((receivers) => {
              console.log("receivers ", JSON.stringify(receivers));
              return sendNewCommentNotificationToMultipleUsers(
                post,
                comment,
                creator,
                receivers,
                postCreatorUser,
                postId
              )
                .then(() => {
                  console.log(
                    "sendNewCommentNotificationToMultipleUsers successful"
                  );
                })
                .catch((e) =>
                  console.log(
                    "sendNewCommentNotificationToMultipleUsers error => ",
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
