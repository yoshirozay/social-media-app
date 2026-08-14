const functions = require("firebase-functions");

const checkIfEventIsOverScheduled = require("../../services/Events");

const {
  getUserToken,
} = require("../../helpers/functions");


exports.checkIfEventIsOverScheduled = functions.pubsub.schedule('every 5 minutes').onRun(() => {

        checkIfEventIsOverScheduled.checkIfEventIsOverScheduled(getUserToken)
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
});
