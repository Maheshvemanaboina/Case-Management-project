/**
 * Created by KJM on 25/06/2019.
 */

@isTest
public with sharing class UploadAccountControllerTest {

    @isTest(SeeAllData=true) // because of document, folders etc
    static void shouldReturnProperIds() {
        UploadAccountController.CsvTemplateWrapper accTempIds;

        User usr = [SELECT Id FROM User WHERE Profile.Name = :Constants.TEST_FCI_DISTRIBUTOR_PROFILE AND IsActive = true LIMIT 1];
        System.runAs(usr) {
            Test.startTest();

            accTempIds = UploadAccountController.getCsvTemplateIds();

            Test.stopTest();
        }

        //System.assertEquals([SELECT Id FROM Document WHERE DeveloperName = :Constants.CSV_TEMPLATE_ACCOUNT_LOCALE_DEVELOPER_NAME].Id, accTempIds.localId);
        System.assertEquals([SELECT Id FROM Document WHERE DeveloperName = :Constants.CSV_TEMPLATE_ACCOUNT_NON_LOCALE_DEVELOPER_NAME].Id, accTempIds.defaultId);
        System.assertEquals([SELECT Id FROM Document WHERE DeveloperName = :Constants.CSV_TEMPLATE_ACCOUNT_NON_LOCALE_DEVELOPER_NAME].Id, accTempIds.nonLocalId);
    }

}