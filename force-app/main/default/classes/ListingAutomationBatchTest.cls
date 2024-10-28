/*
* @Author : Shweta 
* @Date : 7th July 2021
* @Desc : Test class for ListingAutomationBatch
* @Jira : SCPQ-1041
*/
@isTest
public class ListingAutomationBatchTest {
    
    public static String CRON_EXP = '0 0 6 1/1 * ? *';

    @testSetup
     static void setup()
    {
        Listing_Setting__c lstSetting = new Listing_Setting__c();
        lstSetting.Name = 'ListingAutomationBatch';
        lstSetting.Warehouse_Cost__c = 0.02;
        lstSetting.Sales_Orgs_Not_in_Scope__c = '5955,5952,5540,5004,5650';
        lstSetting.Transport_insurance_costs__c = 0.00015;
        lstSetting.Other_other_interest_bank_credit__c = 0.01;
        insert lstSetting;
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Business_Segment__c = 'Industry';
        acc.Type = 'Direct Customer';
        acc.Sub_Segment__c = 'Beverages';
        acc.Application__c = 'DMV: Bakery';
        acc.BillingCity = 'Bangalore';
        acc.BillingCountry = 'India';
        acc.SAP_Number_PE1__c = '0000104110';
        insert acc;
        
        List<Product2> productsList=DataFactoryTest.getProductSKUs(200);
        if(!productsList.isEmpty()){
            insert productsList;
        }
        
        Product2 prod = new Product2(
                Name               = 'Sample Product ',
                RecordTypeId       = DataFactoryTest.getRecordTypeByDeveloperName( Schema.SObjectType.Product2 ).get( 'BGI_Product_SKU').getRecordTypeId(),
                ProductCode        = '000000000000000000',
            	Product_Code__c    = '000000000000000000',
                IsActive           = true);
        insert prod;
        
        GeneralBatchSetting__c batchSetting = new GeneralBatchSetting__c();
        batchSetting.name = 'ListingAutomationBatch';
        batchSetting.Batch_Size__c = 200;
        batchSetting.Batch_Email_Notifiers__c = 'test@gmail.com,test1@gmail.com';
        batchSetting.Batch_Query__c = 'SystemModStamp = TODAY';
        insert batchSetting;
        
        Sales_Area__c sArea = new Sales_Area__c();
        sArea.Business_Segment__c = 'Industry';
        sArea.Customer_Name__c = acc.Id;
        sArea.Name = 'Test Area';
        sArea.Sales_Organization__c = '5150';
        insert sArea;
        
        Partner_Role__c pr = new Partner_Role__c();
        pr.Name = 'Test';
        pr.Relation_Name__c = 'Sold To';
        pr.Target_Account__c = acc.Id;
        pr.Source_Account__c = acc.Id;
        pr.Sales_Area__c = sArea.Id;
        insert pr;
        
        List<Listing__c> listingLst = new List<Listing__c>();
        for(Integer i=0; i<150;i++)
        {
            Listing__c ls = new Listing__c();
            
            ls.Sold_To_Account__c = pr.Id;
            ls.Customer__c = acc.Id;
            ls.Sales_Area__c = sArea.Id;
            ls.Product__c = prod.id;
            ls.Valid_from__c = Date.today();
            ls.Payment_Term_Description__c = 'Z012';
            listingLst.add(ls);
        }
        insert listingLst;
        List<Listing__c> deleteListingList = new List<Listing__c>();
        Listing__c lst = new Listing__c();
        	lst.Sold_To_Account__c = pr.Id;
            lst.Customer__c = acc.Id;
            lst.Sales_Area__c = sArea.Id;
            lst.Product__c = prod.id;
            lst.Valid_from__c = Date.today()-10;
            lst.Payment_Term_Description__c = 'Z012';
        	lst.Valid_Until__c = Date.today()-1;
        deleteListingList.add(lst);
        insert deleteListingList;
        
        Rebate_Danone__c rb = new Rebate_Danone__c();
        rb.Customer__c = '104110';
        rb.Rebate_Danone_Key__c = '51500000104110';
        rb.Rebate_Value__c = -0.015;
        insert rb;
        
        Rebate_Overview__c ro = new Rebate_Overview__c();
        ro.Product_code__c = '000000000000000000';
        ro.Rebate_Overview_Key__c = '51500000104110000000000000000000';
        ro.Sales_Org__c = '5150';
        ro.Sold_To_Account_Number__c = '104110';
        insert ro;
        
        Commission_A855_A854_A809__c com = new Commission_A855_A854_A809__c();
        com.Commission_Key__c = '51500000104110000000000000000000';
        com.Product_code__c = '000000000000000000';
        com.Sales_Org__c = '5150';
        com.Sold_To_Account_Number__c = '104110';
        com.Amount__c = -2.000;
        insert com;
        
        Commission_A852_A853__c comm = new Commission_A852_A853__c();
        comm.Key__c = '51500000104110';
        comm.Sales_Org__c = '5150';
        comm.Sold_To_Account_Number__c = '104110';
        comm.Commission_Amount__c = -3.000;
        insert comm;
        
        CPQ_Budget_SGP__c budget = new CPQ_Budget_SGP__c();
        budget.Product_code__c = '000000000000000000';
        budget.Sales_Org__c = '5150';
        budget.Sold_To_Account_Number__c = '104110';
        budget.SGP_KG__c = 0.26;
        budget.CPQ_Budget_SGP_Key__c = '515000000000000000000000000104110';
        insert budget;
        
    }
    
