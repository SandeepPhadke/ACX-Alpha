({    invoke : function(component, event, helper) {
   component.find("navigationService").navigate({ 
    type: "standard__webPage", 
    attributes: { 
        url: '/' 
    } 
});
}})