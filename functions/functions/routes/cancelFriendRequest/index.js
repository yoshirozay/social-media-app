const functions = require("firebase-functions");

const friendRequests = require("../../services/FriendRequest");

exports.cancelFriendRequest = functions.https.onCall((data, context) => {
  const userId = JSON.stringify(data).slice(2, -2);
  const formattedUID = JSON.stringify(context.auth.uid).slice(1, -1);

  friendRequests.cancel({userId, formattedUID})
      .then((r) => console.log(r))
      .catch((err) => console.error(err));

  return {
    something: "returned",
  };
});
