const functions = require("firebase-functions");

const friendRequests = require("../../services/FriendRequest");

exports.deleteFriendRequest = functions.https.onCall((data, context) => {
  const formattedUID = JSON.stringify(data).slice(2, -2);
  const userId = JSON.stringify(context.auth.uid).slice(1, -1);
  friendRequests.cancel({userId, formattedUID})
      .then((r) => console.log(r))
      .catch((err) => console.error(err));

  return {
    something: "returned",
  };
});
