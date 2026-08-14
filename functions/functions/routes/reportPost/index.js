const functions = require("firebase-functions");

const reportPost = require("../../services/Posts");

exports.reportPost = functions.https.onCall((reportInformation) => {
  /**
     * Returns post data
     * @param {string} reportInformation Contains post metadata
     * @return {any} The firestore response
     */
  function loadData(reportInformation) {
    return new Promise(function(resolve, reject) {
      resolve(reportInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load post data."));
    });
  }
  console.log(`reportInformation = ${JSON.stringify(reportInformation)}`);
  return loadData()
      .then(() => {
        const newReportInformation = {
          sentBy: reportInformation["sentBy"],
          content: reportInformation["content"],
          postID: reportInformation["postID"],
          reportedUser: reportInformation["reportedUser"]
        };
        reportPost.reportPost({newReportInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
