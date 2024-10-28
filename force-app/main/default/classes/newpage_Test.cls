@isTest
private class newpage_Test{

 @istest
private static void testMethod1()
{
Account testAccount = new Account();
        testAccount.name = 'Test account 1';
        testAccount.SAP_Number_PE1__c = '0000101002';
        testAccount.BillingCountry = 'India';
        testAccount.BillingCity = 'Banglore';
 insert testAccount;

 Test.StartTest(); 
  ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
  newpage testAccPlan = new newpage(sc);
 Test.StopTest();
}
 @istest
private static void testMethod2()
{
Account testAccount1 = new Account();
        testAccount1.name = 'Test account 1';
        testAccount1.SAP_Number_PE1__c = '0000101002';
        testAccount1.BillingCountry = 'India';
        testAccount1.BillingCity = 'Banglore';
 insert testAccount1;
 
 List <Account> lstAccount = new List<Account>();
 
 Account testAccount = new Account();
 testAccount.Name='Test Ahnnj' ;
 testAccount.SAP_Number_PE1__c = '0000101045';
  testAccount.BillingCountry = 'Afghanistan';
  testAccount.BillingCity = 'Kabul';
 lstAccount.add(testAccount);
 
 insert  lstAccount;

 Test.StartTest(); 
  ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstAccount);
  stdSetController.setSelected(lstAccount);
  newpage  ext = new newpage (stdSetController);
Test.StopTest();
}
}