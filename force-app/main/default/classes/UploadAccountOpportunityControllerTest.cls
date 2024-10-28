/*************************************************************** KJM - 09/04/2019
 Name: UploadAccountOpportunityControllerTest
 ======================================================
 Purpose: Test class for UploadAccountOpportunityController
 ======================================================
***************************************************************/
@isTest
private class UploadAccountOpportunityControllerTest {

    @isTest(SeeAllData=true) // because of document, folders etc
    static void shouldReturnProperIds() {
        UploadAccountOpportunityController.CsvTemplateWrapper oppTempIds;
        UploadAccountOpportunityController.CsvTemplateWrapper accTempIds;

        User usr = [SELECT Id FROM User WHERE Profile.Name = :Constants.TEST_FCI_DISTRIBUTOR_PROFILE AND IsActive = true LIMIT 1];
        System.runAs(usr) {
            Test.startTest();

            accTempIds = UploadAccountOpportunityController.getCsvTemplateIds('Account');
            oppTempIds = UploadAccountOpportunityController.getCsvTemplateIds('Opportunity');

            Test.stopTest();
        }


        System.assertEquals([SELECT Id FROM Document WHERE DeveloperName = :Constants.CSV_TEMPLATE_ACCOUNT_LOCALE_DEVELOPER_NAME].Id, accTempIds.localId);
        System.assertEquals([SELECT Id FROM Document WHERE DeveloperName = :Constants.CSV_TEMPLATE_ACCOUNT_LOCALE_DEVELOPER_NAME].Id, accTempIds.defaultId);
        System.assertEquals([SELECT Id FROM Document WHERE DeveloperName = :Constants.CSV_TEMPLATE_ACCOUNT_NON_LOCALE_DEVELOPER_NAME].Id, accTempIds.nonLocalId);
        System.assertEquals([SELECT Id FROM Document WHERE DeveloperName = :Constants.CSV_TEMPLATE_OPPORTUNITY_LOCALE_DEVELOPER_NAME].Id, oppTempIds.localId);
        System.assertEquals([SELECT Id FROM Document WHERE DeveloperName = :Constants.CSV_TEMPLATE_OPPORTUNITY_LOCALE_DEVELOPER_NAME].Id, oppTempIds.defaultId);
        System.assertEquals([SELECT Id FROM Document WHERE DeveloperName = :Constants.CSV_TEMPLATE_OPPORTUNITY_NON_LOCALE_DEVELOPER_NAME].Id, oppTempIds.nonLocalId);
    }
}