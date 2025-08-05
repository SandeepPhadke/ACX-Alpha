({
    doInit: function (component, event, helper) {
        console.log("Initializing component...");
        
        let action = component.get("c.getEngagementUsers");
        action.setCallback(this, function (response) {
            let state = response.getState();
            console.log("State: ", state);
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                console.log("User Data: ", data);
                if (data && data.length > 0) {
                    component.set("v.userData", data);
                } else {
                    console.warn("No data returned from Apex.");
                    component.set("v.userData", []);
                }
            } else {
                console.error("Error: ", response.getError());
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    }
});