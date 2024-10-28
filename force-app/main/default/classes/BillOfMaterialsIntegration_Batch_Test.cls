/*------------------------------------------------------------
Author:       Hugo Costa
Company:      waeg
Description:  Test class for BillOfMaterialsIntegration_DataHandler and BillOfMaterialsIntegration_Batch

History
v1.0       2019-10-29    Hugo Costa           Created batch class
v1.1       2019-12-03    Gianluca Calcagni    Included new unit test
------------------------------------------------------------*/
@isTest(isParallel=false)
private class BillOfMaterialsIntegration_Batch_Test {
    public static String CRON_EXP = '0 0 23 * * ?';


    @testSetup
    static void setup() {
        String randomVal = String.valueOf(Math.abs(Crypto.getRandomInteger()));

		List<Product2> testProduct2List  = DataFactoryTest.getProductSKUs(2);

        Product2 productSKU = testProduct2List[0] ;
        productSKU.Product_Code__c = '000000000000588389';
		productSKU.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get( 'BGI_Product_SKU' ).getRecordTypeId();
        productSKU.Sales_Organization_Number__c = '5080';
		productSKU.Business_Segment_Non_Restricted__c = 'Industry';
        productSKU.Base_Unit_of_Measure__c = 'KG';
		productSKU.SBQQ__OptionSelectionMethod__c = 'Click';
		productSKU.SBQQ__PricingMethod__c = 'List';
		productSKU.SBQQ__SubscriptionBase__c = 'List';
		productSKU.SBQQ__SubscriptionType__c = 'Renewable';
		productSKU.SBQQ__DefaultQuantity__c = 100000;
		productSKU.SBQQ__AssetConversion__c = 'One per quote line';
		productSKU.SBQQ__AssetAmendmentBehavior__c = 'Default';
		productSKU.SBQQ__BlockPricingField__c = 'Quantity';

		Product2 productSKU2 = testProduct2List[1] ;
        productSKU2.Product_Code__c = '000000000000561653';
		productSKU2.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get( 'Product_Material' ).getRecordTypeId();
        productSKU2.Sales_Organization_Number__c = '5032';
        productSKU2.Base_Unit_of_Measure__c = 'KG';
		productSKU2.SBQQ__PricingMethod__c = 'List';
		productSKU2.SBQQ__SubscriptionBase__c = 'List';
		productSKU2.SBQQ__SubscriptionType__c = 'Renewable';
		productSKU2.SBQQ__DefaultQuantity__c = 100000;
		productSKU2.SBQQ__AssetConversion__c = 'One per quote line';
		productSKU2.SBQQ__AssetAmendmentBehavior__c = 'Default';
		productSKU2.SBQQ__BlockPricingField__c = 'Quantity';
		productSKU2.Product_Hierarchy_Code__c = '160355410044145999';
		productSKU2.Hierarchy_1__c = 'Food / Nutrition ingredients';
		productSKU2.Hierarchy_2__c = 'Kievit supply (NOT USED)';
		productSKU2.Hierarchy_3__c = 'Vana Sana Others Encapsulates (NOT USED)';
		productSKU2.Hierarchy_4__c = 'Bag';
		productSKU2.Hierarchy_5__c = 'No packaging Size';
		productSKU2.Hierarchy_6__c = 'No flavour';

        insert testProduct2List;

		List<CPQ_Bill_Of_Material_SAP__c> bomList = new List<CPQ_Bill_Of_Material_SAP__c>();

		CPQ_Bill_Of_Material_SAP__c newBom1 = new CPQ_Bill_Of_Material_SAP__c();
		newBom1.Plant__c = '3061';
		newBom1.Plant_Name__c = 'Kievit Meppel' + randomVal;
		newBom1.Material__c = '000000000000588389';
		newBom1.Component__c = '000000000000561653';
		newBom1.Origin_Group__c = '1201';
		newBom1.External_Key__c = '000000000000588389-000000000000561653';
		newBom1.Price_Unit_for_Cost_Price__c = 10000;
		newBom1.Price_Unit_UoM__c = 'KG';
		newBom1.Quantity__c = 10;
		newBom1.Quantity_UoM__c = 'KG';
		newBom1.Standard_Price__c = 3618;
		newBom1.Standard_Qty__c = 10000;
		newBom1.Standard_Qty_UoM__c = 'KG';
		newBom1.Period_Year__c = '201910';
		newBom1.Market_Price_M00__c = 3594  ;
		newBom1.Purchase_Price_P00__c = 3606;
		newBom1.Market_Price_M01__c = 3595  ;
		newBom1.Purchase_Price_P01__c = 3607;
		newBom1.Market_Price_M02__c = 3596  ;
		newBom1.Purchase_Price_P02__c = 3608;
		newBom1.Market_Price_M03__c = 3597  ;
		newBom1.Purchase_Price_P03__c = 3609;
		newBom1.Market_Price_M04__c = 3598  ;
		newBom1.Purchase_Price_P04__c = 3610;
		newBom1.Market_Price_M05__c = 3599  ;
		newBom1.Purchase_Price_P05__c = 3611;
		newBom1.Market_Price_M06__c = 3600  ;
		newBom1.Purchase_Price_P06__c = 3612;
		newBom1.Market_Price_M07__c = 3601  ;
		newBom1.Purchase_Price_P07__c = 3613;
		newBom1.Market_Price_M08__c = 3602  ;
		newBom1.Purchase_Price_P08__c = 3614;
		newBom1.Market_Price_M09__c = 3603  ;
		newBom1.Purchase_Price_P09__c = 3615;
		newBom1.Market_Price_M10__c = 3604  ;
		newBom1.Purchase_Price_P10__c = 3616;
		newBom1.Market_Price_M11__c = 3605  ;
		newBom1.Purchase_Price_P11__c = 3617;
		newBom1.TECH_ToProcess__c = true;
		newBom1.TECH_QuantityChanged__c = true;

		bomList.add(newBom1);

		CPQ_Bill_Of_Material_SAP__c newBom2 = new CPQ_Bill_Of_Material_SAP__c();
		newBom2.Plant__c = '3061';
		newBom2.Plant_Name__c = 'Kievit Meppel' + randomVal;
		newBom2.Material__c = '000000000000588389';
		newBom2.Component__c = '#';
		newBom2.Origin_Group__c = '1201';
		newBom2.External_Key__c = '000000000000588389-#';
		newBom2.Price_Unit_for_Cost_Price__c = 10000;
		newBom2.Price_Unit_UoM__c = 'KG';
		newBom2.Quantity__c = 10;
		newBom2.Quantity_UoM__c = 'KG';
		newBom2.Standard_Price__c = 3618;
		newBom2.Standard_Qty__c = 10000;
		newBom2.Standard_Qty_UoM__c = 'KG';
		newBom2.Period_Year__c = '201910';
		newBom2.Market_Price_M00__c = 3594  ;
		newBom2.Purchase_Price_P00__c = 3606;
		newBom2.Market_Price_M01__c = 3595  ;
		newBom2.Purchase_Price_P01__c = 3607;
		newBom2.Market_Price_M02__c = 3596  ;
		newBom2.Purchase_Price_P02__c = 3608;
		newBom2.Market_Price_M03__c = 3597  ;
		newBom2.Purchase_Price_P03__c = 3609;
		newBom2.Market_Price_M04__c = 3598  ;
		newBom2.Purchase_Price_P04__c = 3610;
		newBom2.Market_Price_M05__c = 3599  ;
		newBom2.Purchase_Price_P05__c = 3611;
		newBom2.Market_Price_M06__c = 3600  ;
		newBom2.Purchase_Price_P06__c = 3612;
		newBom2.Market_Price_M07__c = 3601  ;
		newBom2.Purchase_Price_P07__c = 3613;
		newBom2.Market_Price_M08__c = 3602  ;
		newBom2.Purchase_Price_P08__c = 3614;
		newBom2.Market_Price_M09__c = 3603  ;
		newBom2.Purchase_Price_P09__c = 3615;
		newBom2.Market_Price_M10__c = 3604  ;
		newBom2.Purchase_Price_P10__c = 3616;
		newBom2.Market_Price_M11__c = 3605  ;
		newBom2.Purchase_Price_P11__c = 3617;
		newBom2.TECH_ToProcess__c = true;
		newBom2.TECH_QuantityChanged__c = true;

		bomList.add(newBom2);


		CPQ_Bill_Of_Material_SAP__c newBom3 = new CPQ_Bill_Of_Material_SAP__c();
		newBom3.Plant__c = '3061';
		newBom3.Plant_Name__c = 'Kievit Meppel' + randomVal;
		newBom3.Material__c = '000000000000588344';
		newBom3.Component__c = '#';
		newBom3.Origin_Group__c = '1201';
		newBom3.External_Key__c = '000000000000588344-#';
		newBom3.Price_Unit_for_Cost_Price__c = 10000;
		newBom3.Price_Unit_UoM__c = 'KG';
		newBom3.Quantity__c = 10;
		newBom3.Quantity_UoM__c = 'KG';
		newBom3.Standard_Price__c = 3618;
		newBom3.Standard_Qty__c = 10000;
		newBom3.Standard_Qty_UoM__c = 'KG';
		newBom3.Period_Year__c = '201910';
		newBom3.Market_Price_M00__c = 3594  ;
		newBom3.Purchase_Price_P00__c = 3606;
		newBom3.Market_Price_M01__c = 3595  ;
		newBom3.Purchase_Price_P01__c = 3607;
		newBom3.Market_Price_M02__c = 3596  ;
		newBom3.Purchase_Price_P02__c = 3608;
		newBom3.Market_Price_M03__c = 3597  ;
		newBom3.Purchase_Price_P03__c = 3609;
		newBom3.Market_Price_M04__c = 3598  ;
		newBom3.Purchase_Price_P04__c = 3610;
		newBom3.Market_Price_M05__c = 3599  ;
		newBom3.Purchase_Price_P05__c = 3611;
		newBom3.Market_Price_M06__c = 3600  ;
		newBom3.Purchase_Price_P06__c = 3612;
		newBom3.Market_Price_M07__c = 3601  ;
		newBom3.Purchase_Price_P07__c = 3613;
		newBom3.Market_Price_M08__c = 3602  ;
		newBom3.Purchase_Price_P08__c = 3614;
		newBom3.Market_Price_M09__c = 3603  ;
		newBom3.Purchase_Price_P09__c = 3615;
		newBom3.Market_Price_M10__c = 3604  ;
		newBom3.Purchase_Price_P10__c = 3616;
		newBom3.Market_Price_M11__c = 3605  ;
		newBom3.Purchase_Price_P11__c = 3617;
		newBom3.TECH_ToProcess__c = true;
		newBom3.TECH_QuantityChanged__c = true;

		bomList.add(newBom3);

		insert bomList;
    }


