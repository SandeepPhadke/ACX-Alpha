public with sharing class SubscribedOfficeFromCountryAction {

    @invocableMethod(label='Get Subscribed Office From Country')
    public static List<Response> SubscribedOfficeFromCountryAction(List<Request> requests) {
        List<Response> results = new List<Response>();

        for(Request r : requests){
            Response resp = new Response();
            Map<String, Subscribed_Offices__c> officeMap = makeOfficeMap(r.offices);
            
            if(officeMap.containsKey(r.countryName)){
                resp.subscribedOfficeId = officeMap.get(r.countryName).Id;
            } else {
                resp.subscribedOfficeId = null;
            }

            results.add(resp);
        }

        return results;
    }

    private static Map<String, Subscribed_Offices__c> makeOfficeMap(List<Subscribed_Offices__c> offices){
        Map<String, Subscribed_Offices__c> officeMap = new Map<String, Subscribed_Offices__c>();
        for(Subscribed_Offices__c office : offices){
            officeMap.put(office.Country__c, office);
        }

        return officeMap;
    }

    public class Request{
        @invocableVariable
        public List<Subscribed_Offices__c> offices;
        @invocableVariable
        public String countryName;
    }

    public class Response{
        @InvocableVariable(label = 'subscribed office id')
        public Id subscribedOfficeId;
    }
}