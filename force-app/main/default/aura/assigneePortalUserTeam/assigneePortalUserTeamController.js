({
    doInit: function (component, event, helper) {
        console.log(
            "Initializing component...");
        
        let numberOfUsers = component.get("v.numberOfUsers");
        let action = component.get("c.getTopUsers");
        action.setParams({ numberOfUsers: numberOfUsers });
        console.log(
            "Number of users: ",
            numberOfUsers);
        
        action.setCallback(this, function (response) {
            let state = response.getState();
            console.log(
                "Number of users1: ",
                numberOfUsers);
            if (state === "SUCCESS") {
                console.log(
                    "Number of users2: ",
                    numberOfUsers);
                component.set("v.userList", response.getReturnValue());
                console.log(
                    "List of users: ",
                    response.getReturnValue());
            } else {
                console.error("Error: ", response.getError());
            }
        });
        $A.enqueueAction(action);
    }
});