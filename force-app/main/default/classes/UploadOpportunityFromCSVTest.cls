/**
 * Created by KJM on 18/04/2019.
 */

@isTest
public class UploadOpportunityFromCSVTest {

    static Map<String, String> opportunity1Values = new Map<String, String> {
            'Name' => 'TestKrzysOpp',
            'End_Customer__c' => 'Test Acc Krzys 1',//Customer__c
            //'OwnerId' => 'testFNOwn testLNOwn',
            'OwnerId' => 'no@email.com',
            'Distributor_Sales_Manager__c' => 'test@kvp.com',
            'Business_Segment__c' =>'Adult Nutrition',
            'Sub_Segment__c' => 'Active Nutrition',
            'Opportunity_Application__c'=> 'Clear drinks',
            'Customer_Need__c' => 'Test Acc Krzys 1',
            'Probability' => '30',
            'CloseDate' => '10/12/2023',
            'CurrencyIsoCode' => 'USD',
            'Products_Description__c' => 'prodDesc',
            'Total_volume_per_deal__c' => '12345 KG',
            'RecordTypeId' => 'Partner Opportunity'
    };

    static Map<String, String> opportunity2Values = new Map<String, String> {
            'Name' => 'TestKrzysOpp2',
            'End_Customer__c' => 'Test Acc Krzys 1',//Customer__c
            //'OwnerId' => 'testFNOwn testLNOwn',
            'OwnerId' => 'no@email.com',
            'Distributor_Sales_Manager__c' => 'test@kvp.com',
            'Business_Segment__c' =>'Adult Nutrition',
            'Sub_Segment__c' => 'Active Nutrition',
            'Opportunity_Application__c'=> 'Clear drinks',
            'Customer_Need__c' => 'Test Acc Krzys 1',
            'Probability' => '30',
            'CloseDate' => '10/12/2023',
            'CurrencyIsoCode' => 'USD',
            'Products_Description__c' => 'prodDesc',
            'Total_volume_per_deal__c' => '12345 MG',
            'RecordTypeId' => 'Partner Opportunity'
    };

    @isTest
    static void shouldCreateOpportunity() {
        TriggerHandler.skipTrigger = true;
        User usr = setupDataAndReturnUser();
        //System.debug('Account Mirror REcords --> '+[SELECT Id,Name,Account__c,Account__r.Name from Account_Mirror__c]);
       
            system.debug('usr ' + usr);
			System.runAs(usr) {
                system.debug('usrid ' + UserInfo.getUserId());
                UploadOpportunityFromCSV uploadOpp = new UploadOpportunityFromCSV(new List<string>{getDataRow(opportunity1Values)});
                uploadOpp.upsertData(Constants.CSV_UPSERT_OPTION_INSERT);
             }

		 TriggerHandler.skipTrigger = false;
        Opportunity oppDB = [SELECT Id, External_Comments__c, Customer_Need__c, Owner.Name, OwnerId, Name, Customer__c,End_Customer__c, StageName, Probability, CloseDate, Description, RecordTypeId, CurrencyIsoCode, Products_Description__c, Total_volume_per_deal__c FROM Opportunity WHERE Name = :opportunity1Values.get('Name')];

        // should change fields values from Name to Id
        System.assertEquals([SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'Partner Opportunity' LIMIT 1].Id, oppDB.RecordTypeId);
        System.assertEquals([SELECT Id FROM Account WHERE Name = :opportunity1Values.get('End_Customer__c')].Id, oppDB.End_Customer__c);//Customer__c
        System.assertEquals(opportunity1Values.get('CurrencyIsoCode'), oppDB.CurrencyIsoCode);
        System.assertEquals(opportunity1Values.get('Products_Description__c'), oppDB.Products_Description__c);
        System.assertEquals(opportunity1Values.get('Total_volume_per_deal__c'), String.valueOf(oppDB.Total_volume_per_deal__c));
        System.assertEquals(opportunity1Values.get('External_Comments__c'), String.valueOf(oppDB.External_Comments__c));
        System.assertEquals(opportunity1Values.get('Customer_Need__c'), String.valueOf(oppDB.Customer_Need__c));
    }

