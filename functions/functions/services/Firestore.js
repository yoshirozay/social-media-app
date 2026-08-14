const admin = require("firebase-admin");
// const path = "PATH_TO_ADMIN_SDK.json";
// const serviceAccount = require(path);
admin.initializeApp({
  // credential: admin.credential.cert(serviceAccount),
  storageBucket: "YOUR_FIREBASE_PROJECT_ID.appspot.com",
});

module.exports = {
  DB: admin.firestore(),
  deleteField: admin.firestore.FieldValue.delete,
  bucket: admin.storage().bucket(),
};
