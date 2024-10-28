/**
 * Created by KJM on 05/06/2019.
 */

@isTest
public with sharing class CaseListViewButtonsControllerTest {
    @isTest
    static void shouldReturnProperRecordTypes() {
        User usr = TestUtility.createPartnerPortalUser('testKrzysUser@flc.com.test.PCU', null);

        Integer count = 0;
        List<CaseListViewButtonsController.RTOptionsWrapper> optionWrappers;
        System.runAs(usr) {
            Test.startTest();

            optionWrappers = CaseListViewButtonsController.getRecordTypeList();

            Test.stopTest();

            for (RecordTypeInfo recordType: Case.SObjectType.getDescribe().getRecordTypeInfos()) {
                if (recordType.isAvailable() && recordType.Name != 'Master') {
                    count++;
                }
            }

        }

        System.assertEquals(count, optionWrappers.size());
    }

    @isTest
    static void shouldReturnProperUserInfo() {
        User usr = TestUtility.createPartnerPortalUser('testKrzysUser@flc.com.test.PCU', null);

        CaseListViewButtonsController.UserInfoWrapper userInfo;
        System.runAs(usr) {
            Test.startTest();

            userInfo = CaseListViewButtonsController.getUserInfo();

            Test.stopTest();
        }

        User commUser = [SELECT Id, ContactId, Contact.Parent_Account__c, Contact.AccountId FROM User WHERE Id =: usr.Id];
        System.assertEquals(commUser.ContactId, userInfo.ContactId);
        System.assertEquals(commUser.Contact.Parent_Account__c, userInfo.AccountId);
        System.assertEquals(commUser.Contact.AccountId, userInfo.WorkLocationId);
    }
}