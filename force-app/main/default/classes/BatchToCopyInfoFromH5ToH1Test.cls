/*       
@Name                  BatchToCopyInfoFromH5ToH1Test
@Author                Shoba Thummala + shoba.thummala@frieslandcampina.com
@Version               1
@CreatedDate           Febraury 10, 2021
@UsedBy                BatchToCopyInfoFromH5ToH1
@Description           TestClass for  BatchToCopyInfoFromH5ToH1
@Changes
UserId           | Author-Email                         | Date                | Comment
================ |======================================|=====================|=========
*/

@isTest
public class BatchToCopyInfoFromH5ToH1Test {
   //Create the testdata 
    @testSetup 
    static void setup(){
        List<Account> customerAccounts = new List<Account>();
        //Create CommercialCustomer Accounts
        Account parentAcc1 = TestUtility.createCommercialCustomer();
        parentAcc1.Name = 'First Account';
        customerAccounts.add(parentAcc1);
        Account parentAcc2 = TestUtility.createCommercialCustomer();
        parentAcc2.Name = 'Second Account';
        customerAccounts.add(parentAcc2);
        Account parentAcc3 = TestUtility.createCommercialCustomer();
        parentAcc3.Name = 'Third Account';
        customerAccounts.add(parentAcc3);
        Account parentAcc4 = TestUtility.createCommercialCustomer();
        parentAcc4.Name = 'Fourth Account';
        customerAccounts.add(parentAcc4);
        insert customerAccounts;

        List<Account> customerLocationAccounts = new List<Account>();
        //Add CustoimerLocations to the above created commercial customer accounts
        for(Account acc : customerAccounts){
            for(integer i = 1 ; i <= 3 ; i++){
                Account auxAcc = TestUtility.createCustomerLocation(acc);
                auxAcc.Name = auxAcc.Name + ' '+i;
                auxAcc.Partner_Role__c = 'Sold-to';
                auxAcc.Active__c = true;
                auxAcc.Business_Segment__c = 'Adult Nutrition'; 
                auxAcc.Sub_Segment__c = 'Active Nutrition';
                auxAcc.Application__c = 'Other';
                auxAcc.Sales_Region__c = 'EMEA';
                if(acc.Name=='First Account'){
                  auxAcc.Type='Distributor';  
                }
                else if(acc.Name=='Second Account'){
                  auxAcc.Type='Direct Customer';  
                }
                
                else if(acc.Name=='Third Account'){
                  auxAcc.Type='Distributor & Direct Customer';  
                }
                else {
                  auxAcc.Type=null;  
                }
                customerLocationAccounts.add(auxAcc);
            }
            
            
        }
        
        Account parentAcc5 = TestUtility.createCommercialCustomer();
        parentAcc5.Name = 'Fifth Account';
        insert parentAcc5;
        //Add CustoimerLocations to the above created commercial customer accounts
                Account auxAcc4 = TestUtility.createCustomerLocation(parentAcc5);
                auxAcc4.Name = auxAcc4.Name + ' '+4;
                auxAcc4.Type='Direct Customer';
                customerLocationAccounts.add(auxAcc4);
                Account auxAcc5 = TestUtility.createCustomerLocation(parentAcc5);
                auxAcc5.Name = auxAcc5.Name + ' '+5;
                auxAcc5.Type='Distributor & Direct Customer';
                customerLocationAccounts.add(auxAcc5);
                
            
           
            
        insert customerLocationAccounts;

        
    }

    static testmethod void test() {
      //Call the Batchclass and schedule it 
        Test.startTest();
            BatchToCopyInfoFromH5ToH1 sh1 = new BatchToCopyInfoFromH5ToH1();
            String sch = '0 0 23 * * ?'; 
            system.schedule('Test Territory Check', sch, sh1); 
            Test.stopTest();   
    }
}