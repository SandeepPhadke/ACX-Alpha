({
  invoke: function(component, event, helper) {
    const prof = component.get("v.profileName");
    helper.redirectByProfile(component, prof);
  }
})