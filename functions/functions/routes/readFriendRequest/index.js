const functions = require("firebase-functions");

const readFriendRequests = require("../../services/FriendRequest");

exports.readFriendRequests = functions.https.onCall((requestInfo) => {
  const newRequestInfo = {
    id: requestInfo["id"],
  };
  readFriendRequests.readFriendRequests({newRequestInfo})
      .then((r) => console.log(r))
      .catch((err) => console.error(err));
  return {
    something: "returned",
  };
});
