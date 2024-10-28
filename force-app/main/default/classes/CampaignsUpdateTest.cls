@isTest
public class CampaignsUpdateTest {
  @testSetup
    static void setup(){
     String cmpRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('FCP_Campaign').getRecordTypeId();
     List<Campaign> Campaigns= new List<Campaign>();
     Campaign cmp = new Campaign(); 
     cmp.Business_Segment__c = 'Industry';
     cmp.Sub_Segment__c = 'Beverages';
     cmp.Name = 'test cmp1';
     cmp.StartDate = Date.today();
     cmp.EndDate = Date.today().addDays(30);
     cmp.RecordTypeId = cmpRecordTypeId;
     Campaigns.add(cmp);
     Campaign cmp1 = new Campaign(); 
     cmp1.Business_Segment__c = 'Industry';
     cmp1.Sub_Segment__c = 'Beverages';
     cmp1.Name = 'test cmp2';
     cmp1.StartDate = Date.today().addDays(-5);
     cmp1.EndDate = Date.today().addDays(30);
     cmp1.RecordTypeId = cmpRecordTypeId;
     Campaigns.add(cmp1);
     Campaign cmp2 = new Campaign(); 
     cmp2.Business_Segment__c = 'Industry';
     cmp2.Sub_Segment__c = 'Beverages';
     cmp2.Name = 'test cmp2';
     cmp2.StartDate = Date.today().addDays(-20);
     cmp2.EndDate = Date.today().addDays(-1);
     cmp2.RecordTypeId = cmpRecordTypeId;
     Campaigns.add(cmp2);
     insert Campaigns;
    }
    static testmethod void checkBatchForSendingReminderForExistingLsd() {
        test.startTest();
        CampaignsUpdater cu = new CampaignsUpdater();
        database.executeBatch(cu);
        test.stopTest();
    }
}