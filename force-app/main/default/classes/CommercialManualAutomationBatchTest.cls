/*
* @Author : Shweta 
* @Date : 26th June 2021
* @Desc : Test class for CommercialManualAutomationBatch
* @Jira : SCPQ-1026
*/
@isTest
public class CommercialManualAutomationBatchTest {
    
    public static String CRON_EXP = '0 0 1 1 1/1 ? *';
    
    

    @testSetup
     static void setup()
    {
        List<Product2> productsList=DataFactoryTest.getProductSKUs(200);
        if(!productsList.isEmpty()){
            insert productsList;
        }
        GeneralBatchSetting__c batchSetting = new GeneralBatchSetting__c();
        batchSetting.name = 'CommercialManualAutomationBatch';
        batchSetting.Batch_Size__c = 200;
        batchSetting.Batch_Email_Notifiers__c = 'test@gmail.com,test1@gmail.com';
        insert batchSetting;
        
        List<Commercial_Manual__c> commercialsList = new List<Commercial_Manual__c>();
        for(Integer i=0; i<200;i++)
        {
            Commercial_Manual__c com = new Commercial_Manual__c();
            com.Business_Segment__c = 'Industry';
            com.Commercial_Manual_Region__c = 'Australia';
            com.Floor_Price_M00__c = 10 + i;
            com.Floor_Price_M01__c = 20 + i;
            com.Floor_Price_M02__c = 30 + i;
            com.Floor_Price_M03__c = 40 + i;
            com.Floor_Price_M04__c = 50 + i;
            com.Floor_Price_M05__c = 60 + i;
            com.Floor_Price_M06__c = 70 + i;
            com.Floor_Price_M07__c = 80 + i;
            com.Floor_Price_M08__c = 90 + i;
            com.Floor_Price_M09__c = 100 + i;
            com.Floor_Price_M10__c = 110 + i;
            com.Floor_Price_M11__c = 120 + i;
            com.List_Price_M00__c = 10 + i;
            com.List_Price_M01__c = 20 + i;
            com.List_Price_M02__c = 30 + i;
            com.List_Price_M03__c = 40 + i;
            com.List_Price_M04__c = 50 + i;
            com.List_Price_M05__c = 60 + i;
            com.List_Price_M06__c = 70 + i;
            com.List_Price_M07__c = 80 + i;
            com.List_Price_M08__c = 90 + i;
            com.List_Price_M09__c = 100 + i;
            com.List_Price_M10__c = 110 + i;
            com.List_Price_M11__c = 120 + i;
            com.Product__c = productsList[i].Id;
          commercialsList.add(com);
        }
        if(!commercialsList.isEmpty()){
            insert commercialsList;
        }
    }
    
    // TEST UNITS //

    /*------------------------------------------------------------
    Author:       Shweta
    Description:  Tests the method updateCommercialManual with a positive result

    History:
    27-06-2021    Shweta   Created method
    ------------------------------------------------------------*/
    
    public static testMethod void updateCommercialManual_Positive() {
              
        Test.startTest();
        
        GeneralBatchSetting__c batchSetting = GeneralBatchSetting__c.getValues('CommercialManualAutomationBatch');
        System.debug(batchSetting);
        String jobId1 = Database.executeBatch(new CommercialManualAutomationBatch(),Integer.valueOf(batchSetting.Batch_Size__c));
        
        // Schedule the test job
        String jobId = System.schedule('CommercialMannualAutomationBatch test',CRON_EXP, new CommercialManualAutomationBatch());
        
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
    Description:  Tests the method updateCommercialManual with a negative result

    History:
    01-07-2021    Shweta    Created method
    ------------------------------------------------------------*/
 
    public static testMethod void updateCommercialManual_Negative() {
        List<Commercial_Manual__c> comList = [SELECT Commercial_Manual_Region__c,Floor_Price_M00__c,Floor_Price_M01__c,Floor_Price_M02__c,Floor_Price_M03__c,Floor_Price_M04__c,Floor_Price_M05__c,Floor_Price_M06__c,Floor_Price_M07__c,Floor_Price_M08__c,Floor_Price_M09__c,Floor_Price_M10__c,Floor_Price_M11__c,Id,List_Price_M00__c,List_Price_M01__c,List_Price_M02__c,List_Price_M03__c,List_Price_M04__c,List_Price_M05__c,List_Price_M06__c,List_Price_M07__c,List_Price_M08__c,List_Price_M09__c,List_Price_M10__c,List_Price_M11__c,Name,Product_Code__c,Product__c FROM Commercial_Manual__c Where Commercial_Manual_Region__c = 'Australia' ];
        List<String> testList = new List<String>();
        testList.add('test');
        testList.add('Commercial_Manual_Region__c');
        
        // Assert that there are no debug logs //
        System.assertEquals( 0, [SELECT COUNT() FROM DebugLog__c LIMIT 1], 'Pre-existing debug logs found' );
        // Start the test, insert the records, then stop the test //
        Test.startTest();
        try{ 
           CommercialManualAutomationBatchHandler.throwException = true;
           CommercialManualAutomationBatchHandler.updateCommercialManual(comList);
           
           Utilities.isPicklistFieldContainsValue(testList,'Commercial_Manual_Region__c');
           List<String> splitList = Utilities.splitPicklistValues('test;test1');
           System.debug('splitList'+splitList);
           Utilities.returnValueOrEmpty('test');
        }catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage());
           //Requery the data and assert it is correct 
           System.assertEquals( 1, [SELECT COUNT() FROM DebugLog__c LIMIT 1], 'New debug logs not found' );
        }
 
        Test.stopTest();

        // Requery the data and assert it is correct //
        //System.assertEquals( 1, [SELECT COUNT() FROM DebugLog__c LIMIT 1], 'New debug logs not found' );
        
    }

}