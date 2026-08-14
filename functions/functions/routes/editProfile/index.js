const functions = require("firebase-functions");

const editProfile = require("../../services/Profile");


exports.editProfile = functions.https.onCall((profileInformation) => {
  /**
   * Returns profile information update
   * @param {string} profileInformation Contains profile metadata
   * @return {any} The firestore response
   */
  function loadData(profileInformation) {
    return new Promise(function(resolve, reject) {
      resolve(profileInformation);
      // Rejecting a promise changes its state to "rejected"
      reject(new Error("Could not load profile information."));
    });
  }
  console.log(`profileInformation = ${JSON.stringify(profileInformation)}`);
  return loadData()
      .then(() => {
        const newProfileInformation = {
          name: profileInformation["name"],
          username: profileInformation["username"],
          bio: profileInformation["bio"],
          uid: profileInformation["uid"],
          photo: profileInformation["photo"],
          token: profileInformation["token"],
          school: profileInformation["school"],
        };
        editProfile.create({newProfileInformation})
            .then((r) => console.log(r))
            .catch((err) => console.error(err));
        return {
          something: "returned",
        };
      });
});
