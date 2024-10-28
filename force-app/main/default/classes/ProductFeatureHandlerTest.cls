/*------------------------------------------------------------
Author:       Gianluca Calcagni
Company:      Waeg
Description:  Tests the class ProductFeatureHandler

History
2019-11-14    Gianluca Calcagni    Created test class
------------------------------------------------------------*/
@isTest
private class ProductFeatureHandlerTest {



    // TEST SETUP //

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Sets up sample data to be used for testing

    History:
    2019-11-14    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    @testSetup
    private static void testSetup() {
        // Disable all automations //
        Global_Automation_Setting__c setting = Global_Automation_Setting__c.getInstance();
        setting.Skip_Apex_Trigger__c    = true;
        setting.Skip_Process_Builder__c = true;
        setting.Skip_Validation_Rule__c = true;
        upsert setting;
        CpqDisableTriggers.cpqDisableTriggers();

        // Create some sample data //
        SBQQ__ProductRule__c productRule = new SBQQ__ProductRule__c(
            Name                     = CPQUtility.PRODUCT_RULE_NAME,
            SBQQ__Active__c          = true,
            SBQQ__ConditionsMet__c   = 'All',
            SBQQ__Scope__c           = 'Product',
            SBQQ__EvaluationEvent__c = 'Always',
            SBQQ__Type__c            = 'Filter'
        );
        insert productRule;
        SBQQ__ProductAction__c productAction = new SBQQ__ProductAction__c(
            SBQQ__Rule__c        = productRule.Id,
            SBQQ__Type__c        = 'Default Filter',
            SBQQ__FilterField__c = 'Product_Type_Developer_Name__c',
            SBQQ__Operator__c    = 'equals',
            SBQQ__FilterValue__c = 'Services'
        );
        insert productAction;
        
        Product2 product = new Product2(      
            Name               = 'Sample Product',
            RecordTypeId       = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Services').getRecordTypeId(),
            ProductCode        = 'Pro-1234',
            Family			   = 'Services',
            IsActive           = true
        );
        
        insert product;
                
        // Re-enable some automations //
        setting.Skip_Apex_Trigger__c    = false;
        setting.Skip_Process_Builder__c = false;
        setting.Skip_Validation_Rule__c = true;
        upsert setting;
        CpqEnableTriggers.cpqEnableTriggers();
    }



    // TEST UNITS //

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Tests the method createProductFeatures with a positive result

    History:
    2019-11-14    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    @isTest
    private static void createProductFeaturesTest_Positive() {
        // Initialise some new products //
        List<Product2> sampleProducts = DataFactoryTest.getProductSKUs( 200 );

        // Start the test, insert the records, then stop the test //
        Test.startTest();
        Database.insert( sampleProducts );
        Test.stopTest();

        // Requery the data and assert it is correct //
        List<SBQQ__ProductFeature__c> newFeatures = [SELECT Id FROM SBQQ__ProductFeature__c WHERE Name = :CPQUtility.PRODUCT_FEATURE_NAME AND SBQQ__ConfiguredSKU__c IN :sampleProducts LIMIT :(sampleProducts.size() + 1)];
        System.assertEquals( sampleProducts.size(), newFeatures.size(), 'Wrong number of new features' );
        List<SBQQ__ConfigurationRule__c> newConfigs = [SELECT Id FROM SBQQ__ConfigurationRule__c WHERE SBQQ__ProductFeature__c IN :newFeatures LIMIT :(sampleProducts.size() + 1)];
        System.assertEquals( sampleProducts.size(), newConfigs.size(), 'Wrong number of configuration rules' );
        
    }

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Tests the method createProductFeatures with a negative result

    History:
    2019-11-14    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    @isTest
    private static void createProductFeaturesTest_Negative() {
        // Initialise some new products //
        List<Product2> sampleProducts = DataFactoryTest.getProductSKUs( 200 );

        // Start the test, insert the records, then stop the test //
        Test.startTest();
        ProductFeatureHandler.throwException = true;
        Database.insert( sampleProducts );
        Test.stopTest();

        // Requery the data and assert it is correct //
        System.assertEquals( 1, [SELECT COUNT() FROM DebugLog__c LIMIT 1], 'New debug logs not found' );
        List<SBQQ__ProductFeature__c> newFeatures = [SELECT Id FROM SBQQ__ProductFeature__c WHERE Name = :CPQUtility.PRODUCT_FEATURE_NAME AND SBQQ__ConfiguredSKU__c IN :sampleProducts LIMIT :(sampleProducts.size() + 1)];
        System.assertEquals( 0, newFeatures.size(), 'Wrong number of new features' );
        
    }



}