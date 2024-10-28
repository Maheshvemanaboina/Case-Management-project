/* *******************************************************************************************************
 * Name               : SRM_SupplierHubFeedControllerTest                                                *
 * Description        : SRM - Uni test class for SRM_SupplierHubFeedController                                 *
 * Created By         : Waeg Pawel Kaca                                                                  *
 * Created Date       : 03/09/2020                                                                       *
 * ----------------------------------------------------------------------------------------------------- *
 * VERSION    AUTHOR                            DATE                                                     *
 *  1.0   -   Waeg Pawel Kaca                   03/09/2020          Initial version                      *
 ******************************************************************************************************* */
@IsTest
private class SRM_SupplierHubFeedControllerTest {
    @TestSetup
    static void setup(){
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(null, true);
        Contact contact = TestUtils.newContact(new Contact(AccountId = supplierHub.Supplier_Account__c), true);
    }

    @IsTest
    static void testLoggedUserSupplierHubId() {

        Account account = [SELECT Id FROM Account LIMIT 1];
        Contact userContact = [SELECT Id, AccountId FROM Contact WHERE AccountId != null LIMIT 1];

        User testUser = new User();
        testUser.Email = 'test@test.com';
        testUser.Username = 'sampletest' + Math.random() +'@testuser.com';
        testUser.contactId = userContact.Id;
        testUser.LastName = 'test';
        testUser.Alias = 'test';
        testUser.ProfileId = Utils.getProfileId(ConstUtils.PROFILE_NAME_SRM_CUSTOMER_COMMUNITY_PLUS);
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.TimeZoneSidKey = 'America/Chicago';
        testUser.EmailEncodingKey = 'UTF-8';
        insert testUser;

        String loggedUserSupplierHub;

        Test.startTest();
        System.runAs(testUser) {
            loggedUserSupplierHub = SRM_SupplierHubFeedController.getLoggedUserSupplierHubId();
        }
        Test.stopTest();

        System.assertNotEquals(null, loggedUserSupplierHub);
        System.assertNotEquals('', loggedUserSupplierHub);
    }
}