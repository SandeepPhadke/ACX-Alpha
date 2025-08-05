({
    doInit : function(component, event, helper) {
        console.log('doInit start');
        component.set("v.columns", [
            {
                label: "Tasks",
                fieldName: "recordLink",
                type: "url",
                wrapText: true,
                typeAttributes: { label: { fieldName: "Name" }, target: "_self" }
            },
            { label: "Service", fieldName: "Work_Record_Name_Formula__c", type: "text", wrapText: true },
            { label: "Due Date", fieldName: "Due_Date__c", type: "text" }
        ]);
        helper.getInfoRequestList(component);
        helper.totalInfoRequest(component);       
    },
    LoadMore:function (component, event, helper) {
        console.log('LoadMore start');
        if(component.get("v.Count") < component.get('v.totalResult')){
            console.log('LoadMore');
            event.getSource().set("v.isLoading", true);
            var offSet = component.get("v.offset") + component.get("v.initRows");
            component.set("v.offset", offSet);
            console.log('offSet : '+offSet);
            var action = component.get("c.getInformationRequests");
            action.setParams({
                "limitSize": component.get("v.initRows"),
                "offset": offSet
            });
            action.setCallback(this, function(response) {          
                var state = response.getState();  
                console.log('state : ',state);
                if (state === "SUCCESS" ) {
                    var data = response.getReturnValue();
                    var urlString = window.location.href;
                    let communityBaseUrl = urlString.substring(0, urlString.indexOf("/s"));
                    data.forEach(record => {
                        record.recordLink = communityBaseUrl + "/s/information-request/" + record.Id;
                        if (record.Due_Date__c) {
                            var normalizedDate = helper.normalizeDateForPortal(record.Due_Date__c);
                            if (normalizedDate) {
                                var options = { day: '2-digit', month: 'short', year: 'numeric' };
                                record.Due_Date__c = normalizedDate.toLocaleDateString('en-GB', options);
                            }
                        }
                    });
                    console.log('data : ',data);
                    
                    
                    var currentdata = component.get('v.data');
                    currentdata = currentdata.concat(data); // This merges the two arrays
                    currentdata.sort((a, b) => {
                        const dateA = new Date(a.Due_Date__c);
                        const dateB = new Date(b.Due_Date__c);
    
                        if (!a.Due_Date__c && b.Due_Date__c) return 1; 
                        if (a.Due_Date__c && !b.Due_Date__c) return -1; 
                        return dateB - dateA; 
                    });
                    component.set('v.data', currentdata); 
                    event.getSource().set("v.isLoading", false);
                    console.log('data.length : '+data.length);
                    component.set("v.Count",currentdata.length);
                 }
            });
            $A.enqueueAction(action);
        }
        console.log('no LoadMore');
        event.getSource().set("v.isLoading", false);
    },
})