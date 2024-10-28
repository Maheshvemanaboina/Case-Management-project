@isTest
public class PartnerRoleShipToUpdate_BatchTest {
    
    @TestSetup
    static void setupData(){
        
        TriggerHandler.skipTrigger = true;

        List<Account> accsCustomLocToInsert = new List<Account>();
        Account commercialCust = TestUtility.createAccount('IMCD Holding');
        accsCustomLocToInsert.add(commercialCust);

        insert accsCustomLocToInsert;

        List<Account> accsToInsert = new List<Account>();
        Account customerLocItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCust);
        customerLocItaly.SAP_Number_PE1__c = '0000123456';
        accsToInsert.add(customerLocItaly);

        Account customerLocFrance = TestUtility.createCustomerLocation('IMCD France Spa', commercialCust);
        customerLocFrance.SAP_Number_PE1__c = '0000654321';
        accsToInsert.add(customerLocFrance);

        insert accsToInsert;

        List<Sales_Area__c> salesAreaToInsert = new List<Sales_Area__c>();
        Sales_Area__c sourceSalesArea = TestUtility.createSalesArea('FC Domo NL (5954) IMCD Italy', customerLocItaly, '5954 FC Domo NL', '5954', '01', '10');
        salesAreaToInsert.add(sourceSalesArea);

        Sales_Area__c targetSalesArea = TestUtility.createSalesArea('FC Domo NL (5954) IMCD France', customerLocFrance, '5954 FC Domo NL', '5954', '01', '10');
        salesAreaToInsert.add(targetSalesArea);

        Sales_Area__c sourceSalesAreaFail = TestUtility.createSalesArea('FC Domo NL (0001) IMCD Italy', customerLocItaly, '0001 FC Domo NL', '0001' /* Target not existing */, '01', '10');
        salesAreaToInsert.add(sourceSalesAreaFail);

        insert salesAreaToInsert;

        List<Partner_Role__c> partnerRolesToInsert = new List<Partner_Role__c>();
        Partner_Role__c partnerRoleEqual = TestUtility.createPartnerRole('IMCD Italy Operations', customerLocItaly, customerLocItaly, sourceSalesArea, '5954', 'WE');
        partnerRoleEqual.Target_Account_Sales_Area__c = sourceSalesArea.Id;
        partnerRolesToInsert.add(partnerRoleEqual);

        Partner_Role__c partnerRoleDiff = TestUtility.createPartnerRole('IMCD Italy - France Operations', customerLocFrance, customerLocItaly, sourceSalesArea, '5954', 'WE');
        partnerRoleDiff.Target_Account_Sales_Area__c = targetSalesArea.Id;
        partnerRolesToInsert.add(partnerRoleDiff);

        Partner_Role__c partnerRolefail = TestUtility.createPartnerRole('IMCD Italy - France Fail Operations', customerLocFrance, customerLocItaly, sourceSalesAreaFail, '0001', 'WE');
        partnerRolesToInsert.add(partnerRolefail);

        insert partnerRolesToInsert;

        TriggerHandler.skipTrigger = false;
    }

    @isTest
    static void salesAreaUpdateCheckSchedule(){

        // Start the test, schedule the batch, then stop the test //
        Test.startTest();
        String jobId = System.schedule(
            'PartnerRoleShipToUpdateScheduleTest',
            PartnerRoleShipToUpdate_Batch.CRON_EXP,
            new PartnerRoleShipToUpdate_Batch()
        );
        Test.stopTest();

        // Query the cron job trigger //
        CronTrigger cronTrigger = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];

        // Assert that the batch was scheduled //
        System.assertEquals( PartnerRoleShipToUpdate_Batch.CRON_EXP, cronTrigger.CronExpression );
    }

    @isTest
    static void salesAreaUpdateCheckBatch(){

        // Start the test, schedule the batch, then stop the test //
        Test.startTest();
        
        Database.executeBatch(new PartnerRoleShipToUpdate_Batch());

        Test.stopTest();

        Sales_Area__c sourceSalesArea = [SELECT Id, Name FROM Sales_Area__c WHERE Name = 'FC Domo NL (5954) IMCD Italy'];
        Sales_Area__c targetSalesArea = [SELECT Id, Name FROM Sales_Area__c WHERE Name = 'FC Domo NL (5954) IMCD France'];

        Partner_Role__c partnerRoleEqual = [SELECT Id, Sales_Area__c, Is_Recalculation_Required__c, Target_Account_Sales_Area__c FROM Partner_Role__c WHERE Name = 'IMCD Italy Operations'];

        System.assertEquals(partnerRoleEqual.Is_Recalculation_Required__c , false);
        System.assertEquals(partnerRoleEqual.Target_Account_Sales_Area__c , partnerRoleEqual.Sales_Area__c);
        System.assertEquals(partnerRoleEqual.Target_Account_Sales_Area__c , sourceSalesArea.Id);

        Partner_Role__c partnerRoleDiff = [SELECT Id, Sales_Area__c, Is_Recalculation_Required__c, Target_Account_Sales_Area__c FROM Partner_Role__c WHERE Name = 'IMCD Italy - France Operations'];

        System.assertEquals(partnerRoleDiff.Is_Recalculation_Required__c , false);
        System.assertNotEquals(partnerRoleDiff.Target_Account_Sales_Area__c , partnerRoleDiff.Sales_Area__c);
        System.assertEquals(partnerRoleDiff.Target_Account_Sales_Area__c , targetSalesArea.Id);
    }

    @isTest
    static void salesAreaUpdateFailureCheck(){

        // Start the test, schedule the batch, then stop the test //
        Test.startTest();
        
        Database.executeBatch(new PartnerRoleShipToUpdate_Batch());

        Test.stopTest();

        Partner_Role__c partnerRoleFail = [SELECT Id, Sales_Area__c, Is_Recalculation_Required__c, Target_Account_Sales_Area__c FROM Partner_Role__c WHERE Name = 'IMCD Italy - France Fail Operations'];

        System.assertEquals(partnerRoleFail.Is_Recalculation_Required__c , false);
        System.assert(partnerRoleFail.Target_Account_Sales_Area__c == NULL);
    }
}