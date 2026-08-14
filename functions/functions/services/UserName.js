/* eslint-disable require-jsdoc */
const { DB } = require("./Firestore");

class UserNameService {
  constructor() {
    this.collection = DB.collection("UserInfo");
  }

  checkUserNameAvailability(userName) {
    return new Promise((resolve, reject) => {
      this.collection
        .where("username", "==", userName)
        .get()
        .then((snapShot) => {
          let available = snapShot.size > 0 ? false : true;
          let response = { available: available };
          resolve(response);
        })
        .catch((e) => reject(e));
    });
  }
}

const userNameService = new UserNameService();
module.exports = userNameService;
