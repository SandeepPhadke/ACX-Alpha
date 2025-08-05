@IsTest
 public class TestUtility {
     static Integer myNumber = 1;
 
     public static Id getFakeId(Schema.SObjectType sObjectType) {
         String result = String.valueOf(myNumber++);
         return (Id) (sObjectType.getDescribe().getKeyPrefix() +
         '0'.repeat(12 - result.length()) +
         result);
     } 
     
     public static String getDateString(Integer year, Integer month, Integer day) {
 
         Date newDate = Date.newInstance(year, month, day);
 
         String result = JSON.serialize(newDate);
 
         return result;
     }
     
     public static String getDateTimeString(Integer year, Integer month, Integer day, Integer hour, Integer minute, Integer second) {
 
         Datetime newDateTime = Datetime.newInstance(year, month, day, hour, minute, second);
 
         String result = JSON.serialize(newDateTime);
 
         return result;
     }
     
 }