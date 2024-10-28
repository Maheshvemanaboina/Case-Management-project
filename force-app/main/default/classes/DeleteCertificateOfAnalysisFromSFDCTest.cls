@isTest
public class DeleteCertificateOfAnalysisFromSFDCTest {

    @isTest
    public static void testDeletionOfCoA(){
        id recordTypeId = schema.SObjectType.Tile__c.getRecordTypeInfosByDeveloperName().get('Certificate_of_Analysis').getRecordTypeId();
        String sch = '0 0 23 * * ?';
        
        Tile__c tile1 = new Tile__c();
        tile1.Name ='CoA:DL00004';
        tile1.Delivery_Number__c ='DL00004';
        tile1.Sales_Order_Number__c ='';
        tile1.Purchase_Order_Number__c='';
        tile1.RecordTypeId=recordTypeId;
        insert tile1;
        
        ContentVersion cv = new ContentVersion();
        cv.PathOnClient='test.pdf';
        cv.VersionData =blob.valueOf('testCoA');
        cv.Title = 'CoA';
        insert cv;
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId =[SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.id ].ContentDocumentId;
        cdl.LinkedEntityId = tile1.id;
        insert cdl;
        
        Test.StartTest();
        ScheduleDeleteCertificateOfAnalysis scheduleDelete = new ScheduleDeleteCertificateOfAnalysis();
        System.schedule('TestDeleteSchedule', sch, scheduleDelete);
        Test.stopTest();
        
    }
}