    public static testMethod void testProductDataSchedule() {
        Test.startTest();
        
        // Schedule the test job
        String jobId = System.schedule('BillOfMaterialsIntegration_Batch test',CRON_EXP, new BillOfMaterialsIntegration_Batch());
        //String jobId = Database.executeBatch(new BillOfMaterialsIntegration_Batch());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);      
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
		//System.assertEquals( 1, [SELECT COUNT() FROM CPQ_Bill_Of_Material_SAP__c WHERE TECH_ToProcess__c = TRUE], 'Errors found while processing the BOM' );
    }


    public static testMethod void testProductDataBatch() {
        Test.startTest();
        
        // Schedule the test job
        //String jobId = System.schedule('BillOfMaterialsIntegration_Batch test',CRON_EXP, new BillOfMaterialsIntegration_Batch());
        String jobId = Database.executeBatch(new BillOfMaterialsIntegration_Batch());
        
        // Get the information from the CronTrigger API object
        //CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        //System.assertEquals(CRON_EXP, ct.CronExpression);      
        // Verify the job has not run
        //System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
		System.assertEquals( 1, [SELECT COUNT() FROM CPQ_Bill_Of_Material_SAP__c WHERE TECH_ToProcess__c = TRUE], 'Errors found while processing the BOM' );
    }


