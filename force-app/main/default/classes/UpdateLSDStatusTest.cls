/**       
@Name           - UpdateLSDStatusTest
@Author         - Mahendra Kumar | Email - mahendra.kumar@frieslandcampina.com
@Version        - 1.0
@CreatedDate    - 26-07-2023

UserId              | Author-Email                        | Date       | Comment
====================|=====================================|============|==============
0058E000009TanLQAS  | mahendra.kumar@frieslandcampina.com | 26-07-2023 | Created class
--------------------|-------------------------------------|------------|--------------

* @description To test the logic invoked from the schedule-Triggered flow (Flow Name - Update LSD Status to Expired)
*/
@isTest
public class UpdateLSDStatusTest {
    @testSetup
    static void setupTestData(){
        List<Account> accList = new List<Account>();
        
        Account commercialCust = TestUtility.createCommercialCustomer('H1 IMCD Holding');
        insert commercialCust;
        
        Account custLoc = TestUtility.createCustomerLocation(commercialCust);
        accList.add(custLoc);
        
        Account custLoc2 = TestUtility.createCustomerLocation(commercialCust);
        custLoc2.Name = 'test cust loc 2';
        accList.add(custLoc2);
        
        insert accList;
        
        Legal_Sales_Document__c legalSales = TestUtility.getLegalInstance(commercialCust.Id, custLoc.Id,11000000);
        legalSales.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        insert legalSales;
        
        legalSales.LSD_Auto_Extension__c = 'Yes';
        legalSales.LSD_StartEffective_Date__c = system.today().addMonths(-13);
        legalSales.Initial_Term_of_LSD_In_Months__c = 12;
        legalSales.Termination_Notice_Period_In_Months__c = 1;
        legalSales.Status_of_LSD__c = 'LSD in Place';
        legalSales.SCAF_Approval_Status__c = 'Approved';
        legalSales.RecordTypeId = Schema.SObjectType.Legal_Sales_Document__c.getRecordTypeInfosByDeveloperName().get('LSD_Locked_Record_Type').getRecordTypeId();
        update legalSales;
        
        Legal_Sales_Document__c legalSales2 = TestUtility.getLegalInstance(commercialCust.Id, custLoc2.Id,11000000);
        legalSales2.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        insert legalSales2;
        
        legalSales2.LSD_Auto_Extension__c = 'Yes';
        legalSales2.LSD_StartEffective_Date__c = system.today().addMonths(-13);
        legalSales2.Initial_Term_of_LSD_In_Months__c = 12;
        legalSales2.Termination_Notice_Period_In_Months__c = 1;
        legalSales2.Status_of_LSD__c = 'LSD in Place';
        legalSales2.SCAF_Approval_Status__c = 'Approved';
        legalSales2.RecordTypeId = Schema.SObjectType.Legal_Sales_Document__c.getRecordTypeInfosByDeveloperName().get('LSD_Locked_Record_Type').getRecordTypeId();
        update legalSales2;
        
        custLoc2.Active__c = false;
        update custLoc2;
        
        Legal_Sales_Document__c lsd = new Legal_Sales_Document__c();
        lsd.Parent_Account__c =    commercialCust.Id;
        lsd.Account_Name__c = custLoc.Id;
        lsd.Business_Group__c = 'FCI';
        lsd.RecordTypeId = Schema.getGlobalDescribe().get('Legal_Sales_Document__c').getDescribe().getRecordTypeInfosByDeveloperName().get('LSD_Record_Type').getRecordTypeId();
        lsd.Leading_Business_Segment__c = 'Adult Nutrition';
        lsd.FC_Legal_Entity__c = 'FrieslandCampina Nederland B.V.';
        lsd.Deviations_from_RFC_LSD_Template__c = 'Without Deviations';
        lsd.Status_of_LSD__c = 'No LSD';
        insert lsd;
        
        lsd.Status_of_LSD__c = 'LSD in Place';
        lsd.LSD_StartEffective_Date__c = system.today().addMonths(-13);
        lsd.Initial_Term_of_LSD_In_Months__c = 12;
        lsd.Termination_Notice_Period_In_Months__c = 1;
        lsd.RecordTypeId = Schema.getGlobalDescribe().get('Legal_Sales_Document__c').getDescribe().getRecordTypeInfosByDeveloperName().get('LSD_Lock_Without_Deviation').getRecordTypeId();
        update lsd;
    }
    
    @isTest
    static void updateLSDsToExpiredTest(){
        
        Id lsdWithoutDeviationsExpired = Schema.SObjectType.Legal_Sales_Document__c.getRecordTypeInfosByDeveloperName().get('LSD_Without_Deviation_Expired').getRecordTypeId();
        Id lsdWithDeviationsExpired = Schema.SObjectType.Legal_Sales_Document__c.getRecordTypeInfosByDeveloperName().get('LSD_With_Deviation_Expired').getRecordTypeId();
        
        List<Account> accountsList = [SELECT Id, Name FROM Account WHERE Name = 'H1 IMCD Holding' OR Parent.Name = 'H1 IMCD Holding'];
        
        List<Legal_Sales_Document__c> lsdsToBeUpdated = new List<Legal_Sales_Document__c>();
        
        for(Legal_Sales_Document__c lsd : [SELECT Id, Name, RecordTypeId, Expiry_Termination_Date_Reached__c, Status_of_LSD__c,
                                                 RecordType.DeveloperName, Expired__c FROM Legal_Sales_Document__c 
                                               WHERE Account_Name__c IN: accountsList])
        {
            if(lsd.RecordType.DeveloperName == 'LSD_Locked_Record_Type'){
                lsd.RecordTypeId = lsdWithDeviationsExpired;
            }else if(lsd.RecordType.DeveloperName == 'LSD_Lock_Without_Deviation'){
                lsd.RecordTypeId = lsdWithoutDeviationsExpired;
            }
            lsd.Status_of_LSD__c = 'Expired';
            lsd.Expired__c = 'Yes';
            lsdsToBeUpdated.add(lsd);
        }
        
        List<SObjectDMLUtility.Request> requests = new List<SObjectDMLUtility.Request>();
        
        SObjectDMLUtility.Request req = new SObjectDMLUtility.Request();
        req.sObjectList = new List<SObject>();
        req.sObjectList.addAll(lsdsToBeUpdated);
        req.dmlType = 'UPDATE';
        req.objectLabel = 'Legal Sales Document';
        req.objectAPIName = 'Legal_Sales_Document__c';
        req.comments = 'Test';
        req.typeName = 'LSD Error';
        
        requests.add(req);
        
        Test.startTest();
        SObjectDMLUtility.performDML(requests);
        Test.stopTest();
        
        Legal_Sales_Document__c lsdErrorRecord = new Legal_Sales_Document__c();
        Boolean lsdsUpdated;

        for(Legal_Sales_Document__c lsd : [SELECT Id, Name, RecordTypeId, Expiry_Termination_Date_Reached__c, Status_of_LSD__c,
                                           Expired__c, Account_Name__r.Active__c, RecordType.Name FROM Legal_Sales_Document__c
                                           WHERE Account_Name__c IN: accountsList ORDER BY Account_Name__c])
        {
            if(lsd.Status_of_LSD__c == 'Expired' && lsd.Expired__c == 'Yes' && lsd.RecordType.Name.contains('Expired')){
                lsdsUpdated = true;
            }
        }

        Assert.areEqual(true, lsdsUpdated);
    }
}