   @isTest
    static void shouldUploadOpportunity() {
        User usr = setupDataAndReturnUser();
        System.runAs(usr) {
            TriggerHandler.skipTrigger = true;
            // insert opportunity
            UploadOpportunityFromCSV uploadOpp = new UploadOpportunityFromCSV(new List<string>{getDataRow(opportunity1Values)});
            //uploadOpp.upsertData(Constants.CSV_UPSERT_OPTION_INSERT);

            Test.startTest();

            // change opportunity value and upsert
            opportunity1Values.put('Description', 'testDescriptionOverwrited');
            uploadOpp = new UploadOpportunityFromCSV(new List<string>{getDataRow(opportunity1Values)});
            uploadOpp.upsertData(Constants.CSV_UPSERT_OPTION_WITH_OVERWRITE);
			TriggerHandler.skipTrigger = false;
            Test.stopTest();
        }

        Opportunity oppDB = [SELECT Id, External_Comments__c, Customer_Need__c, Owner.Name, OwnerId, Name, End_Customer__c, StageName, Probability, CloseDate, Description, RecordTypeId, CurrencyIsoCode, Products_Description__c, Total_volume_per_deal__c FROM Opportunity WHERE Name = :opportunity1Values.get('Name')];

        System.assertEquals([SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'Partner Opportunity' LIMIT 1].Id, oppDB.RecordTypeId);
        System.assertEquals([SELECT Id FROM Account WHERE Name = :opportunity1Values.get('End_Customer__c')].Id, oppDB.End_Customer__c);
        System.assertEquals(opportunity1Values.get('CurrencyIsoCode'), oppDB.CurrencyIsoCode);
        System.assertEquals(opportunity1Values.get('Products_Description__c'), oppDB.Products_Description__c);
        System.assertEquals(opportunity1Values.get('Total_volume_per_deal__c'), String.valueOf(oppDB.Total_volume_per_deal__c));
        System.assertEquals(opportunity1Values.get('External_Comments__c'), String.valueOf(oppDB.External_Comments__c));
        System.assertEquals(opportunity1Values.get('Customer_Need__c'), String.valueOf(oppDB.Customer_Need__c));

    }

    @isTest
    static void shouldUploadExistingAndInsertNewOpportunity() {
        User usr = setupDataAndReturnUser();
        System.runAs(usr) {
            Test.startTest();
            TriggerHandler.skipTrigger = true;
            // insert opportunity
            UploadOpportunityFromCSV uploadOpp = new UploadOpportunityFromCSV(new List<string>{getDataRow(opportunity1Values)});
            uploadOpp.upsertData(Constants.CSV_UPSERT_OPTION_INSERT);

            

            // change opportunity value and upsert
            opportunity1Values.put('Customer_Need__c', 'testCustomerNeedOverwrited');

            // should upload opportunity1 and insert opportunity2
            uploadOpp = new UploadOpportunityFromCSV(new List<string>{getDataRow(opportunity1Values) , getDataRow(opportunity2Values)});
            uploadOpp.upsertData(Constants.CSV_UPSERT_OPTION_WITH_OVERWRITE);

            Test.stopTest();
            TriggerHandler.skipTrigger = false;
        }

        Opportunity oppOverwritedDB = [SELECT Id, External_Comments__c, Customer_Need__c, Owner.Name, OwnerId, Name, End_Customer__c, StageName, Probability, CloseDate, Description, RecordTypeId, CurrencyIsoCode, Products_Description__c, Total_volume_per_deal__c FROM Opportunity WHERE Name = :opportunity1Values.get('Name')];
        Opportunity oppDB = [SELECT Id, External_Comments__c, Customer_Need__c, Owner.Name, OwnerId, Name, End_Customer__c, StageName, Probability, CloseDate, Description, RecordTypeId, CurrencyIsoCode, Products_Description__c, Total_volume_per_deal__c FROM Opportunity WHERE Name = :opportunity2Values.get('Name')];

        System.assertEquals('testCustomerNeedOverwrited', oppOverwritedDB.Customer_Need__c);

        // should change fields values from Name to Id
        System.assertEquals([SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'Partner Opportunity' LIMIT 1].Id, oppDB.RecordTypeId);
        System.assertEquals([SELECT Id FROM Account WHERE Name = :opportunity2Values.get('End_Customer__c')].Id, oppDB.End_Customer__c);

        // check all other field values
        System.assertEquals(opportunity2Values.get('CurrencyIsoCode'), oppDB.CurrencyIsoCode);
        System.assertEquals(opportunity2Values.get('Products_Description__c'), oppDB.Products_Description__c);
        System.assertEquals(opportunity2Values.get('Total_volume_per_deal__c'), String.valueOf(oppDB.Total_volume_per_deal__c));
        System.assertEquals(opportunity2Values.get('External_Comments__c'), String.valueOf(oppDB.External_Comments__c));
        System.assertEquals(opportunity2Values.get('Customer_Need__c'), String.valueOf(oppDB.Customer_Need__c));
    }

