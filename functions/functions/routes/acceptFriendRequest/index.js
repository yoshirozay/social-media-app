const functions = require("firebase-functions");

const friendRequests = require("../../services/FriendRequest");

exports.acceptFriendRequest = functions.https.onCall((requestInfo, context) => {
  console.log(`friendInfo = ${JSON.stringify(requestInfo)}`);
  const newRequestInfo = {
    id: requestInfo["id"],
    nameOfSendingUser: requestInfo["nameOfSendingUser"],
    token: requestInfo["token"],
  };
  const currentUser = JSON.stringify(context.auth.uid).slice(1, -1);
  friendRequests.accept({newRequestInfo, currentUser})
      .then((r) => console.log(r))
      .catch((err) => console.error(err));
  return {
    something: "returned",
  };
});
