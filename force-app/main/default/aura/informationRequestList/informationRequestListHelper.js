({
    normalizeDateForPortal: function(dateValue) {
        if (!dateValue) return null;

        var parts = dateValue.split("-");
        var year = parseInt(parts[0], 10);
        var month = parseInt(parts[1], 10) - 1; 
        var day = parseInt(parts[2], 10);

        var utcDate = new Date(Date.UTC(year, month, day, 12, 0, 0)); 
        return utcDate;
    },
    getInfoRequestList: function (component) {
        console.log('getInfoRequestList start');
        var action = component.get("c.getInformationRequests");
        action.setParams({
            "limitSize": component.get("v.initRows"),
            "offset": component.get("v.offset")
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue() || []; // Ensure data is always an array

                if (!data || data.length === 0) {
                    console.log("No data found. Showing empty message.");
                    component.set("v.data", component.get("v.emptyData"));
                    component.set("v.Count", 0);
                    return;
                }

                var urlString = window.location.href;
                let communityBaseUrl = urlString.substring(0, urlString.indexOf("/s"));
                let self = this;
                data.forEach(record => {
                    record.recordLink = communityBaseUrl + "/s/information-request/" + record.Id;
                    if (record.Due_Date__c) {
                        var normalizedDate = self.normalizeDateForPortal(record.Due_Date__c);
                        if (normalizedDate) {
                            var options = { day: '2-digit', month: 'short', year: 'numeric' };
                            record.Due_Date__c = normalizedDate.toLocaleDateString('en-GB', options);
                        }
                    }
                });

                // Sorting data based on Due Date
                data.sort((a, b) => {
                    if (!a.Due_Date__c && b.Due_Date__c) return 1;
                    if (a.Due_Date__c && !b.Due_Date__c) return -1;
                    return b.Due_Date__c - a.Due_Date__c;
                });

                console.log('data : ', data);
                component.set("v.data", data);
                component.set("v.Count", data.length);
            } else {
                console.error("Error fetching data: ", response.getError());
                component.set("v.data", component.get("v.emptyData"));
                component.set("v.Count", 0);
            }
        });

        $A.enqueueAction(action);
    },

    totalInfoRequest: function (component) {
        var action = component.get("c.getInformationRequestCount");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultData = response.getReturnValue();
                console.log('resultData: ', resultData);
                component.set('v.totalResult', resultData);
                component.set('v.tableClass', resultData <= 5 ? "" : "slds-scrollable_y");
                component.set('v.tableStyle', resultData <= 5 ? "" : "height: 40vh;");
            }
        });

        $A.enqueueAction(action);
    }
});