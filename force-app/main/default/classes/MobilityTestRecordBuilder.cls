public class MobilityTestRecordBuilder {

    public Id recordId;
    public Schema.SObjectType objectType;
    public Map<String, String> fields;
    public Map<String, List<String>> childRecords;
    public Map<String, String> parentRecords; 
    public String objectString;
    
    public MobilityTestRecordBuilder(){
        this.childRecords = new Map<String, List<String>>();
        this.parentRecords = new Map<String, String>();
    }
    
    public MobilityTestRecordBuilder withRecordId(Id recordId){
        this.recordId = recordId;
        return this;
    }
    
    public MobilityTestRecordBuilder withObjectString(String objectString){
        this.objectString = objectString;
        return this;
    }
    
    public MobilityTestRecordBuilder withObjectType(Schema.SObjectType objectType){
        this.objectType = objectType;
        return this;
    }
    
    public MobilityTestRecordBuilder withFields(Map<String, String> fields){
        this.fields = fields;
        return this;
    }
    
    public MobilityTestRecordBuilder withChildRecords(String childRelationshipName, List<String> childRecords){
        this.childRecords.put(childRelationshipName, childRecords);
        return this;
    }
    
    public MobilityTestRecordBuilder withParentRecords(String parentRelationshipName, String parentRecord){
        this.parentRecords.put(parentRelationshipName, parentRecord);
        return this;
    }
    
    public MobilityTestRecord build(){
        return new MobilityTestRecord(this);
    }
   
}