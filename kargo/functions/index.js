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
exports.myFunction2 = functions.firestore.document("chats/{docId}")
    .onCreate((snap, context) => {
      const db = admin.firestore();
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
exports.updatebid = functions.firestore.document("ads/{docId}")
    .onUpdate( (change, context) => {
      const db = admin.firestore();
      const newValue = change.after.data()||{};
      const previousValue = change.before.data()||{};
      const newBid = newValue.highest_bid;
      const oldBid = previousValue.highest_bid;
      db.collection('users').get().then((snapshot) => {
        snapshot.forEach((doc) => {
        
        console.log(doc.data());
        
        
        const allbids=doc.data().myBids;
        console.log(allbids);

        if(allbids.length>0){
          console.log("da5alt");
          console.log(allbids[0].ad_id);
          const bids = allbids.map(ad => ad.ad_id);
          console.log(bids);

          if(bids.includes(context.params.docId)) {
            console.log(doc.data().name,bids);
            if (newBid!==oldBid) {
              console.log("sa7 mot");
            } else{
              console.log("sa7 mesh mot");
            }
            
          }
        }
      });
      return;
    });



    });
