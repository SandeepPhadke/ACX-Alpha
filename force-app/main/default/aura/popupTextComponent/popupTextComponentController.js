({
    openModal: function (component, event, helper) {
        component.set("v.isModalOpen", true);
    },
    closeModal: function (component, event, helper) {
        component.set("v.isModalOpen", false);
    }
});