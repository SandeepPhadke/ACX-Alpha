public class MobilityTestRecord {

    //do child records need to be able to understand the parent record Id??  should we automatically add it?  if so how?
    //would need to know the Id to set it
    //but trying to avoid setting it
    //maybe this gets implemented differently..
    //should I build records in the factory?
    //does the factory understand how to build the objects explicitly?
    
    Id recordId;
    Schema.SObjectType objectType;
    Map<String, String> fields;
    Map<String, List<String>> childRecords;
    Map<String, String> parentRecords; //field name e.g. Children__r, String that is actually a list of SObjects
    String objectString;
    
    public MobilityTestRecord(MobilityTestRecordBuilder builder){
		this.objectType = builder.objectType;
        this.recordId = builder.recordId ?? TestUtility.getFakeId(this.objectType);
        this.fields = builder.fields ?? null;
        this.childRecords = builder.childRecords ?? null;
        this.parentRecords = builder.parentRecords ?? null;
        this.objectString = builder.objectString ?? null;
        makeObject();
        addFields();
        addParentRecords();
        addChildRecords();
    }
    
    public String getObjectString(){
        return this.objectString;
    }
    
    private void makeObject(){
        String theObject = this.objectString ?? '{"Id":"'+this.recordId+'"}';
     	this.objectString = theObject;  
    }
    
    private void addFields(){
        System.debug('fields:'+this.fields);
        if(this.fields != null){
            String fieldMap = JSON.serialize(this.fields);
            fieldMap = fieldMap.removeEnd('}').removeStart('{');
            this.objectString = this.objectString.removeEnd('}') +', '+fieldMap+'}';
        }
    }
    
    private void addParentRecords(){
        if(this.parentRecords.keySet().size() > 0){
            for(String parentField : this.parentRecords.keySet()){
                String parentString = '"'+parentField+'"'+':'+this.parentRecords.get(parentField);
                addToObject(parentString);
            }
        }
    }
    
    private void addChildRecords(){
        if(this.childRecords.keySet().size() > 0){
            List<String> childRecordStrings = new List<String>();
            for(String childRelationship : this.childRecords.keySet()){
                List<String> childRecordList = this.childRecords.get(childRelationship);
                Integer totalSize = childRecordList.size();
                String records = String.join(childRecordList,',');
                childRecordStrings.add('"'+childRelationship+'":{"totalSize":"'+totalSize+'", "done":true, "records":['+records+']}');
            }
            String childRecordsString = String.join(childRecordStrings,',');
            addToObject(childRecordsString);
        }
    }
    
    private void addToObject(String additionalString){
        this.objectString = this.objectString.substringBeforeLast('}') + ', '+additionalString+'}';
    }
}