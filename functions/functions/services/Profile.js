/* eslint-disable require-jsdoc */
// const {DB, bucket} = require("./Firestore");
const {DB, deleteField} = require("./Firestore");
// const admin = require("firebase-admin");
// const storage = admin.storage();
// const bucket = storage.bucket("YOUR_FIREBASE_PROJECT_ID.appspot.com");
// const fs = require("fs");

class ProfileService {
  constructor() {
    this.collection = DB.collection("UserInfo");
    this.secondCollection = DB.collection("FeatureRequests");
    this.thirdCollection = DB.collection("Silence");
    this.fourthCollection = DB.collection("Badge")
  }
  /**
     * Updates the users profile
     * @param {string} name The user's full name
     * @param {string} username The user's username
     * @param {string} bio The user's bio
     * @param {string} uid The user's unique identifier
     * @param {any} photo The user's photo
     * @return {any} The firestore response
     */
  create({newProfileInformation}) {
    console.log(`name = ${newProfileInformation["name"]}`);
    console.log(`uid = ${newProfileInformation["uid"]}`);
    console.log(`photo = ${newProfileInformation["photo"]}`);
    // const metadata = {contentType: `${newProfileInformation["uid"]}/jpeg`};
    return this.collection.doc(newProfileInformation["uid"])
        .set({
          "name": newProfileInformation["name"],
          "username": `@${newProfileInformation["username"]}`,
          "bio": newProfileInformation["bio"],
          "imageurl": `${newProfileInformation["uid"]}.png`,
          "token": newProfileInformation["token"],
          "uid": newProfileInformation["uid"]}, {merge: true})
        .then(() => {
          return this.collection.doc(newProfileInformation["uid"])
              .collection("Settings")
              .doc("Preferences")
              .set({
                "momentNotifications": true,
                "commentNotifications": true
              }, {merge: true })
              .then(() => {
                return this.fourthCollection.doc(newBadgeInformation["uid"])
                    .set({
                      "badgeCount": 0
                    }, {merge: true});
              });
        })
  }
  featureRequest({newFeatureInformation}) {
    return this.secondCollection.doc(newFeatureInformation["currentUser"])
        .collection("Requests")
        .doc(newFeatureInformation["id"])
        .set({
          "message": newFeatureInformation["message"],
          "createdAt": new Date()
        });
  }
  silence({newSilenceInformation}) {
    const silencedUser = {};
    silencedUser[newSilenceInformation["silencedUser"]] = new Date()
    const currentUser = {};
    currentUser[newSilenceInformation["currentUser"]] = new Date()
    return this.thirdCollection.doc(newSilenceInformation["currentUser"])
        .collection("MySilenced")
        .doc("MySilenced")
        .set(silencedUser, {merge: true})
        .then(() => {
            return this.thirdCollection.doc(newSilenceInformation["currentUser"])
                .collection("TotalSilenced")
                .doc("TotalSilenced")
                .set(silencedUser, {merge: true});
        })
        .then(() => {
            return this.thirdCollection.doc(newSilenceInformation["silencedUser"])
                .collection("TotalSilenced")
                .doc("TotalSilenced")
                .set(currentUser, {merge: true});
        });
  }
  removeSilenced({newSilenceInformation}) {
    const silencedUser = {};
    silencedUser[newSilenceInformation["silencedUser"]] = deleteField();
    const currentUser = {};
    currentUser[newSilenceInformation["currentUser"]] = deleteField();
    return this.thirdCollection.doc(newSilenceInformation["currentUser"])
        .collection("MySilenced")
        .doc("MySilenced")
        .set(silencedUser, {merge: true})
        .then(() => {
            return this.thirdCollection.doc(newSilenceInformation["currentUser"])
                .collection("TotalSilenced")
                .doc("TotalSilenced")
                .set(silencedUser, {merge: true});
        })
        .then(() => {
            return this.thirdCollection.doc(newSilenceInformation["silencedUser"])
                .collection("TotalSilenced")
                .doc("TotalSilenced")
                .set(currentUser, {merge: true});
        });
  }
  updateProfileCircle({newCircleInformation}) {
    return this.collection.doc(newCircleInformation["currentUser"])
        .set({ 
          "profileCircle": newCircleInformation["profileCircle"]
        }, {merge: true});
  }
  editPhoneNumber({newProfileInformation}) {
    return this.collection.doc(newProfileInformation["uid"])
        .set({
          "phoneNumber": newProfileInformation["phoneNumber"]}, {merge: true});
  }
  updateBadge({newBadgeInformation}) {
    return this.fourthCollection.doc(newBadgeInformation["uid"])
        .set({
          "badgeCount": 0
        }, {merge: true});
  }
}

const editProfile = new ProfileService();
module.exports = editProfile;
