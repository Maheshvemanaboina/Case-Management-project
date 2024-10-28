/*       
@Name                  BatchToUpdateSalesAreaInfoToH5_Test
@Author                Vijay
@Version               1
@CreatedDate           April 26, 2021
@UsedBy                BatchToUpdateSalesAreaInfoToH5
@Description           TestClass for  BatchToUpdateSalesAreaInfoToH5
@Changes
UserId           | Author-Email                         | Date                | Comment
================ |======================================|=====================|=========
*/

@isTest
public class BatchToUpdateSalesAreaInfoToH5_Test {
    
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
        list<Sales_Area__c> salesAreas = new list<Sales_Area__c>();
        for(Account acc:customerLocationAccounts){
            Sales_Area__c sa1 = new Sales_Area__c(Name = 'test sales1'+acc.name,
                                    Customer_Name__c        = acc.id,
                                    //Customer_Group__c       = 'SM01 Modern Trade',
                                    Customer_Group__c       = 'Modern Trade',
                                   // Customer_Group_1__c     = 'DM Bakery',
                                    Customer_Group_1__c     = 'Bakery',
                                   // Customer_Group_2__c     = 'SM02 Medical',
                                    Customer_Group_2__c     = 'Medical',
                                    Sales_Group__c          = 'Test Sales',
                                    Active__c               = true,
                                    Business_Segment__c     = 'Industry'
                              );
            Sales_Area__c sa2 = new Sales_Area__c(Name = 'test sales2'+acc.name,
                                    Customer_Name__c        = acc.id,
                                    /*Customer_Group__c       = 'DM01 Out of Home',
                                    Customer_Group_1__c     = 'SM02 Savoury',
                                    Customer_Group_2__c     = 'SM01 Food', */
                                    Customer_Group__c       = 'Out of Home',
                                    Customer_Group_1__c     = 'Savoury',
                                    Customer_Group_2__c     = 'Food',
                                    Sales_Group__c          = 'Sales test2',
                                    Active__c               = true,
                                    Business_Segment__c     = 'Industry'
                              );
            salesAreas.add(sa1);
            salesAreas.add(sa2);
        }
        insert salesAreas;
        
        
    }
    
    static testmethod void BatchToUpdateH5Account(){
        test.startTest();
        list<account> accList = [SELECT Sales_Unit__c,Channel__c,Sub_Segment__c,Application_Group__c FROm Account];
        for(account acc:accList){
            acc.Sales_Unit__c = 'Sales test2';
            acc.Channel__c = 'Out of Home';
            acc.Sub_Segment__c = 'Medical Nutrition';
            acc.Application_Group__c = 'Savoury';
        }
        
        update accList;
        
        list<Sales_Area__c> salesList = [SELECT id FROM Sales_Area__c WHere Active__c=true];
        for(Sales_Area__c sa:salesList){
            sa.Active__c = false;
        }
        update salesList;
        
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch,new BatchToUpdateSalesAreaInfoToH5());
        
        test.stopTest();
    }
    
    static testmethod void BatchToUpdateH5Account2(){
        test.startTest();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch,new BatchToUpdateSalesAreaInfoToH5());
        test.stopTest();
        
    }

}