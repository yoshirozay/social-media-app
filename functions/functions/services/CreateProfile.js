/* eslint-disable require-jsdoc */
// const {DB, bucket} = require("./Firestore");
const {DB} = require("./Firestore");

class CreateProfileService {
  constructor() {
    this.collection = DB.collection("UserInfo");
    this.newCollection = DB.collection("Friends");
  }
  /**
     * Creates the users profile
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
    // const metadata = {contentType: `${newProfileInformation["uid"]}/jpeg`};
    return this.collection.doc(newProfileInformation["uid"])
        .set({
          "name": newProfileInformation["name"],
          "username": `@${newProfileInformation["username"]}`,
          "bio": newProfileInformation["bio"],
          "imageurl": `${newProfileInformation["uid"]}.png`,
          "token": newProfileInformation["token"],
          "school": newProfileInformation["school"],
          "city": newProfileInformation["city"],
          "age": newProfileInformation["age"],
          "createdProfile": true,
          "accountCreationDate": new Date(),
          "appPassword": newProfileInformation["appPassword"],
          "webLink": newProfileInformation["webLink"],
          "uid": newProfileInformation["uid"]}, {merge: true})
        .then(() => {
          const friendsList = {};
          friendsList[newProfileInformation["uid"]] = "test";
          friendsList["ctgg158KOnajMBuFZ5GyHLyRYPE3"] = "test";
          return this.newCollection
              .doc(newProfileInformation["uid"])
              .set(friendsList, {merge: true});
        })
        .then(() => {
            return this.collection.doc(newProfileInformation["uid"])
                .collection("Settings")
                .doc("Preferences")
                .set({
                  "momentNotifications": true,
                  "commentNotifications": true}, {merge: true})
        });
  }
  uploadWebLink({newProfileInformation}) {
    return this.collection.doc(newProfileInformation["uid"])
        .set({
          "webLink": newProfileInformation["webLink"]}, {merge: true});
  }
  updateAnonymousMode({newProfileInformation}) {
    return this.collection.doc(newProfileInformation["uid"])
        .set({
          "anonymousMode": newProfileInformation["anonymousMode"]}, {merge: true});
  }
  uploadProfilePhoto({newProfileInformation}) {
    return this.collection.doc(newProfileInformation["userID"])
        .set({
          "photoLink": newProfileInformation["photoLink"]}, {merge: true});
  }
  updateToken({newProfileInformation}) {
    return this.collection.doc(newProfileInformation["uid"])
        .set({
          "token": newProfileInformation["token"]}, {merge: true});
  }
}

const createProfile = new CreateProfileService();
module.exports = createProfile;
