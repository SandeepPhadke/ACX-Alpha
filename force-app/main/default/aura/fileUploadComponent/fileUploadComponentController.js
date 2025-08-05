({
    handleFileUpload: function (component, event, helper) {
        const uploadedFiles = event.getParam("files");
        if (uploadedFiles && uploadedFiles.length > 0) {
            const file = uploadedFiles[0];

            // Set file data
            component.set("v.uploadedFile", file);
            component.set("v.contentDocumentId", file.documentId);
            component.set("v.isFileUploaded", true);
            console.log('Controller finished');
            
        }
    },

    removeFile: function (component, event, helper) {
        const contentDocumentId = component.get("v.contentDocumentId");
        console.log('Remove started ');
        if (contentDocumentId) {
            console.log("contentDocumentId not null");
            // Call helper to delete the file from Salesforce
            helper.deleteFileFromSalesforce(component, contentDocumentId, () => {
                console.log("Delete file fuction");
                // Clear file-related attributes once deleted
                component.set("v.uploadedFile", null);
                component.set("v.contentDocumentId", null);
                component.set("v.isFileUploaded", false);
            });
        } else {
            // If no file is uploaded, just reset attributes
            component.set("v.uploadedFile", null);
            component.set("v.contentDocumentId", null);
            component.set("v.isFileUploaded", false);
        }
    }
});