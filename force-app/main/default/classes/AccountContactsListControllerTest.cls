/**
 * Created by KJM on 03/07/2019.
 */

@isTest
public class AccountContactsListControllerTest {

    @testSetup
    static void setup() {
        Account parentAcc = TestUtility.createCommercialCustomer();
        insert parentAcc;

        Account childAcc = TestUtility.createCustomerLocation(parentAcc);
        insert childAcc;

        Account childAcc2 = TestUtility.createCustomerLocation(parentAcc);
        childAcc2.Name = 'IMCD France Spa';
        childAcc2.BillingCountry = 'France';
        childAcc2.BillingCountryCode = 'FR';
        insert childAcc2;

        List<Contact> contacts = new List<Contact>();
        Contact cont1 = TestUtility.createContact(parentAcc, childAcc);
        contacts.add(cont1);

        Contact cont2 = TestUtility.createContact(parentAcc, childAcc);
        contacts.add(cont2);

        Contact cont3 = TestUtility.createContact(parentAcc, childAcc2);
        contacts.add(cont3);

        insert contacts;
    }

    @isTest
    static void shouldReturnContactsForStandardUser() {
        CommunityUtility.communityOptionsInstance = TestUtility.getCommunityOptions();

        AccountContactsListController.MembersTableWrapper testTable;

        User usr = TestUtility.createPartnerPortalUser(
        'testKrzysUser@flc.com.test.PCU',
        [SELECT Id FROM Account WHERE Name = 'IMCD Holding'],
        [SELECT Id FROM Account WHERE Name = 'IMCD Italy Spa']);

        System.runAs(usr) {
            Test.startTest();

            testTable = AccountContactsListController.getTableData();

            Test.stopTest();
        }

        System.assertEquals(8, testTable.headerValues.size());
        System.assertEquals(2, testTable.bodyValues.size());
    }

    @isTest
    static void shouldReturnContactsForManagerUser() {
        CommunityUtility.communityOptionsInstance = TestUtility.getCommunityOptions();

        AccountContactsListController.MembersTableWrapper testTable;

        User usr = TestUtility.createPartnerPortalManagerUser(
        'testKrzysUser@flc.com.test.PCU',
        [SELECT Id FROM Account WHERE Name = 'IMCD Holding'],
        [SELECT Id FROM Account WHERE Name = 'IMCD Italy Spa']);

        System.runAs(usr) {
            Test.startTest();

            testTable = AccountContactsListController.getTableData();

            Test.stopTest();
        }

        System.assertEquals(9, testTable.headerValues.size());
        System.assertEquals(3, testTable.bodyValues.size());
    }
}