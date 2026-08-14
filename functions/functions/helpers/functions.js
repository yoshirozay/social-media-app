const { DB } = require("../services/Firestore");

function intersect(a, b) {
  var setB = new Set(b);
  return [...new Set(a)].filter((x) => setB.has(x));
}

function getUser(uid) {
  return new Promise((resolve, reject) => {
    DB.collection("UserInfo")
      .doc(uid)
      .get()
      .then((snapShot) => {
        if (snapShot.data()) {
          let user = snapShot.data();
          getUserSettings(uid)
            .then((settings) => {
              getUserAccessTags(uid)
                .then((myTagsAccess) => {
                  user.settings = settings;
                  user.myTagsAccess = myTagsAccess;
                  resolve(user);
                })
                .catch((e) => console.log("myTagsAccess error ", e));
            })
            .catch((e) => console.log("settings error ", e));
        } else {
          reject();
        }
      })
      .catch((e) => {
        reject(e);
      });
  });
}
function getPost(uid, postId) {
  return new Promise((resolve, reject) => {
    DB.collection("Posts")
      .doc(uid)
      .collection("UserPosts")
      .doc(postId)
      .get()
      .then((snapShot) => {
        if (snapShot.data()) {
          let post = snapShot.data();
          resolve(post);
        } else {
          reject();
        }
      })
      .catch((e) => {
        reject(e);
      });
  });
}

function getUserSettings(uid) {
  return new Promise((resolve, reject) => {
    DB.collection("UserInfo")
      .doc(uid)
      .collection("Settings")
      .doc("Preferences")
      .get()
      .then(async (snapShot) => {
        if (snapShot.data()) {
          let settings = snapShot.data();
          resolve(settings);
        } else {
          reject();
        }
      })
      .catch((e) => {
        reject(e);
      });
  });
}
function getUserFriends(uid) {
  return new Promise((resolve, reject) => {
    try {
      DB.collection("Friends")
        .doc(uid)
        .get()
        .then((snapShot) => {
          if (snapShot.data()) {
            let list = snapShot.data();
            let friendsPromises = [];
            for (var key in list) {
              if (key !== uid) {
                friendsPromises.push(getUser(key));
              }
            }

            Promise.all(friendsPromises)
              .then((response) => {
                resolve(response);
              })
              .catch((e) => {
                console.log("e ", e);
                reject(e);
              });
          } else {
            resolve({});
          }
        })
        .catch((e) => {
          reject(e);
        });
    } catch (error) {
      console.log("error", error);
    }
  });
}

function getUserAccessTags(uid) {
  return new Promise((resolve, reject) => {
    DB.collection("MyTagsAccess")
      .doc(uid)
      .get()
      .then((snapShot) => {
        if (snapShot.data()) {
          let list = snapShot.data();
          let tags = [];
          for (var key in list) {
            tags.push(key);
          }
          resolve(tags);
        } else {
          resolve([]);
        }
      })
      .catch((e) => {
        reject(e);
      });
  });
}

function getChatDetail(id) {
  return new Promise((resolve, reject) => {
    DB.collection("Chats")
      .doc(id)
      .get()
      .then((snapShot) => {
        if (snapShot.data()) {
          snapShot.data();
          resolve(snapShot.data());
        } else {
          reject();
        }
      })
      .catch((e) => {
        reject(e);
      });
  });
}

function getUserChatDetail(userChatId, userChatssId) {
  return new Promise((resolve, reject) => {
    DB.collection("UserChats")
      .doc(userChatId)
      .collection("UserChatss")
      .doc(userChatssId)
      .get()
      .then((snapShot) => {
        if (snapShot.data()) {
          snapShot.data();
          let userChatDetail = snapShot.data();
          userChatDetail.id = snapShot.id;
          resolve(userChatDetail);
        } else {
          reject();
        }
      })
      .catch((e) => {
        reject(e);
      });
  });
}

function updateNewMessageField(userChatId, userChatssId) {
  return new Promise((resolve, reject) => {
    DB.collection("UserChats")
      .doc(userChatId)
      .collection("UserChatss")
      .doc(userChatssId)
      .set(
        {
          newMessage: false,
        },
        { merge: true }
      )
      .then(() => {
        resolve();
      })
      .catch((e) => {
        reject(e);
      });
  });
}
function getBadgeCount(userID) {
  console.log(`BC USERID = ${userID}`);
  return new Promise((resolve, reject) => {
    DB.collection("Badge")
      .doc(userID)
      .get()
      .then((snapShot) => {
        if (snapShot.data()) {
          snapShot.data();
          let badgeCount = snapShot.data();
          console.log(`BADGE COUNT = ${badgeCount}`);
          resolve(badgeCount);
        } else {
          reject();
        }
      })
  });
}
function udpateBadgeCount(userID, badgeCount) {
  return new Promise((resolve, reject) => {
    DB.collection("Badge")
      doc(userID)
      .set(
        {
          "badgeCount": badgeCount + 1
        },
        { mege: true }
      )
      .then(() => {
      resolve();
      })
      .catch((e) => {
        reject(e);
      });
  });
}
// function isExistInCommentSubscription(postId, userId) {
//   return new Promise(async (resolve, reject) => {
//     try {
//       let exist = false;
//       let subRef = admin.firestore().collection("CommentSubscription");
//       let snapshot = await subRef.get();

//       for (var i in snapshot.docs) {
//         const doc = snapshot.docs[i];
//         let objectData = doc.data();
//         if (exist == false) {
//           for (const [key, value] of Object.entries(objectData)) {
//             if (key == postId && value == userId) {
//               exist = true;
//             }
//           }
//         }
//         if (exist == true) {
//           break;
//         }
//       }

//       resolve(exist);
//     } catch (error) {
//       reject(error);
//     }
//   });
// }

async function getUsersForCommentNotification(postId, uid, creator) {
  return new Promise(async (resolve, reject) => {
    try {
      let promises = [];
      let userIds = [];
      let subRef = DB.collection("CommentSubscription");
      let snapshot = await subRef.get();
      let friends = await getUserFriends(creator.uid);
      for (var i in snapshot.docs) {
        const doc = snapshot.docs[i];
        let objectData = doc.data();
        let currentId = doc.id;
        for (const [key, value] of Object.entries(objectData)) {
          if (
            userIds.filter((item) => item == currentId).length == 0 &&
            key == postId &&
            friends.filter((i) => i.uid == currentId).length > 0
          ) {
            promises.push(getUser(currentId));
            userIds.push(currentId);
          }
          if (
            key == postId &&
            userIds.filter((item) => item == value).length == 0 &&
            value !== uid &&
            friends.filter((i) => i.uid == value).length > 0
          ) {
            promises.push(getUser(value));
            userIds.push(value);
          }
        }
      }
      const response = await Promise.all(promises);
      resolve(response);
    } catch (error) {
      console.log("error", error);
      reject(error);
    }
  });
}

function getUserToken(userID) {
  return new Promise((resolve, reject) => {
   DB.collection("UserInfo").doc(userID)
    .get()
    .then((doc) => {
      if (doc.data()) {
        doc.data();
        let user = doc.data();
        resolve(user.token);
      } else {
        reject();
      }
    })
    .catch((e) => {
      reject(e);
    });
  });
}

module.exports = {
  getUser,
  getUserFriends,
  getUserSettings,
  getUserAccessTags,
  intersect,
  getChatDetail,
  getUserChatDetail,
  updateNewMessageField,
  getPost,
  getUsersForCommentNotification,
  getBadgeCount,
  udpateBadgeCount,
  getUserToken,
};
