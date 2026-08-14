/* eslint-disable require-jsdoc */
// const {DB, bucket} = require("./Firestore");
const {DB, deleteField} = require("./Firestore");
const admin = require("firebase-admin");

class PostService {
  constructor() {
    this.collection = DB.collection("Posts");
    this.secondCollection = DB.collection("Reports");
    this.thirdCollection = DB.collection("SavedPosts");
    this.fourthCollection = DB.collection("ReadPost");
    this.fifthCollection = DB.collection("CommentSubscription");
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
    console.log(`videoUrl = ${newPostInformation["videoUrl"]}`);
    let postInformation = {};
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
          const postID = {};
          postID[newPostInformation["postID"]] = newPostInformation["sentBy"];
          return this.fifthCollection.doc(newPostInformation["sentBy"])
          .set(postID, {merge: true})
        });
  }
  delete({newPostInformation}) {
    return this.collection.doc(newPostInformation["currentUser"])
    .collection("UserPosts")
    .doc(newPostInformation["postID"])
    .set({
      "isDeleted": true}, {merge: true})
    .then(() => {
      return this.collection.doc(newPostInformation["currentUser"])
          .collection("UserPosts")
          .doc(newPostInformation["postID"])
          .collection("Likes")
          .get()
          .then((res) => {
            res.forEach((element) => {
              element.ref.delete();
            });
          })
          .then(() => {
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
            } else if (newPostInformation["isThereAVideo"] === true) {
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
            } else if (newPostInformation["isThereAudio"] === true) {
              const storage = admin.storage();
              const id = newPostInformation["sentBy"];
              const postID = newPostInformation["postID"];
              const path = `${id}/TimelinePostAudios/${postID}`;
              return storage.bucket()
                  .file(`${path}/audio.m4a`).delete();
            }
          });
    })
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
  modifyMoment({newPostInformation}) {
    console.log(`postID = ${newPostInformation["postID"]}`);
    console.log(`videoUrl = ${newPostInformation["videoUrl"]}`);
    if (newPostInformation["deletePhoto"] === true) {
      const storage = admin.storage();
      const id = newPostInformation["sentBy"];
      const folderName = newPostInformation["oldFolderName"];
      const path = `${id}/TimelinePostPhotos/${folderName}`;
      return storage.bucket()
          .file(`${path}/newPost.jpeg`).delete()
          .then(() => {
            updatePostDocument(newPostInformation)
          })
    } else if (newPostInformation["deleteVideo"] === true) {
      const storage = admin.storage();
      const id = newPostInformation["sentBy"];
      const folderName = newPostInformation["oldFolderName"];
      const path = `${id}/TimelinePostVideos/${folderName}`;
      return storage.bucket()
          .file(`${path}/thumbnail.jpeg`).delete()
          .then(() => {
            return storage.bucket()
                .file(`${path}/video.mov`).delete()
                .then(() => {
                  console.log(`newPostInformation1 = ${JSON.stringify(newPostInformation)}`);
                  updatePostDocument(newPostInformation)
                })
          });
    } else if (newPostInformation["deleteAudio"] === true) {
      const storage = admin.storage();
      const id = newPostInformation["sentBy"];
      const folderName = newPostInformation["oldFolderName"];
      const path = `${id}/TimelinePostAudios/${folderName}`;
      return storage.bucket()
          .file(`${path}/audio.m4a`).delete()
          .then(() => {
            updatePostDocument(newPostInformation)
          })
    } else {
      updatePostDocument(newPostInformation)
    }
  }
  modifyTaggedMoment({newPostInformation}) {
    console.log(`postID = ${newPostInformation["postID"]}`);
    console.log(`videoUrl = ${newPostInformation["videoUrl"]}`);
    console.log(`audioUrl = ${newPostInformation["audioUrl"]}`);
    if (newPostInformation["deletePhoto"] === true) {
      const storage = admin.storage();
      const id = newPostInformation["sentBy"];
      const folderName = newPostInformation["oldFolderName"];
      const path = `${id}/TimelinePostPhotos/${folderName}`;
      return storage.bucket()
          .file(`${path}/newPost.jpeg`).delete()
          .then(() => {
            updateTaggedPostDocument(newPostInformation)
          })
    } else if (newPostInformation["deleteVideo"] === true) {
      const storage = admin.storage();
      const id = newPostInformation["sentBy"];
      const folderName = newPostInformation["oldFolderName"];
      const path = `${id}/TimelinePostVideos/${folderName}`;
      return storage.bucket()
          .file(`${path}/thumbnail.jpeg`).delete()
          .then(() => {
            return storage.bucket()
                .file(`${path}/video.mov`).delete()
                .then(() => {
                  console.log(`updateTaggedPostDocument1 = ${JSON.stringify(newPostInformation)}`);
                  updateTaggedPostDocument(newPostInformation)
                })
          });
    } else if (newPostInformation["deleteAudio"] === true) {
      const storage = admin.storage();
      const id = newPostInformation["sentBy"];
      const folderName = newPostInformation["oldFolderName"];
      const path = `${id}/TimelinePostAudios/${folderName}`;
      return storage.bucket()
          .file(`${path}/audio.m4a`).delete()
          .then(() => {
            updateTaggedPostDocument(newPostInformation)
          })
    } else {
      console.log(`updateTaggedPostDocument1 = ${JSON.stringify(newPostInformation)}`);
      updateTaggedPostDocument(newPostInformation)
    }
  }