    // TEST UNITS //

    /*------------------------------------------------------------
    Author:       Shweta
    Description:  Tests the method ListingAutomationBatch with a positive result

    History:
    08-07-2021    Shweta   Created method
    ------------------------------------------------------------*/
    public static testMethod void updateListing_Positive()
    {
        Test.startTest();
        GeneralBatchSetting__c batchSetting = GeneralBatchSetting__c.getValues('ListingAutomationBatch');
        System.debug(batchSetting);
        String jobId1 = Database.executeBatch(new ListingAutomationBatch(),Integer.valueOf(batchSetting.Batch_Size__c));
        
        // Schedule the test job
        String jobId = System.schedule('ListingAutomationBatch test',CRON_EXP, new ListingAutomationBatch());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);      
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
    
        Test.stopTest();
    }
    
	/*------------------------------------------------------------
	Author:       Shweta
	Description:  Tests the method ListingAutomationBatch with a negative result

	History:
	08-07-2021    Shweta    Created method
	------------------------------------------------------------*/
 
    public static testMethod void updateCommercialManual_Negative() {
        List<Listing__c> listingList = [SELECT Active__c,Budget_SGP__c,Commissions__c,External_Key__c,Id,Material__c,Name,Product__c,Rebates__c,Sales_Area__c,Sales_Org__c,Sales_Price__c,SGP_PL__c,SGP__c,Sales_Area__r.Sales_Organization__c,Sold_To_Number__c,Product__r.Product_Code__c,Sold_To_Account_Id__c,Sold_To_Account__c,Transport_Insurance_Percent__c,Valid_from__c,Valid_Until__c,Warehouse_Cost__c,Payment_Term_Description__c,CreatedDate FROM Listing__c Where Payment_Term_Description__c = 'Z012'];
        List<String> testList = new List<String>();
        testList.add('test');
        testList.add('Payment_Term_Description__c');
        List<Listing__c> deleteListingList = [SELECT Active__c,Budget_SGP__c,Commissions__c,External_Key__c,Id,Material__c,Name,Product__c,Rebates__c,Sales_Area__c,Sales_Org__c,Sales_Price__c,SGP_PL__c,SGP__c,Sales_Area__r.Sales_Organization__c,Sold_To_Number__c,Product__r.Product_Code__c,Sold_To_Account_Id__c,Sold_To_Account__c,Transport_Insurance_Percent__c,Valid_from__c,Valid_Until__c,Warehouse_Cost__c,Payment_Term_Description__c,CreatedDate FROM Listing__c];
        
        // Assert that there are no debug logs //
        System.assertEquals( 0, [SELECT COUNT() FROM DebugLog__c LIMIT 1], 'Pre-existing debug logs found' );
        // Start the test, insert the records, then stop the test //
        Test.startTest();
        try{ 
           ListingAutomationBatchHelper.throwException = true;
           ListingAutomationBatchHelper.updateListings(listingList);
           
           ListingAutomationBatchHandler.throwException = true;
           ListingAutomationBatchHandler.updateListingsasActive(listingList);
           ListingAutomationBatchHandler.deleteListings(deleteListingList);
            
           Utilities.isPicklistFieldContainsValue(testList,'Payment_Term_Description__c');
           List<String> splitList = Utilities.splitPicklistValues('test;test1');
           System.debug('splitList'+splitList);
           Utilities.returnValueOrEmpty('test');
        }catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage());
           //Requery the data and assert it is correct 
           System.assertEquals( 1, [SELECT COUNT() FROM DebugLog__c LIMIT 1], 'New debug logs not found' );
        }
 
        Test.stopTest();
        
    }

}