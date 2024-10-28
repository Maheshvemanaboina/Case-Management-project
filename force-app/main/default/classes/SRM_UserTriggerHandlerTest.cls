/* *******************************************************************************************************
 * Name               : SRM_UserTriggerHandlerTest                                                       *
 * Description        : SRM - Test class for SRM_UserTriggerHandler.cls                                        *
 * Created Date       : 24-Aug-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       24-Aug-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
@IsTest
private class SRM_UserTriggerHandlerTest {

    @isTest
    static void shouldCreateShareRecords() {

        Supplier_Category__c category = new Supplier_Category__c(Name = 'AEROSOLS & VALVES', IsActive__c =true);
        insert category;
        Joint_Business_Plan__c jointBusinessPlan = TestUtils.newJointBusinessPlan(null, false);
        jointBusinessPlan.Category_Subgroup__c= category.Id;
        insert jointBusinessPlan;
        jointBusinessPlan = [SELECT Supplier_Hub__c, Supplier_Hub__r.Supplier_Account__c FROM Joint_Business_Plan__c WHERE Id = :jointBusinessPlan.Id];
        Supplier_Project__c supplierProject = TestUtils.newSupplierProject(new Supplier_Project__c(Supplier__c = jointBusinessPlan.Supplier_Hub__c, Type__c = ConstUtils.SUPPLIER_PROJECT_TYPE_EXTERNAL), true);

        Contact contact = TestUtils.newContact(new Contact(AccountId = jointBusinessPlan.Supplier_Hub__r.Supplier_Account__c), true);

        Test.startTest();

        User testUser = new User();
        testUser.Email = 'test@test.com';
        testUser.Username = 'sampletest@testuser.com';
        testUser.contactId = contact.Id;
        testUser.LastName = 'test';
        testUser.Alias = 'test';
        testUser.ProfileId = Utils.getProfileId(ConstUtils.PROFILE_NAME_SRM_CUSTOMER_COMMUNITY_PLUS);
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.TimeZoneSidKey = 'America/Chicago';
        testUser.EmailEncodingKey = 'UTF-8';
        insert testUser;

        Test.stopTest();
    }

}