/* eslint-disable indent */
const functions = require("firebase-functions");
const {
  getUser,
  getChatDetail,
  getUserChatDetail,
  updateNewMessageField,
} = require("../../helpers/functions");
const {
  sendMessageNotificationToGroupUsers,
} = require("../../helpers/notifications");

exports.groupMessageNotification = functions.firestore
  .document("ChatMessages/{chatId}/ChatMessagess/{messageId}")
  .onWrite((change, context) => {
    const message = change.after.data();
    const messageId = context.params.messageId;
    const chatId = context.params.chatId;
    const sentBy = message.sentBy;
    console.log("message ", message);
    console.log("messageId ", messageId);
    console.log("chatId ", chatId);
    console.log("sentBy ", sentBy);

    if (messageId !== undefined && messageId !== null) {
      return getUser(sentBy)
        .then((sender) => {
          return getChatDetail(chatId)
            .then((chat) => {
              return getUserChatDetail(sentBy, chatId)
                .then((userChatData) => {
                  const { users } = userChatData;

                  if (
                    userChatData.groupChat !== null &&
                    userChatData.groupChat !== undefined &&
                    userChatData.groupChat == true
                  ) {
                    return updateNewMessageField(sentBy, chatId)
                      .then(() => {
                        return sendMessageNotificationToGroupUsers(
                          message,
                          sender,
                          users,
                          chat,
                          userChatData,
                          chatId,
                          messageId
                        )
                          .then(() => {
                            console.log(
                              "sendMessageNotificationToGroupUsers successful"
                            );
                          })
                          .catch((e) =>
                            console.log(
                              "sendMessageNotificationToGroupUsers error => ",
                              e
                            )
                          );
                      })
                      .catch((e) =>
                        console.log("update new message field error =>", e)
                      );
                  }
                })
                .catch((e) => console.log("receivers error =>", e));
            })
            .catch((e) => console.log("creator error => ", e));
        })
        .catch((e) => console.log("getting sender error ", e));
    } else {
      return null;
    }
  });
