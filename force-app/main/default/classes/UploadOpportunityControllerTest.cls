/**
 * Created by KJM on 25/06/2019.
 */

@isTest
public with sharing class UploadOpportunityControllerTest {

    @isTest(SeeAllData=true) // because of document, folders etc
    static void shouldReturnProperIds() {
        UploadOpportunityController.CsvTemplateWrapper oppTempIds;

        User usr = [SELECT Id FROM User WHERE Profile.Name = :Constants.TEST_FCI_DISTRIBUTOR_PROFILE AND IsActive = true LIMIT 1];
        System.runAs(usr) {
            Test.startTest();

            oppTempIds = UploadOpportunityController.getCsvTemplateIds();

            Test.stopTest();
        }
		
        System.assertEquals([SELECT Id FROM Document WHERE DeveloperName = :Constants.CSV_TEMPLATE_OPPORTUNITY_NON_LOCALE_DEVELOPER_NAME].Id, oppTempIds.nonLocalId);
        System.assertEquals([SELECT Id FROM Document WHERE DeveloperName = :Constants.CSV_TEMPLATE_OPPORTUNITY_LOCALE_DEVELOPER_NAME].Id, oppTempIds.localId);
        System.assertEquals([SELECT Id FROM Document WHERE DeveloperName = :Constants.CSV_TEMPLATE_OPPORTUNITY_NON_LOCALE_DEVELOPER_NAME].Id, oppTempIds.defaultId);
        
    }
}