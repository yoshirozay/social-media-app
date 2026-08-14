/* eslint-disable require-jsdoc */
// const {DB, bucket} = require("./Firestore");
const {DB, deleteField} = require("./Firestore");
const admin = require("firebase-admin");

class PostService {
  constructor() {
    this.collection = DB.collection("Posts");
    this.secondCollection = DB.collection("Reports");
    this.thirdCollection = DB.collection("SavedPosts");
    this.fourthCollection = DB.collection("CommentSubscription");
  }
  /**
     * Creates a new timeline posts. If the posts has a photo,
     * the function places it in storage
     * @param {string} sentBy The user who made the post
     * @param {string} content The text of the post
     * @param {string} postPhoto The photo attached to the post
     * @return {any} The firestore response
     */
  create({newPostInformation}) {
    console.log(`postID = ${newPostInformation["postID"]}`);
    console.log(`HELLO DOES THIS RUN `);
    console.log(`videoUrl = ${newPostInformation["videoUrl"]}`);
    let postInformation = {};
    const sendingUser = `${newPostInformation["nameOfCurrentUser"]}`;
    if (newPostInformation["photoLink"] != undefined) {
      postInformation = {
        "sentBy": newPostInformation["sentBy"],
        "content": newPostInformation["content"],
        "photoLink": newPostInformation["photoLink"],
        "updatedAt": new Date(),
        "time": new Date(),
      };
    } else if (newPostInformation["videoUrl"] != undefined) {
      postInformation = {
        "sentBy": newPostInformation["sentBy"],
        "content": newPostInformation["content"],
        "videoUrl": newPostInformation["videoUrl"],
        "thumbnailUrl": newPostInformation["thumbnailUrl"],
        "updatedAt": new Date(),
        "time": new Date(),
      };
    } else if (newPostInformation["audioUrl"] != undefined) {
      postInformation = {
        "sentBy": newPostInformation["sentBy"],
        "content": newPostInformation["content"],
        "audioUrl": newPostInformation["audioUrl"],
        "updatedAt": new Date(),
        "time": new Date(),
      };
    } else {
      postInformation = {
        "sentBy": newPostInformation["sentBy"],
        "content": newPostInformation["content"],
        "updatedAt": new Date(),
        "time": new Date(),
      };
    }
    return this.collection.doc(newPostInformation["sentBy"])
        .collection("UserPosts")
        .doc(`${newPostInformation["postID"]}`)
        .set(postInformation)
        .then(() => {
          const authorData = {};
          authorData[newPostInformation["postID"]] = newPostInformation["sentBy"];
          return this.fourthCollection.doc(newPostInformation["sentBy"])
              .set(authorData, {merge: true});
        });
  }
  delete({newPostInformation}) {
    return this.collection.doc(newPostInformation["currentUser"])
        .collection("UserPosts")
        .doc(newPostInformation["postID"])
        .collection("Likes")
        .get()
        .then((res) => {
          res.forEach((element) => {
            element.ref.delete();
          });
        }).then(() => {
          return this.collection.doc(newPostInformation["currentUser"])
              .collection("UserPosts")
              .doc(newPostInformation["postID"])
              .collection("Comments")
              .get()
              .then((res) => {
                res.forEach((element) => {
                  element.ref.delete();
                });
              });
        }).then(() => {
          return this.collection.doc(newPostInformation["currentUser"])
              .collection("UserPosts")
              .doc(newPostInformation["postID"]).delete();
        }).then(() => {
          if (newPostInformation["isThereAPhoto"] === true) {
            const storage = admin.storage();
            const id = newPostInformation["currentUser"];
            const postID = newPostInformation["postID"];
            const path = `${id}/TimelinePostPhotos/${postID}`;
            return storage.bucket()
                .file(`${path}/newPost.jpeg`).delete();
          }}).then(() => {
            if (newPostInformation["isThereAVideo"] === true) {
            const storage = admin.storage();
            const id = newPostInformation["currentUser"];
            const postID = newPostInformation["postID"];
            const path = `${id}/TimelinePostVideos/Video-${postID}`;
            return storage.bucket()
                .file(`${path}/thumbnail.jpeg`).delete()
                .then(() => {
                  return storage.bucket()
                      .file(`${path}/video.mov`).delete();
                });
          } 
        });
  }
  reportPost({newReportInformation}){
    return this.secondCollection.doc(newReportInformation["reportedUser"])
        .collection("Posts")
        .doc(newReportInformation["postID"])
        .collection("Users")
        .doc(newReportInformation["sentBy"])
        .set({
          "content": newReportInformation["content"]
        }); 
  }
  savePost({savedPostInformation}) {
    const postID = {};
    postID[savedPostInformation["postID"]] = new Date()
    return this.thirdCollection.doc(savedPostInformation["currentUser"])
        .collection("Posts")
        .doc(savedPostInformation["postAuthor"])
        .set(postID, {merge: true});
  }
  deleteSavedPost({savedPostInformation}) {
    const deletePost = {};
    deletePost[savedPostInformation["postID"]] = deleteField();
    return this.thirdCollection.doc(savedPostInformation["currentUser"])
        .collection("Posts")
        .doc(savedPostInformation["postAuthor"])
        .update(deletePost);
  }
  uploadPostPhotoLink({newPostInformation}){
    return this.collection.doc(newPostInformation["postAuthor"])
        .collection("UserPosts")
        .doc(newPostInformation["postID"])
        .set({
          "photoLink": newPostInformation["photoLink"]}, {merge: true});
  }
  uploadPostThumbnailLink({newPostInformation}){
    return this.collection.doc(newPostInformation["postAuthor"])
        .collection("UserPosts")
        .doc(newPostInformation["postID"])
        .set({
          "thumbnailUrl": newPostInformation["thumbnailUrl"]}, {merge: true});
  }
  didTakePostScreenshot({newPostInformation}){
    const userWhoScreenshotted = {};
    userWhoScreenshotted[newPostInformation["currentUser"]] = new Date();
    return this.collection.doc(newPostInformation["postAuthor"])
        .collection("UserPosts")
        .doc(newPostInformation["postID"])
        .collection("Screenshots")
        .doc("Screenshots")
        .set(userWhoScreenshotted, {merge: true});
  }
}

const sendPosts = new PostService();
module.exports = sendPosts;
