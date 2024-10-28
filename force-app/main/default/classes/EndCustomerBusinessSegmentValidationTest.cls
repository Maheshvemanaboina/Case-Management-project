/*      
@Name                  EndCustomerBusinessSegmentValidationTest
@Author                KJM
@ModifiedBy            Mahendra Kumar | Email - mahendra.kumar@frieslandcampina.com
@Version               1.0
@CreatedDate           23-09-2022
@UsedBy                
@Description           Test class for the EndCustomerBusinessSegmentValidation
@Changes
UserId           | Author-Email                   | Date           | Comment
================ |================================|================|=========
*/
@isTest
public class EndCustomerBusinessSegmentValidationTest {
    /* 
         * @Description Test setup to create some test records such as Accounts, Contacts, Users
         * @return void
	*/
    @testSetup
    public static void testData(){
        Account commercialCustIMCD = TestUtility.createAccount('IMCD Holding'); //Commercial customer test record
        insert commercialCustIMCD;
        
        Account customerLocIMCDItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCustIMCD); //Customer location test record
        insert customerLocIMCDItaly;
        
        Contact cItalySU = TestUtility.createContact(commercialCustIMCD, customerLocIMCDItaly); //Contact test record
        cItalySU.FirstName = 'Test Disti';
        cItalySU.LastName = 'Italy';
        insert cItalySU;
        
        User usrIMCDItalySU = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrIMCDItalySU.ContactId = cItalySU.Id;
        insert usrIMCDItalySU;
    }
    
    /* 
         * @Description Test method to test the validation of business segment while creating or updaitng end customer records
         * @return void
	*/
    @isTest
    public static void testEndCustomerBusinessSegmentValidation(){
        User imcdItalyDistiUser = [SELECT Id FROM User WHERE UserName LIKE '%TestIMCDItaly%'];//Distributor user
        Account commercialCustomer = [SELECT Id FROM Account WHERE Name LIKE '%IMCD Holding%'];//Commercial customer test record
        Account customerLocation = [SELECT Id FROM Account WHERE Name LIKE '%IMCD Italy Spa%'];//Customer location test record
        
        //start the test
        Test.startTest();
        //Insert and update the end customer records as Distributor community user
        system.runAs(imcdItalyDistiUser){
            List<Account> accountList = new List<Account>();
            Account acc = TestUtility.createEndCustomerAccount('Test End Customer no business segment');
            acc.Distributor_Location__c = customerLocation.Id;
            acc.Distributor__c = commercialCustomer.Id;
            accountList.add(acc);
            
            Account acc1 = TestUtility.createEndCustomerAccount('Test End Customer with business segment');
            acc1.Distributor_Location__c = customerLocation.Id;
            acc1.Distributor__c = commercialCustomer.Id;
            acc1.Business_Segment__c = 'Industry';
			insert acc1;
            
            //insert end customer and catch the validation error when the business segment of the end customer is null
            try{
                insert accountList;
            }catch(DMLException ex){
                system.assertEquals('Please ensure only one business segment is selected', ex.getDmlMessage(0));
            }
			
			//update the end customer and catch the validation error when more than one value is selected in the business segment            
            try{
                List<Account> endCustomerList = new List<Account>();
                Account endCustomer = new Account();
                endCustomer.Id = acc1.Id;
                endCustomer.Business_Segment__c = 'Food & Beverages;Adult Nutrition';
                endCustomerList.add(endCustomer);
                update endCustomerList;
            }catch(DMLException ex){
                system.assertEquals('Please ensure only one business segment is selected', ex.getDmlMessage(0));
            }
        }
        Test.stopTest();
    }
}