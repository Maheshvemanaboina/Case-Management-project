/* *******************************************************************************************************
 * Name               : LightningFileUploadHandler                                                       *
 * Description        : SRM - Controller for aura methods                                                      *
 * Created Date       : 25-07-2020                                                                       *
 * Created By         : Szymon Szczepański                                                               *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    sszcz              25-07-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
@IsTest
private class LightningFileUploadHandlerTest {

    @IsTest
    static void shouldGetFilesAndDelete() {
        Supplier_Category__c category = new Supplier_Category__c(Name = 'AEROSOLS & VALVES', IsActive__c =true);
        insert category;
        Joint_Business_Plan__c jointBusinessPlan = TestUtils.newJointBusinessPlan(null, false);
        jointBusinessPlan.Category_Subgroup__c= category.Id;
        insert jointBusinessPlan;

        Test.startTest();

        ContentVersion contentVersion = new ContentVersion(
                Title = 'Waeg',
                PathOnClient = 'Waeg.jpg',
                VersionData = Blob.valueOf('Test Waeg Content'),
                IsMajorVersion = true
        );
        insert contentVersion;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = jointBusinessPlan.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        contentVersion = new ContentVersion(
                Title = 'Waeg2',
                PathOnClient = 'Waeg2.jpg',
                VersionData = Blob.valueOf('Test Waeg Content2'),
                IsMajorVersion = true,
                ContentDocumentId = documents[0].Id
        );
        insert contentVersion;

        List<ContentDocument> contentDocuments = LightningFileUploadHandler.getFiles(jointBusinessPlan.Id);
        LightningFileUploadHandler.deleteThisFile(documents[0].Id);

        Test.stopTest();


        System.assert(!contentDocuments.isEmpty());
        System.assert([SELECT Id FROM ContentDocument WHERE Id =: documents[0].Id].isEmpty());

    }


    @IsTest(SeeAllData=true)
    static void shouldUpdateFileCategory() {
        List<LightningFileUploadHandler.SelectOptionWrapper> selectOptionWrappers = LightningFileUploadHandler.getCategoryOptions();

        Supplier_Category__c category = new Supplier_Category__c(Name = 'AEROSOLS & VALVES', IsActive__c =true);
        insert category;
        Joint_Business_Plan__c jointBusinessPlan = TestUtils.newJointBusinessPlan(null, false);
        jointBusinessPlan.Category_Subgroup__c= category.Id;
        insert jointBusinessPlan;

        ContentVersion contentVersion = new ContentVersion(
                Title = 'Waeg',
                PathOnClient = 'Waeg.jpg',
                VersionData = Blob.valueOf('Test Waeg Content'),
                IsMajorVersion = true
        );
        insert contentVersion;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = jointBusinessPlan.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        contentVersion = new ContentVersion(
                Title = 'Waeg2',
                PathOnClient = 'Waeg2.jpg',
                VersionData = Blob.valueOf('Test Waeg Content2'),
                IsMajorVersion = true,
                ContentDocumentId = documents[0].Id
        );
        insert contentVersion;

        Test.startTest();
        String properRecordId = LightningFileUploadHandler.getProperRecordId(jointBusinessPlan.Id);
        String category2 = selectOptionWrappers.get(1).value;
        try {
            LightningFileUploadHandler.updateFileCategory(jointBusinessPlan.Id, category2);
        } catch (Exception e) {}

        Test.stopTest();

        System.assertEquals(jointBusinessPlan.Id, properRecordId);        
    }



}