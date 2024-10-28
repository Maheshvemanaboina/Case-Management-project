/**
 * Created by KJM on 01/07/2019.
 */

@isTest
public with sharing class SendChatterMessageControllerTest {

    @isTest
    (SeeAllData=true)
    static void shouldCreateChatterDirectMessage() {
        TriggerHandler.skipTrigger = true;
        User usr = TestUtility.createPartnerPortalUserSeeAllData('testKrzysUser123@flc.com.test.PCU');
        TriggerHandler.skipTrigger = false;

        System.runAs(usr) {
            Test.startTest();

            Boolean availableForUser = SendChatterMessageController.isChatterAvailableForUser('Praneeth Krishna');
            System.assertEquals(true, availableForUser);

            String error = SendChatterMessageController.sendDirectChatterMessage('Praneeth Krishna', 'testSubj', 'testMess');
            System.assertEquals('', error);

            Test.stopTest();
        }
    }
}