/**
 * Created by KJM on 18/04/2019.
 */

@isTest
public class UploadAccountFromCSVTest {

    
    static Map<String, String> account1Values = new Map<String, String> {
            'Name' => 'IMCD Italy Spa',
            'Distributor_Location__c' => 'IMCD Italy Spa',
            'OwnerId' => 'no@email.com',
            'Distributor_Sales_Manager__c' => 'test@kvp.com',
            'Business_Segment__c' => 'Adult Nutrition',
            'Sub_Segment__c' => 'Active Nutrition',
            'Application__c' => 'Other',
            'BillingCountry' => 'Italy',
            'BillingStreet' => 'testStreet 1',
            'BillingPostalCode' => '20-2050',
            'BillingCity' => 'Bangalore',
            'Description' => 'testDescription',
            'RecordTypeId' => 'End Customer',
            'Skip_Distributor_Auto_Assignment__c' => 'true'
    };

    static Map<String, String> account2Values = new Map<String, String> {
            'Name' => 'testAccountKrzys',
            'Distributor_Location__c' => 'IMCD Italy Spa',
            'OwnerId' => 'no@email.com',
            'Distributor_Sales_Manager__c' => 'test@kvp.com',
            'Business_Segment__c' => 'Adult Nutrition',
            'Sub_Segment__c' => 'Active Nutrition',
            'Application__c' => 'Other',
            'BillingCountry' => 'Italy',
            'BillingStreet' => 'testStreet 1',
            'BillingPostalCode' => '20-2050',
            'BillingCity' => 'Bangalore',
            'Description' => 'testDescription',
            'RecordTypeId' => 'End Customer',
            'Skip_Distributor_Auto_Assignment__c' => 'true'
    };

    
    
    @isTest
      static void shouldCreateAccountFromCSVFile() {
        TriggerHandler.skipTrigger = true;
        Account comCust = TestUtility.createCommercialCustomer('IMCD Holding');
        insert comCust;

        Account custLoc = TestUtility.createCustomerLocation('IMCD Italy Spa',comCust);
        custLoc.Partner_Role__c = 'Sold-to;';
        insert custLoc;
        
        User usr = TestUtility.createPartnerPortalUser('testKrzysUser2@flc.com.test.PCU', comCust,custLoc);
        Contact cont = TestUtility.createContact('TestContact', 'Krzys',comCust,custLoc );
        insert cont; 
        
        System.runAs(usr) {
            Test.startTest();

            UploadAccountFromCSV UploadAcc = new UploadAccountFromCSV(new List<String>{getDataRow(account1Values)});
            UploadAcc.upsertData(Constants.CSV_UPSERT_OPTION_INSERT);

            Test.stopTest();
            TriggerHandler.skipTrigger = false;
        }

       
        Account accDB = [SELECT Id, Name, Distributor__r.Name, Distributor_Location__r.Name,Distributor_Sales_Manager__r.Name, Skip_Distributor_Auto_Assignment__c, Distributor_Sales_Manager__c,Business_Segment__c,Sub_Segment__c,Application__c, BillingCountry, BillingStreet, BillingPostalCode, BillingCountryCode, BillingCity, Sales_Region__c, Description, RecordTypeId FROM Account WHERE Name = 'IMCD Italy Spa' and BillingCity = 'Bangalore'];
        // should change fields values from Name to Id
        System.debug('accDB '+accDB);
        System.assertEquals([SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = :account1Values.get('RecordTypeId') LIMIT 1].Id, accDB.RecordTypeId);
        System.assertEquals([SELECT Id FROM Contact WHERE Email = :account1Values.get('Distributor_Sales_Manager__c') AND Name LIKE 'TestContact%'].Id, accDB.Distributor_Sales_Manager__c);
        //System.assertEquals([SELECT Id FROM Contact WHERE Name = :account1Values.get('Distributor_Sales_Manager__c')].Id, accDB.Distributor_Sales_Manager__c);
        //System.assertEquals([SELECT Id, Name FROM Account WHERE Name = :account1Values.get('Distributor__c')].Name, accDB.Distributor__r.Name);
        //System.assertEquals([SELECT Id, Name FROM Account WHERE Name = :account1Values.get('Distributor_Location__c')].Name, accDB.Distributor_Location__r.Name);

        // check all other field values
        account1Values.remove('Distributor__c');
        account1Values.remove('RecordTypeId');
        account1Values.remove('Distributor_Location__c');
        account1Values.remove('Distributor_Sales_Manager__c');
        account1Values.remove('Skip_Distributor_Auto_Assignment__c');
        account1Values.remove('OwnerId');
        for (String fieldName : account1Values.keySet()) {
            System.assertEquals(account1Values.get(fieldName), accDB.get(fieldName));
        }
    }
    

