const functions = require("firebase-functions");

const commentMention = require("../../services/Mention");

exports.commentMention = functions.https.onCall((mentionInformation) => {
  /**
       * Returns mention data
       * @param {string} mentionInformation Contains mention metadata
       * @return {any} The firestore response
       */
  function loadMention(mentionInformation) {
    return new Promise(function(resolve, reject) {
      resolve(mentionInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load mention data."));
    });
  }
  console.log(`mentionInfo = ${JSON.stringify(mentionInformation)}`);
  return loadMention()
      .then(() => {
        mentionInformation.forEach((item) => {
          const newMentionInformation = {
            id: item["id"],
            resourceID: item["resourceID"],
            sentBy: item["sentBy"],
            sentTo: item["sentTo"],
            token: item["token"],
            nameOfSendingUser: item["nameOfSendingUser"],
            originalAuthor: item["originalAuthor"],
          };
          commentMention.commentMention({newMentionInformation})
              .then((r) => console.log(r))
              .catch((err) => console.error(err));
          return {
            something: "returned",
          };
        });
      });
});
