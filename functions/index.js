const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
admin.initializeApp();

//Confirmation between Rider and User
exports.confirmOrderStatusUserRider = functions.firestore
    .document("active_orders/{orderId}") // Replace 'orders' with your Firestore collection name if different
    .onUpdate((change, context) => {
        // Fetch the data before and after the update
        const previousValue = change.before.data();
        const newValue = change.after.data();

        // Log data for debugging purposes
        console.log("Previous Data:", previousValue);
        console.log("New Data:", newValue);

        // Check if userConfirm and riderConfirm fields changed
        if (
            newValue.userConfirmDelivery !== previousValue.userConfirmDelivery ||
            newValue.riderConfirmDelivery !== previousValue.riderConfirmDelivery
        ) {
            // If both userConfirm and riderConfirm are true
            if (newValue.userConfirmDelivery === true && newValue.riderConfirmDelivery === true) {
                console.log("Both userConfirm and riderConfirm are true. Updating orderStatus to 'Delivered'.");

                // Update the orderStatus field to 'Delivered'
                return change.after.ref.update({
                    orderStatus: "Delivered",
                });
            }
        }

        // Return null if no action is required
        return null;
    });

//Confirmation between Store and Rider
exports.confirmOrderStatusComplete = functions.firestore
    .document("active_orders/{orderId}") // Replace 'active_orders' with your Firestore collection name if different
    .onUpdate((change, context) => {
        // Fetch the data before and after the update
        const previousValue = change.before.data();
        const newValue = change.after.data();

        // Log data for debugging purposes
        console.log("Previous Data:", previousValue);
        console.log("New Data:", newValue);

        // Check if orderDelivered and storeConfirmDelivery fields changed
        if (
            newValue.orderDelivered !== previousValue.orderDelivered ||
            newValue.storeConfirmDelivery !== previousValue.storeConfirmDelivery
        ) {
            // If orderDelivered is not null and storeConfirmDelivery is true
            if (newValue.orderDelivered !== null && newValue.storeConfirmDelivery === true) {
                console.log("orderDelivered is not null and storeConfirmDelivery is true. Updating orderStatus to 'Confirmed by Store'.");

                // Update the orderStatus field to 'Confirmed by Store'
                return change.after.ref.update({
                    orderStatus: "Completed",
                });
            }
        }

        // Return null if no action is required
        return null;
    });
