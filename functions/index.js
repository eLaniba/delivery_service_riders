const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
admin.initializeApp();
//Confirmation between Store and Rider
exports.completeOrderStoreRider = functions.firestore
    .document("active_orders/{orderId}")
    .onUpdate((change, context) => {
        const previousValue = change.before.data();
        const newValue = change.after.data();

        console.log("Previous Data:", previousValue);
        console.log("New Data:", newValue);

        // Check if storeDelivered or ridersStoreDelivered has changed
        if (
            newValue.storeDelivered !== previousValue.storeDelivered ||
            newValue.ridersStoreDelivered !== previousValue.ridersStoreDelivered
        ) {
            // If storeDelivered is not null AND ridersStoreDelivered is true
            if (newValue.storeDelivered !== null && newValue.ridersStoreDelivered === true) {
                console.log("storeDelivered is not null and ridersStoreDelivered is true. Updating fields...");

                // Proceed to update the following fields
                return change.after.ref.update({
                    orderStatus: "Picked up",
                    storeStatus: "Completed",
                    userStatus: "Picked up"
                });
            }
        }

        return null;
    });

//Confirmation between Rider and User
exports.completeOrderUserRider = functions.firestore
    .document("active_orders/{orderId}")
    .onUpdate((change, context) => {
        const previousValue = change.before.data();
        const newValue = change.after.data();

        console.log("Previous Data:", previousValue);
        console.log("New Data:", newValue);

        // Check if userDelivered or riderUserDelivered has changed
        if (
            newValue.userDelivered !== previousValue.userDelivered ||
            newValue.riderUserDelivered !== previousValue.riderUserDelivered
        ) {
            // If userDelivered is not null AND riderUserDelivered is true
            if (newValue.userDelivered !== null && newValue.riderUserDelivered === true) {
                console.log("userDelivered is not null and riderUserDelivered is true. Updating fields...");

                // Update the orderStatus and userStatus to 'Completed'
                return change.after.ref.update({
                    orderStatus: "Completed",
                    userStatus: "Completed"
                });
            }
        }

        return null;
    });


