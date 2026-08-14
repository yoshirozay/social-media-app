const functions = require("firebase-functions");

const friendRequests = require("../../services/FriendRequest");

exports.friendRequest = functions.https.onCall((requestInfo, context) => {
  const newRequestInfo = {
    id: requestInfo["id"],
    nameOfSendingUser: requestInfo["nameOfSendingUser"],
    token: requestInfo["token"],
  };
  const currentUser = JSON.stringify(context.auth.uid).slice(1, -1);
  friendRequests.create({newRequestInfo, currentUser})
      .then((r) => console.log(r))
      .catch((err) => console.error(err));
  return {
    something: "returned",
  };
});
