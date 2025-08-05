({
    doInit: function (component, event, helper) {
        let informationRequestId = component.get("v.informationRequestId");

        if (!informationRequestId) {
            console.error("Information Request ID is required");
            return;
        }

        let action = component.get("c.getTopUsers");
        action.setParams({ informationRequestId: informationRequestId });

        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log("UserList--",response.getReturnValue());
                component.set("v.userList", response.getReturnValue());
            } else {
                console.error("Error: ", response.getError());
            }
        });

        $A.enqueueAction(action);
    }
});