    public static testMethod void testProductDataBatch_with_Existing_Features() {
		insert new SBQQ__ProductFeature__c(
			Name                           = 'Raw Materials',
			SBQQ__Category__c              = 'Bill of Materials',
			SBQQ__MinOptionCount__c        = 0,
			External_Key__c                = '000000000000588389-Raw Materials',
			SBQQ__ConfiguredSKU__r         = new Product2( Product_Code__c = '000000000000588389' ),
			SBQQ__Number__c                = 20
		);
		insert new SBQQ__ProductOption__c(
			SBQQ__Quantity__c      = 3,
			SBQQ__Number__c        = 4,
			SBQQ__ConfiguredSKU__r = new Product2( Product_Code__c = '000000000000588389' ),
			SBQQ__Feature__r       = new SBQQ__ProductFeature__c( External_Key__c = '000000000000588389-Raw Materials' ),
			SBQQ__OptionalSKU__r   = new Product2( Product_Code__c = '000000000000561653' ),
			External_Key__c        = '000000000000588389-000000000000561653-2'
		);

        Test.startTest();
        
        // Schedule the test job
        //String jobId = System.schedule('BillOfMaterialsIntegration_Batch test',CRON_EXP, new BillOfMaterialsIntegration_Batch());
        String jobId = Database.executeBatch(new BillOfMaterialsIntegration_Batch());
        
        // Get the information from the CronTrigger API object
        //CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        //System.assertEquals(CRON_EXP, ct.CronExpression);      
        // Verify the job has not run
        //System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
		System.assertEquals( 1, [SELECT COUNT() FROM CPQ_Bill_Of_Material_SAP__c WHERE TECH_ToProcess__c = TRUE], 'Errors found while processing the BOM' );
    }

