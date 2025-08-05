({
    deleteFileFromSalesforce: function (component, contentDocumentId, callback) {
        console.log("helper0");
        const action = component.get("c.deleteFile");
        console.log("helper1");
        action.setParams({
            contentDocumentId: contentDocumentId
        });
        console.log("helper2");
        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                console.log("File deleted successfully.");
                if (callback) {
                    callback(); // Invoke the callback to reset UI
                }
            } else {
                console.error("Error deleting file: ", response.getError());
                // Handle error scenarios here if necessary
            }
        });

        $A.enqueueAction(action);
    }
});