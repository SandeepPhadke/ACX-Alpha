({
  redirectByProfile: function(component, prof) {
    let url = $A.get("$Label.c.Login_URL"); 

    if (prof === 'Client Portal') {
      url = $A.get("$Label.c.ACX_Client_Portal");
    } else if (prof === 'Assignee Portal') {
      url = $A.get("$Label.c.ACX_Assignee_Portal");
    }
    window.open(url, '_self');
  }
})