	public static testMethod void testBOMData() {
        Test.startTest();
        
        // Test Validations rules
		List<CPQ_Bill_Of_Material_SAP__c> thisBOMList = [Select id,Quantity__c from CPQ_Bill_Of_Material_SAP__c];

		for(CPQ_Bill_Of_Material_SAP__c thisBom : thisBOMList){
			thisBom.Component__c = 'tested';
		}
        
		try{
			update thisBOMList;
		}catch(Exception e){
			System.assertEquals(true, e.getMessage().contains('match! Must be numeric of 18 digits or hashtag (#)'));
		}        
        Test.stopTest();
    }


    public static testMethod void testProductDataBatch_with_SKU_as_Component() {
        // Create some dirty data //
		upsert new Product2(
        	Product_Code__c = '000000000000561653',
			RecordTypeId    = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get( 'BGI_Product_SKU' ).getRecordTypeId()
		) Product_Code__c;

		// Check that a raw material is not present //
		System.assertEquals( 0, [SELECT COUNT() FROM Product2 WHERE Product_Code__c = 'RAW-000000000000561653'], 'Raw material created' );

        Test.startTest();
        // Schedule the test job
        //String jobId = System.schedule('BillOfMaterialsIntegration_Batch test',CRON_EXP, new BillOfMaterialsIntegration_Batch());
        String jobId = Database.executeBatch(new BillOfMaterialsIntegration_Batch());

        // Get the information from the CronTrigger API object
        //CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        //System.assertEquals(CRON_EXP, ct.CronExpression);      
        // Verify the job has not run
        //System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();      
		
		// Check that a raw material was created //
		System.assertEquals( 1, [SELECT COUNT() FROM Product2 WHERE Product_Code__c = 'RAW-000000000000561653' AND RecordTypeId = :Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get( 'Product_Material' ).getRecordTypeId()], 'Raw material not created' );
		System.assertEquals( 1, [SELECT COUNT() FROM CPQ_Bill_Of_Material_SAP__c WHERE TECH_ToProcess__c = TRUE], 'Errors found while processing the BOM' );
    }


