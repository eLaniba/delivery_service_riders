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

        // Prevent duplicate execution if storeStatus is already Completed
        if (newValue.storeStatus === "Completed") {
            console.log("Store status already completed. Skipping update.");
            return null;
        }

        // Check if storeDelivered or riderStoreDelivered has changed
        if (
            newValue.storeDelivered !== previousValue.storeDelivered ||
            newValue.riderStoreDelivered !== previousValue.riderStoreDelivered
        ) {
            // If storeDelivered is not null, riderStoreDelivered is true, and storeStatus is not 'Completed'
            if (
                newValue.storeDelivered !== null &&
                newValue.riderStoreDelivered === true
            ) {
                console.log("Conditions met. Updating order status fields...");

                return change.after.ref.update({
                    orderStatus: "Picked up",
                    storeStatus: "Completed",
                    userStatus: "Picked up"
                });
            }
        }

        return null;
    });

// Confirmation between Rider and User
exports.completeOrderUserRider = functions.firestore
    .document("active_orders/{orderId}")
    .onUpdate((change, context) => {
        const previousValue = change.before.data();
        const newValue = change.after.data();

        console.log("Previous Data:", previousValue);
        console.log("New Data:", newValue);

        // Prevent duplicate execution if already marked as Completed
        if (newValue.orderStatus === "Completed") {
            console.log("Order already completed. Skipping update.");
            return null;
        }

        // Check if userDelivered or riderUserDelivered has changed
        if (
            newValue.userDelivered !== previousValue.userDelivered ||
            newValue.riderUserDelivered !== previousValue.riderUserDelivered
        ) {
            // If userDelivered is not null AND riderUserDelivered is true
            if (newValue.userDelivered !== null && newValue.riderUserDelivered === true) {
                console.log("userDelivered is not null and riderUserDelivered is true. Updating fields...");

                // Update the orderStatus, userStatus, and orderDelivered timestamp
                return change.after.ref.update({
                    orderStatus: "Completed",
                    userStatus: "Completed",
                    orderDelivered: admin.firestore.FieldValue.serverTimestamp()
                });
            }
        }

        return null;
    });




