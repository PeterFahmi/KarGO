const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

exports.myFunction = functions.firestore.document("chats/{docId}")
    .onUpdate((change, context) => {
      const db = admin.firestore();
      const data = change.after.data();
      console.log(context.params);
      console.log("me7ama a7maaaaaaaaaaaaaaaaaa");
      console.log(data.users[0]._path);
      return db.collection("chats").doc(context.params.docId)
          .get()
          .then((doc) => {
            console.log(" /////////////////////////////////////////////////");
            console.log("recent: ", doc.data().recentMessage);
            const sender=String(doc.data().recentMessageSender);
            console.log(sender);
            const user1=String(doc.data().users[0].id);
            console.log(user1);
            const user2=String(doc.data().users[1].id);
            console.log(user2);
            if (sender==user1) {
              db.collection("users").doc(user1).get()
                  .then((doc1) => {
                    admin.messaging().sendToTopic(user2,
                        {notification: {title: String(doc1.data().name),
                          body: doc.data().recentMessage}});
                  });
            } else {
              db.collection("users").doc(user2).get()
                  .then((doc1) => {
                    admin.messaging().sendToTopic(user1,
                        {notification: {title: String(doc1.data().name),
                          body: doc.data().recentMessage}});
                  });
            }
          });
    });