    @isTest
    static void shouldFindDuplicateAccount() {
        // prepare duplicate for account1Values
        Account comCust = TestUtility.createCommercialCustomer('IMCD Holding');
        insert comCust;

        Account custLoc = TestUtility.createCustomerLocation('IMCD Italy Spa',comCust);
        insert custLoc;

        Account basicAcc = TestUtility.createAccount('testAccountKrzys');
        basicAcc.put('Name', account2Values.get('Name'));
        basicAcc.put('Distributor_Location__c',custLoc.Id);
        basicAcc.put('BillingCountry', account2Values.get('BillingCountry'));
        basicAcc.put('BillingStreet', account2Values.get('BillingStreet'));
        basicAcc.put('BillingPostalCode', account2Values.get('BillingPostalCode'));
        basicAcc.put('BillingCity', account2Values.get('BillingCity'));
        basicAcc.put('RecordTypeId', Constants.ACCOUNT_RECORD_TYPE_END_CUSTOMER_ID);
        insert basicAcc;

        List<UploadObjectFromCSV.ErrorWrapper> errors;
        User usr = TestUtility.createPartnerPortalUser('testKrzysUser2123@flc.com.test.PCU', comCust,custLoc);
        System.runAs(usr) {
            Test.startTest();


            UploadAccountFromCSV UploadAcc = new UploadAccountFromCSV(new List<String>{ getDataRow(account2Values) });
            errors = UploadAcc.validateData();

            Test.stopTest();
        }

        System.assertEquals(Constants.ERROR_UPLOAD_TYPE_DUPLICATE, errors.get(0).type);
    }

    /*@isTest
    static void shouldValidatePicklistFields() {
        List<UploadObjectFromCSV.ErrorWrapper> errors;

        account1Values.put('Description', '');
        User usr = TestUtility.createPartnerPortalUser('testKrzysUser3@flc.com.test.PCU', null);
        System.runAs(usr) {
            Test.startTest();

            UploadAccountFromCSV UploadAcc = new UploadAccountFromCSV(new List<String>{getDataRow(account1Values)});
            errors = UploadAcc.validateData();

            Test.stopTest();
        }

        System.assertEquals(Constants.ERROR_UPLOAD_TYPE_MANDATORY, errors.get(0).type);
    }*/

    @isTest
    static void shouldInsertOnlyNewAccounts() {
        Account comCust = TestUtility.createCommercialCustomer('IMCD Holding');
        insert comCust;

        Account custLoc = TestUtility.createCustomerLocation('IMCD Italy Spa',comCust);
        custLoc.Partner_Role__c = 'Sold-to;';
        insert custLoc;
        

        User usr = TestUtility.createPartnerPortalUser('testKrzysUser4@flc.com.test.PCU', comCust ,custLoc);
        Contact cont = TestUtility.createContact('TestContact', 'Krzys',comCust,custLoc );
        insert cont;
        
        System.runAs(usr) {
            Test.startTest();

            UploadAccountFromCSV UploadAcc = new UploadAccountFromCSV(new List<String>{ getDataRow(account1Values), getDataRow(account2Values)  });
            UploadAcc.upsertData(Constants.CSV_UPSERT_OPTION_ONLY_NEW);

            Test.stopTest();
        }

        Account notOverwriteDB = [SELECT Id, Name, Distributor__c, Distributor_Location__c, Distributor_Sales_Manager__c, Skip_Distributor_Auto_Assignment__c, BillingCountry, BillingStreet, BillingPostalCode, BillingCountryCode, BillingCity, Sales_Region__c, Description, RecordTypeId FROM Account WHERE Name = :account1Values.get('Name') and BillingCity= 'Bangalore'];
        Account newDB = [SELECT Id, Name, Distributor__c, Distributor_Location__c, Distributor_Sales_Manager__c, Skip_Distributor_Auto_Assignment__c, BillingCountry, BillingStreet, BillingPostalCode, BillingCountryCode, BillingCity, Sales_Region__c, Description, RecordTypeId, RecordType.Name FROM Account WHERE Name = :account2Values.get('Name') and BillingCity= 'Bangalore'];

        // should do not overwrite account
        System.assertEquals('testDescription', notOverwriteDB.Description);

        // should change fields values from Name to Id
        System.assertEquals([SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = :account2Values.get('RecordTypeId') LIMIT 1].Name, newDB.RecordType.Name);
        System.assertEquals([SELECT Id FROM Contact WHERE Email = :account2Values.get('Distributor_Sales_Manager__c') AND Name LIKE 'TestContact%'].Id, newDB.Distributor_Sales_Manager__c);
        //System.assertEquals([SELECT Id FROM Contact WHERE Name = :account2Values.get('Distributor_Sales_Manager__c')].Id, newDB.Distributor_Sales_Manager__c);
        //System.assertEquals([SELECT Id FROM Account WHERE Name = :account2Values.get('Distributor__c')].Id, newDB.Distributor__c);
        //System.assertEquals([SELECT Id FROM Account WHERE Name = :account2Values.get('Distributor_Location__c')].Id, newDB.Distributor_Location__c);
        // check all other field values
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