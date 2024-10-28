/* *******************************************************************************************************
 * Name               : SRM_FeedItemTriggerHandlerTest                                                   *
 * Description        : SRM - Unit test for SRM_FeedItemTriggerHandler                                         *
 * Created By         : WAEG Pawel Kaca                                                                  *
 * Created Date       : 16/09/2020                                                                       *
 * ----------------------------------------------------------------------------------------------------- *
 * VERSION    AUTHOR                            DATE                                                     *
 *  1.0   -   WAEG Pawel Kaca                   16/09/2020          Initial version                      *
 ******************************************************************************************************* */
@IsTest
private class SRM_FeedItemTriggerHandlerTest {
    @TestSetup
    static void setup(){
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(null, true);
        Contact contact = TestUtils.newContact(new Contact(AccountId = supplierHub.Supplier_Account__c), true);
    }

    @IsTest
    static void testFeedItemReparent() {

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

        Test.startTest();
        System.runAs(testUser) {
            FeedItem fi = new FeedItem();
            fi.ParentId = account.Id;
            fi.Body = '<p>UT Test post to SH</p>';
            insert fi;
        }
        Test.stopTest();

        FeedItem fi = [SELECT Id, ParentId FROM FeedItem LIMIT 1];
        System.assertNotEquals(null, fi.Id);
        System.assertNotEquals(null, fi.ParentId);

//        Schema.DescribeSObjectResult dsr = Supplier_Hub__c.sObjectType.getDescribe();
//        String parentFeedItemId = (String) fi.ParentId;
//        System.assertEquals(false, parentFeedItemId.startsWith('001'));
//        System.assert(parentFeedItemId.startsWith(dsr.getKeyPrefix()));
    }
}