    public static testMethod void testProductDataBatch_where_SKU_is_Component() {
        // Create some dirty data //
        String randomVal = String.valueOf(Math.abs(Crypto.getRandomInteger()));
		CPQ_Bill_Of_Material_SAP__c newBom4 = new CPQ_Bill_Of_Material_SAP__c();
		newBom4.Plant__c = '3061';
		newBom4.Plant_Name__c = 'Kievit Meppel' + randomVal;
		newBom4.Material__c = '000000000000588389';
		newBom4.Component__c = '000000000000588389';
		newBom4.Origin_Group__c = '1201';
		newBom4.External_Key__c = '000000000000588389-000000000000588389';
		newBom4.Price_Unit_for_Cost_Price__c = 10000;
		newBom4.Price_Unit_UoM__c = 'KG';
		newBom4.Quantity__c = 20;
		newBom4.Quantity_UoM__c = 'KG';
		newBom4.Standard_Price__c = 3618;
		newBom4.Standard_Qty__c = 10000;
		newBom4.Standard_Qty_UoM__c = 'KG';
		newBom4.Period_Year__c = '201910';
		newBom4.Market_Price_M00__c = 3594  ;
		newBom4.Purchase_Price_P00__c = 3606;
		newBom4.Market_Price_M01__c = 3595  ;
		newBom4.Purchase_Price_P01__c = 3607;
		newBom4.Market_Price_M02__c = 3596  ;
		newBom4.Purchase_Price_P02__c = 3608;
		newBom4.Market_Price_M03__c = 3597  ;
		newBom4.Purchase_Price_P03__c = 3609;
		newBom4.Market_Price_M04__c = 3598  ;
		newBom4.Purchase_Price_P04__c = 3610;
		newBom4.Market_Price_M05__c = 3599  ;
		newBom4.Purchase_Price_P05__c = 3611;
		newBom4.Market_Price_M06__c = 3600  ;
		newBom4.Purchase_Price_P06__c = 3612;
		newBom4.Market_Price_M07__c = 3601  ;
		newBom4.Purchase_Price_P07__c = 3613;
		newBom4.Market_Price_M08__c = 3602  ;
		newBom4.Purchase_Price_P08__c = 3614;
		newBom4.Market_Price_M09__c = 3603  ;
		newBom4.Purchase_Price_P09__c = 3615;
		newBom4.Market_Price_M10__c = 3604  ;
		newBom4.Purchase_Price_P10__c = 3616;
		newBom4.Market_Price_M11__c = 3605  ;
		newBom4.Purchase_Price_P11__c = 3617;
		newBom4.TECH_ToProcess__c = true;
		newBom4.TECH_QuantityChanged__c = true;

		insert newBom4;

        Test.startTest();
        // Schedule the test job
        //String jobId = System.schedule('BillOfMaterialsIntegration_Batch test',CRON_EXP, new BillOfMaterialsIntegration_Batch());
        String jobId = Database.executeBatch(new BillOfMaterialsIntegration_Batch());

        // Get the information from the CronTrigger API object
        //CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        //System.assertEquals(CRON_EXP, ct.CronExpression);      
        // Verify the job has not run
        //System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();      
		
		// Check that a raw material was created //
		System.assertEquals( 1, [SELECT COUNT() FROM Product2 WHERE Product_Code__c = 'RAW-000000000000588389' AND RecordTypeId = :Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get( 'Product_Material' ).getRecordTypeId()], 'Raw material not created' );
		System.assertEquals( 1, [SELECT COUNT() FROM CPQ_Bill_Of_Material_SAP__c WHERE TECH_ToProcess__c = TRUE], 'Errors found while processing the BOM' );
    }


