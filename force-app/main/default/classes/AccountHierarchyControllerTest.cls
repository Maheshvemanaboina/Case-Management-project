/**
 * AccountHierarchyControllerTest class is created to cover all test class scenarios of AccountHierarchyController class.
 * Created By :   Charan K.
 * Crated Date :  23/08/2024.
 */

@IsTest
public class AccountHierarchyControllerTest {
    @TestSetup
    static void accountData() {
        Account parentAccount = new Account( Name = 'Parent Account', BillingCity = 'San Francisco', BillingCountry = 'United States of America', SAP_Number__c = '12345' );
        insert parentAccount;
        Account parentAccount1 = new Account( Name = 'Parent Account1', BillingCity = 'San Francisco', BillingCountry = 'United States of America', ParentId = parentAccount.Id, SAP_Number__c = null );
        insert parentAccount1;
        Account childAccount1 = new Account( Name = 'ChildCKAccount 1', BillingCity = 'San Francisco', BillingCountry = 'United States of America', ParentId = parentAccount.Id, SAP_Number__c = '67890' );
        insert childAccount1;
        Account childAccount2 = new Account( Name = 'ChildVKAccount 2', BillingCity = 'San Francisco', BillingCountry = 'United States of America', ParentId = parentAccount.Id, SAP_Number__c = null );
        insert childAccount2;
        Account childAccount3 = new Account( Name = 'ChildCKVKAccount 3', BillingCity = 'Toronto', BillingCountry = 'Canada', ParentId = parentAccount.Id, SAP_Number__c = '54321' );
        insert childAccount3;
        Account childAccount4 = new Account( Name = 'ChildAIAccount 4', BillingCity = 'San Francisco', BillingCountry = 'United States of America', ParentId = parentAccount.Id, SAP_Number__c = '97890' );
        insert childAccount4;
        Account childAccount5 = new Account( Name = 'ChildAIAccount 5', BillingCity = 'San Francisco', BillingCountry = 'United States of America', SAP_Number__c = '9780', 
                                            Account_Plan_for_FCP_T20_KA_Name__c = 'Test Plan', Account_Plan_for_FCP_T20_KA__c = 'http://testplan.com', ParentId = parentAccount1.Id );
        insert childAccount5;
    }

     @IsTest
    static void testGetChildAccounts() {
        Account childAccount = [SELECT Id,BillingCountry,ParentId FROM Account WHERE Name = 'ChildCKAccount 1' LIMIT 1];
        List<Account> result = AccountHierarchyController.getChildAccounts(childAccount.Id);
    }
    @IsTest
    static void testGetChildAccounts1() {
        Account childAccount = [SELECT Id, ParentId FROM Account WHERE Name = 'Parent Account' LIMIT 1];
        List<Account> result = AccountHierarchyController.getChildAccounts(childAccount.Id);
    }
    @IsTest
    static void testGetChildAccounts2() {
        Account childAccount = [SELECT Id,BillingCountry,ParentId FROM Account WHERE Name = 'ChildAIAccount 5' LIMIT 1];
        List<Account> result = AccountHierarchyController.getChildAccounts(childAccount.Id);
    }
    
    @IsTest
    static void testgetAccountDetails() {
        Account account = [SELECT Id FROM Account WHERE Name = 'ChildAIAccount 5' LIMIT 1];
        Account result = AccountHierarchyController.getAccountDetails(account.Id);
    }
    @isTest
    static void testUpdateAccount() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        AccountHierarchyController.updateAccount(account.Id, 'Updated Plan Name', 'http://updatedplanurl.com');
        Account updatedAccount = [SELECT Account_Plan_for_FCP_T20_KA_Name__c, Account_Plan_for_FCP_T20_KA__c FROM Account WHERE Id = :account.Id];
    }
}