updateUpdatedAt({newPostInformation}) {
  return this.collection.doc(newPostInformation["userID"])
      .collection("UserPosts")
      .doc(newPostInformation["postID"])
      .set({
        "updatedAt": new Date(newPostInformation["updatedAt"])}, {merge: true});
}
readPost({newPostInformation}) {
  const postID = {};
  postID[`readTime`] = new Date();
  return this.fourthCollection.doc(newPostInformation["currentUser"])
      .collection("ReadPostIDs")
      .doc(newPostInformation["postID"])
      .set(postID, {merge: true})
}
isTypingInOP({newPostInformation}) {
  function deleteTypingUser(newPostInformation) {
    return new Promise((resolve, reject) => {
      DB.collection("Posts")
        .doc(newPostInformation["originalAuthor"])
        .collection("UserPosts")
        .doc(newPostInformation["postID"])
        .collection("IsTyping")
        .doc(newPostInformation["typingUser"])
        .delete()
        .then(() => {
          resolve();
        })
        .catch((e) => {
          reject(e);
        });
    });
  }
  return this.collection
    .doc(newPostInformation["originalAuthor"])
    .collection("UserPosts")
    .doc(newPostInformation["postID"])
    .collection("IsTyping")
    .doc(newPostInformation["typingUser"])
    .set({
      "typingUser": newPostInformation["typingUser"],
      "time": new Date()}, {merge: true})
    .then(() => {
      setTimeout(deleteTypingUser, 15000, newPostInformation);
    });
  }

  isNotTypingInOP({newPostInformation}) {
    return this.collection
      .doc(newPostInformation["originalAuthor"])
      .collection("UserPosts")
      .doc(newPostInformation["postID"])
      .collection("IsTyping")
      .doc(newPostInformation["typingUser"]).delete()
  }
}


function updateTaggedPostDocument(newPostInformation) {
  console.log(`updateTaggedPostDocument2 = ${JSON.stringify(newPostInformation)}`);
  let postInformation = {};
    if (newPostInformation["photoLink"] != undefined) {
      postInformation = {
        "sentBy": newPostInformation["sentBy"],
        "content": newPostInformation["content"],
        "tags": newPostInformation["tags"],
        "photoLink": newPostInformation["photoLink"],
        "updatedAt": new Date(),
        "time": new Date(newPostInformation["time"]),
      };
    } else if (newPostInformation["videoUrl"] != undefined) {
      postInformation = {
        "sentBy": newPostInformation["sentBy"],
        "content": newPostInformation["content"],
        "tags": newPostInformation["tags"],
        "videoUrl": newPostInformation["videoUrl"],
        "thumbnailUrl": newPostInformation["thumbnailUrl"],
        "updatedAt": new Date(),
        "time": new Date(newPostInformation["time"]),
      };
    } else if (newPostInformation["audioUrl"] != undefined) { 
      postInformation = {
        "sentBy": newPostInformation["sentBy"],
        "content": newPostInformation["content"],
        "tags": newPostInformation["tags"],
        "audioUrl": newPostInformation["audioUrl"],
        "updatedAt": new Date(),
        "time": new Date(newPostInformation["time"]),
      };
    } else {
      postInformation = {
        "sentBy": newPostInformation["sentBy"],
        "content": newPostInformation["content"],
        "tags": newPostInformation["tags"],
        "updatedAt": new Date(),
        "time": new Date(newPostInformation["time"]),
      };
    }
    return DB.collection("Posts").doc(newPostInformation["sentBy"])
        .collection("UserPosts")
        .doc(`${newPostInformation["postID"]}`)
        .set(postInformation)
}

function updatePostDocument(newPostInformation) {
  let postInformation = {};
  if (newPostInformation["photoLink"] != undefined) {
    postInformation = {
      "sentBy": newPostInformation["sentBy"],
      "content": newPostInformation["content"],
      "photoLink": newPostInformation["photoLink"],
      "updatedAt": new Date(),
      "time": new Date(newPostInformation["time"]),
    };
  } else if (newPostInformation["videoUrl"] != undefined) {
    postInformation = {
      "sentBy": newPostInformation["sentBy"],
      "content": newPostInformation["content"],
      "videoUrl": newPostInformation["videoUrl"],
      "thumbnailUrl": newPostInformation["thumbnailUrl"],
      "updatedAt": new Date(),
      "time": new Date(newPostInformation["time"]),
    };
  } else if (newPostInformation["audioUrl"] != undefined) { 
    postInformation = {
      "sentBy": newPostInformation["sentBy"],
      "content": newPostInformation["content"],
      "audioUrl": newPostInformation["audioUrl"],
      "updatedAt": new Date(),
      "time": new Date(newPostInformation["time"]),
    };
  } else {
    postInformation = {
      "sentBy": newPostInformation["sentBy"],
      "content": newPostInformation["content"],
      "updatedAt": new Date(),
      "time": new Date(newPostInformation["time"]),
    };
  }
  return DB.collection("Posts").doc(newPostInformation["sentBy"])
      .collection("UserPosts")
      .doc(`${newPostInformation["postID"]}`)
      .set(postInformation)
}

const sendPosts = new PostService();
module.exports = sendPosts;
