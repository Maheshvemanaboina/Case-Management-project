@isTest
private class ScheduleUpdate_Test{
  
  @isTest
  static void ScheduleUpdate(){
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('QA_SALES').getRecordTypeId();

        Case c = new case();
        
        c.status = 'new';
        c.checkbox__c = false;
        c.recordtypeid = devRecordTypeId;
        insert c;
        
        c.status = 'On Hold';
        update c;
        ScheduleUpdate sh1 = new ScheduleUpdate(new list<case>{c});      
         String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
    }
}