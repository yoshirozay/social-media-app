/* eslint-disable require-jsdoc */

const {DB, deleteField} = require("./Firestore");

class TagsService {
  constructor() {
    this.collection = DB.collection("Posts");
    this.secondCollection = DB.collection("Tags");
    this.thirdCollection = DB.collection("TagAccess");
    this.fourthCollection = DB.collection("TagInvitations");
    this.fifthCollection = DB.collection("Notifications");
    this.sixthCollection = DB.collection("MyTags");
    this.seventhCollection = DB.collection("MyTagsAccess");
    this.eightCollection = DB.collection("CommentSubscription");
  }
  sendTaggedPost({newPostInformation}) {
    console.log(`postID = ${newPostInformation["postID"]}`);
    let postInformation = {};
    if (newPostInformation["photoLink"] != undefined) {
      postInformation = {
        "sentBy": newPostInformation["sentBy"],
        "content": newPostInformation["content"],
        "tags": newPostInformation["tags"],
        "photoLink": newPostInformation["photoLink"],
        "updatedAt": new Date(),
        "time": new Date(),
      };
    } else if (newPostInformation["videoUrl"] != undefined) {
      postInformation = {
        "sentBy": newPostInformation["sentBy"],
        "content": newPostInformation["content"],
        "tags": newPostInformation["tags"],
        "videoUrl": newPostInformation["videoUrl"],
        "thumbnailUrl": newPostInformation["thumbnailUrl"],
        "updatedAt": new Date(),
        "time": new Date(),
      };
    } else if (newPostInformation["audioUrl"] != undefined) {
      postInformation = {
        "sentBy": newPostInformation["sentBy"],
        "content": newPostInformation["content"],
        "tags": newPostInformation["tags"],
        "audioUrl": newPostInformation["audioUrl"],
        "updatedAt": new Date(),
        "time": new Date(),
      };
    } else {
      postInformation = {
        "sentBy": newPostInformation["sentBy"],
        "content": newPostInformation["content"],
        "tags": newPostInformation["tags"],
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
          return this.eightCollection.doc(newPostInformation["sentBy"])
              .set(authorData, {merge: true});
        });
  }
  createNewTag({newTagInformation}) {
    console.log(`tagID = ${newTagInformation["tagID"]}`);
    let tagInformation = {};
    tagInformation = {
      "tagID": newTagInformation["tagID"],
      "name": newTagInformation["name"],
      "description": newTagInformation["description"],
      "createdAt": new Date(),
      "createdBy": newTagInformation["createdBy"],
    };
    const createdBy = {};
    createdBy[newTagInformation["createdBy"]] = new Date();
    const tagID = {};
    tagID[newTagInformation["tagID"]] = new Date();
    const myTagID = {};
    myTagID[newTagInformation["tagID"]] = newTagInformation["createdBy"];
    return this.secondCollection.doc(newTagInformation["tagID"])
        .set(tagInformation)
        .then(() => {
          return this.thirdCollection.doc(newTagInformation["tagID"])
              .set(createdBy, {merge: true})
              .then(() => {
                return this.sixthCollection.doc(newTagInformation["createdBy"])
                    .set(tagID, {merge: true})
                    .then(() => {
                      return this.seventhCollection.doc(newTagInformation["createdBy"])
                          .set(myTagID, {merge: true});
                    });
              });
        });
  }
  inviteToTag({newInviteInformation}) {
    const acceptingUserId = {};
    acceptingUserId[newInviteInformation["sentTo"]] = new Date();
    return this.thirdCollection.doc(newInviteInformation["tagID"])
        .set(acceptingUserId, {merge: true})
        .then(() => {
          const tagID = {};
          tagID[newInviteInformation["tagID"]] = newInviteInformation["creatorID"];
          return this.seventhCollection.doc(newInviteInformation["sentTo"])
              .set(tagID, {merge: true});
        });
  }
  removeFromTag({newInviteInformation}) {
    const deletedUserId = {};
    deletedUserId[newInviteInformation["sentTo"]] = deleteField();
    return this.thirdCollection.doc(newInviteInformation["tagID"])
        .update(deletedUserId, {merge: true})
        .then(() => {
          const deleteTagID = {};
          deleteTagID[newInviteInformation["tagID"]] = deleteField();
          return this.seventhCollection.doc(newInviteInformation["sentTo"])
              .update(deleteTagID, {merge: true});
        });
  }
  deleteTag({newTagInformation}) {
    const deletedTagID = {};
    deletedTagID[newTagInformation["tagID"]] = deleteField();
    return this.sixthCollection.doc(newTagInformation["tagCreator"])
        .update(deletedTagID, {merge: true});
  }
  acceptTagInvitation({newInviteInformation}) {
    console.log(`documentID = ${newInviteInformation["documentID"]}`);
    const acceptingUserId = {};
    acceptingUserId[newInviteInformation["acceptingUser"]] = new Date();
    return this.thirdCollection.doc(newInviteInformation["tagID"])
        .set(acceptingUserId, {merge: true})
        .then(() => {
          const acceptingUser = newInviteInformation["acceptingUser"];
          return this.fourthCollection.doc(acceptingUser)
              .collection("Invites")
              .doc(newInviteInformation["documentID"])
              .delete();
          /*
            need to send a notification to each friend in the tag
            that _____ has joined the tag */
        })
        .then(() => {
          const tagID = {};
          tagID[newInviteInformation["tagID"]] = new Date();
          return this.sixthCollection.doc(newInviteInformation["acceptingUser"])
              .set(tagID, {merge: true});
        })
        .then(() => {
          const deleteInv = {};
          deleteInv[newInviteInformation["acceptingUser"]] = deleteField();
          return this.sixthCollection.doc(newInviteInformation["sentBy"])
              .collection("Invites")
              .doc(newInviteInformation["tagID"])
              .update(deleteInv);
        });
  }
}

const tags = new TagsService();

module.exports = tags;
