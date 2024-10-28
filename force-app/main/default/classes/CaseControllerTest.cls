@isTest
public class CaseControllerTest {
  @testSetup
  static void setup(){
       Account acc = TestUtility.createAccount('TestAccount');
       insert acc;
      
       Account accCustomerLoc = TestUtility.createCustomerLocation('Test Customer Loc',acc);
       insert accCustomerLoc;
      
       Contact con = TestUtility.createContact(acc, accCustomerLoc);
       insert con;
      
       Case cs = TestUtility.createCase(con);
       cs.recordtypeid = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('QA_SALES').getRecordTypeId();
       cs.Type = 'Audit';
       cs.status = 'New';
       cs.Priority = 'Regular';
       cs.Business_Segment__c = 'Adult Nutrition';
       insert cs;
  }
  @isTest
  public static void testCaseNotification(){
       Case caseRecord = [SELECT Id FROM Case LIMIT 1];
       Test.startTest();
       Boolean result = CaseController.checkForCaseProducts(caseRecord.Id);
       system.assertEquals(true,result);
       Test.stopTest();       
  }
}