    @isTest
    static void shouldValidateMandatoryFields() {
        List<UploadObjectFromCSV.ErrorWrapper> errors;
        opportunity1Values.put('Customer_Need__c', '');

        User usr = setupDataAndReturnUser();
        System.runAs(usr) {
            Test.startTest();

            UploadOpportunityFromCSV uploadOpp = new UploadOpportunityFromCSV(new List<string>{getDataRow(opportunity1Values)});
            errors = uploadOpp.validateData();

            Test.stopTest();
        }

        System.assertEquals(Constants.ERROR_UPLOAD_TYPE_MANDATORY, errors.get(0).type);
    }

    /*@isTest
    static void shouldValidatePicklistFields() {
        List<UploadObjectFromCSV.ErrorWrapper> errors;
        opportunity1Values.put('Business_Segment__c', 'fakeBS');

        User usr = setupDataAndReturnUser();
        System.runAs(usr) {
            Test.startTest();

            UploadOpportunityFromCSV uploadOpp = new UploadOpportunityFromCSV(new List<string>{getDataRow(opportunity1Values)});
            errors = uploadOpp.validateData();

            Test.stopTest();
        }

        System.assertEquals(Constants.ERROR_UPLOAD_TYPE_VALUE, errors.get(0).type);
    }*/

   @isTest
    static void shouldFindDuplicateOpportunities() {
        
        TriggerHandler.skipTrigger = true;
        
        List<UploadObjectFromCSV.ErrorWrapper> errors;

        User usr = setupDataAndReturnUser();
        System.runAs(usr) {
            
            UploadOpportunityFromCSV uploadOpp = new UploadOpportunityFromCSV(new List<string>{getDataRow(opportunity1Values)});
            uploadOpp.upsertData(Constants.CSV_UPSERT_OPTION_INSERT);
			
            List<Opportunity> opplist = [SELECT Id, Name, Account.Name, Parent_Account__r.Name FROM Opportunity];
            
            Test.startTest();
			
            uploadOpp = new UploadOpportunityFromCSV(new List<string>{getDataRow(opportunity1Values)});
            errors = uploadOpp.validateData();

            Test.stopTest();
            TriggerHandler.skipTrigger = false;
            
        }
        
        System.assertEquals(Constants.ERROR_UPLOAD_TYPE_DUPLICATE, errors.get(0).type);
    }

    private static User setupDataAndReturnUser() {
        /*Account acc = TestUtility.createAccount('Test Acc Krzys 1');
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'End Customer' LIMIT 1].Id;
        insert acc;*/

        Pricebook2 prBook = TestUtility.createPriceBook('Creamy SKU Product List');
        insert prBook;

        /*User usrForOwner = TestUtility.createUser('testKrzysUser2@flc.com.test.PCU', 'System Administrator');
        usrForOwner.FirstName = 'testFNOwn';
        usrForOwner.LastName = 'testLNOwn';
        insert usrForOwner;*/

        Account commercialCust = TestUtility.createAccount('IMCD Holding test');
        commercialCust.Active__c=true;
        insert commercialCust;
        
        Account customerLocItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCust);
        customerLocItaly.Active__c=true;
        customerLocItaly.Partner_Role__c='Sold-to';
        insert customerLocItaly;
        
        Account accEndCust = TestUtility.createAccount('Test Acc Krzys 1');
        accEndCust.distributor__c = commercialCust.Id;
        accEndCust.Distributor_Location__c = customerLocItaly.Id;
        accEndCust.Active__c=true;
        accEndCust.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'End Customer' LIMIT 1].Id;
        insert accEndCust;
        
        //return TestUtility.createPartnerPortalUser('testKrzysUser1@flc.com.test.PCU', null);
        return TestUtility.createPartnerPortalUser('testKrzysUser1@flc.com.test.PCU', commercialCust,customerLocItaly);
    }

    private static String getDataRow(Map<String, String> accValues) {
        String row = '';
        for (String fieldValue : accValues.values()) {
            row += fieldValue + ';';
        }
        row = row.removeEnd(';');
        return row;
    }
}