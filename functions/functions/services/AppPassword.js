/* eslint-disable require-jsdoc */
// const {DB, bucket} = require("./Firestore");
const { DB } = require("./Firestore");

class AppPasswordService {
  doesPasswordExist(password) {
    console.log(`password = ${password}`);
    const passwordDocRef = DB.collection("PromoPasswords");
    return new Promise((resolve, reject) => {
      passwordDocRef
        .where("password", "==", password)
        .get()
        .then((querySnapshot) => {
          resolve({ result: querySnapshot.size > 0 });
        })
        .catch((e) => reject(e));
    });
  }
}

const doesPasswordExist = new AppPasswordService();
module.exports = doesPasswordExist;
