/* *******************************************************************************************************
 * Name               : SRM_ContentVersionTriggerHandlerTest                                                 *
 * Description        : SRM - Test class for SRM_ContentVersionTriggerHandler.cls                                  *
 * Created Date       : 20-Aug-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       20-Aug-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
@IsTest
private class SRM_ContentVersionTriggerHandlerTest {

    @IsTest(SeeAllData=true)
    static void shouldPostToChatterJointBusinessPlan() {
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

        Test.stopTest();
    }

    @IsTest(SeeAllData=true)
    static void shouldPostToChatterRisk() {
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(null, true);
        Supplier_Category__c category = new Supplier_Category__c(Name = 'AEROSOLS & VALVES', IsActive__c =true);
        insert category;
        Risk__c objRisk = new Risk__c(Supplier__c = supplierHub.id,
                                      Risk_Title__c	= 'Test Risk title', 
                                      Classification_incident__c	= 'Quality', 
                                      Severity_assessment_date__c= date.today(),
                                      Visibility__c	= 'Joined', Category_Subgroup__c = category.id);
        insert objRisk;


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
        cdl.LinkedEntityId = objRisk.id;
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

        Test.stopTest();
    }

    @IsTest(SeeAllData=true)
    static void shouldPostToChatterSupplierHub() {
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(null, true);

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
        cdl.LinkedEntityId = supplierHub.id;
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

        Test.stopTest();
    }

    @IsTest(SeeAllData=true)
    static void shouldPostToChatterSupplierKPI() {
        Supplier_KPI__c supplierKPI = TestUtils.newSupplierKPI(null, true);

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
        cdl.LinkedEntityId = supplierKPI.id;
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

        Test.stopTest();
    }

}