    public static testMethod void testProductDataBatch_with_Self_BOM() {
        // Create some dirty data //
        String randomVal = String.valueOf(Math.abs(Crypto.getRandomInteger()));
		CPQ_Bill_Of_Material_SAP__c newBom4 = new CPQ_Bill_Of_Material_SAP__c();
		newBom4.Plant__c = '3061';
		newBom4.Plant_Name__c = 'Kievit Meppel' + randomVal;
		newBom4.Material__c = '000000000000588389';
		newBom4.Component__c = '000000000000588389';
		newBom4.Origin_Group__c = '1201';
		newBom4.External_Key__c = '000000000000588389-000000000000588389';
		newBom4.Price_Unit_for_Cost_Price__c = 10000;
		newBom4.Price_Unit_UoM__c = 'KG';
		newBom4.Quantity__c = 20;
		newBom4.Quantity_UoM__c = 'KG';
		newBom4.Standard_Price__c = 3618;
		newBom4.Standard_Qty__c = 10000;
		newBom4.Standard_Qty_UoM__c = 'KG';
		newBom4.Period_Year__c = '201910';
		newBom4.Market_Price_M00__c = 3594  ;
		newBom4.Purchase_Price_P00__c = 3606;
		newBom4.Market_Price_M01__c = 3595  ;
		newBom4.Purchase_Price_P01__c = 3607;
		newBom4.Market_Price_M02__c = 3596  ;
		newBom4.Purchase_Price_P02__c = 3608;
		newBom4.Market_Price_M03__c = 3597  ;
		newBom4.Purchase_Price_P03__c = 3609;
		newBom4.Market_Price_M04__c = 3598  ;
		newBom4.Purchase_Price_P04__c = 3610;
		newBom4.Market_Price_M05__c = 3599  ;
		newBom4.Purchase_Price_P05__c = 3611;
		newBom4.Market_Price_M06__c = 3600  ;
		newBom4.Purchase_Price_P06__c = 3612;
		newBom4.Market_Price_M07__c = 3601  ;
		newBom4.Purchase_Price_P07__c = 3613;
		newBom4.Market_Price_M08__c = 3602  ;
		newBom4.Purchase_Price_P08__c = 3614;
		newBom4.Market_Price_M09__c = 3603  ;
		newBom4.Purchase_Price_P09__c = 3615;
		newBom4.Market_Price_M10__c = 3604  ;
		newBom4.Purchase_Price_P10__c = 3616;
		newBom4.Market_Price_M11__c = 3605  ;
		newBom4.Purchase_Price_P11__c = 3617;
		newBom4.TECH_ToProcess__c = true;
		newBom4.TECH_QuantityChanged__c = true;

		insert newBom4;

		// Insert some existing features //
		insert new SBQQ__ProductFeature__c(
			Name                           = 'Raw Materials',
			SBQQ__Category__c              = 'Bill of Materials',
			SBQQ__MinOptionCount__c        = 0,
			External_Key__c                = '000000000000588389-Raw Materials',
			SBQQ__ConfiguredSKU__r         = new Product2( Product_Code__c = '000000000000588389' ),
			SBQQ__Number__c                = 20
		);
		insert new SBQQ__ProductOption__c(
			SBQQ__Quantity__c      = 3,
			SBQQ__Number__c        = 4,
			SBQQ__ConfiguredSKU__r = new Product2( Product_Code__c = '000000000000588389' ),
			SBQQ__Feature__r       = new SBQQ__ProductFeature__c( External_Key__c = '000000000000588389-Raw Materials' ),
			SBQQ__OptionalSKU__r   = new Product2( Product_Code__c = '000000000000561653' ),
			External_Key__c        = '000000000000588389-000000000000561653-2'
		);

        Test.startTest();
        
        // Schedule the test job
        //String jobId = System.schedule('BillOfMaterialsIntegration_Batch test',CRON_EXP, new BillOfMaterialsIntegration_Batch());
        String jobId = Database.executeBatch(new BillOfMaterialsIntegration_Batch());
        
        // Get the information from the CronTrigger API object
        //CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        //System.assertEquals(CRON_EXP, ct.CronExpression);      
        // Verify the job has not run
        //System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
		System.assertEquals( 1, [SELECT COUNT() FROM CPQ_Bill_Of_Material_SAP__c WHERE TECH_ToProcess__c = TRUE], 'Errors found while processing the BOM' );
    }



}