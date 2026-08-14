/* eslint-disable require-jsdoc */
// const {DB, bucket} = require("./Firestore");
const {DB, deleteField} = require("./Firestore");

class SettingsService {
  constructor() {
    this.collection = DB.collection("UserInfo");
    this.secondCollection = DB.collection("UserDetail");
  }
  /**
     * Updates the users friends list preference
     * @param {string} friendsListView The user's preference
     * @param {string} uid The user's unique identifier
     * @return {any} The firestore response
     */
  friendsListPreference({newSettingsInformation}) {
    console.log(`uid = ${newSettingsInformation["uid"]}`);
    const preference = {};
    preference["friendsListView"] = newSettingsInformation["friendsListView"];
    return this.collection.doc(newSettingsInformation["uid"])
        .collection("Settings")
        .doc("Preferences")
        .set(preference, {merge: true});
  }
  hasWatchedMainVideo({newVideoInformation}) {
    return this.secondCollection.doc(newVideoInformation["userID"])
        .set({
          "hasWatchedMainVideo": true}, {merge: true});
  }
  hasDoneIntroduction({newVideoInformation}) {
    return this.secondCollection.doc(newVideoInformation["userID"])
        .set({
          "hasDoneIntroduction": true}, {merge: true});
  }
  enableCommentNotification({newUserInformation}) {
    const newUserId = {};
    newUserId[newUserInformation["friendID"]] = true;
    return this.collection.doc(newUserInformation["uid"])
        .collection("Settings")
        .doc("CommentNotifications")
        .set(newUserId, {merge: true});
  }
   enableMomentNotification({newUserInformation}) {
    const newUserId = {};
    newUserId[newUserInformation["friendID"]] = true;
    return this.collection.doc(newUserInformation["uid"])
        .collection("Settings")
        .doc("MomentNotifications")
        .set(newUserId, {merge: true});
  }
  updateMomentNotification({newProfileInformation}) {
    return this.collection.doc(newProfileInformation["uid"])
    .collection("Settings")
    .doc("Preferences")
        .set({
          "momentNotifications": newProfileInformation["momentNotifications"]}, {merge: true});
  }
  disableCommentNotification({newUserInformation}) {
    const newUserId = {};
    newUserId[newUserInformation["friendID"]] = deleteField();
    return this.collection.doc(newUserInformation["uid"])
        .collection("Settings")
        .doc("CommentNotifications")
        .update(newUserId);
  }
  disableMomentNotification({newUserInformation}) {
    const newUserId = {};
    newUserId[newUserInformation["friendID"]] = deleteField();
    return this.collection.doc(newUserInformation["uid"])
        .collection("Settings")
        .doc("MomentNotifications")
        .update(newUserId);
  }
  momentNotificationScript({newUserInformation}) {
    return this.collection.doc(newUserInformation["uid"])
        .collection("Settings")
        .doc("MomentNotifications")
        .set(newUserInformation["friendIDs"], {merge: true})
        .then(() => {
          return this.collection.doc(newUserInformation["uid"])
              .collection("Settings")
              .doc("CommentNotifications")
              .set(newUserInformation["friendIDs"], {merge: true})
        })
  }
  deleteAccount({newAccountInformation}) {
    return this.collection.doc(newAccountInformation["userID"])
      .set({"createdProfile": false}, {merge: true})
      .then(() => {
        return this.secondCollection.doc(newAccountInformation["userID"])
          .set({
            "hasDoneIntroduction": false}, {merge: true});
        })
  }
}

const friendsListPreference = new SettingsService();
module.exports = friendsListPreference;
