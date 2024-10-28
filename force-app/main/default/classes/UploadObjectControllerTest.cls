/**
* Created by KJM on 18/04/2019.
*/

@isTest
public with sharing class UploadObjectControllerTest {

    static Map<String, String> account1Values = new Map<String, String> {
            'Name' => 'testNewAccKrzys',
            'Distributor__c' => 'IMCD Holding',
            'Distributor_Location__c' => 'IMCD Italy Spa',
            'OwnerId' => 'first last',
            'Distributor_Sales_Manager__c' => 'TestContact Krzys',
            'BillingCountry' => 'Italy',
            'BillingStreet' => 'testStreet 1',
            'BillingPostalCode' => '20-2050',
            'BillingCity' => 'Bangalore',
            'Description' => 'testDescription'
    };

    static Map<String, String> opportunity1Values = new Map<String, String> {
            'Name' => 'TestKrzysOpp',
            'End_Customer__c' => 'Test Acc Krzys 1',
            'OwnerId' => 'first last',
            'Business_Segment__c' =>'Industry',
            'Sub_Segment__c' => 'Beverages',
            'Opportunity_Application__c'=> 'Instant Mixes - Chocolate',   
            'Customer_Need__c' => 'customerNeed',
            'Probability' => '30',
            'CloseDate' => '10/12/2019',
            'CurrencyIsoCode' => 'EUR',
            'Products_Description__c' => 'prodDesc',
            'Total_volume_per_deal__c' => '123.00'
            
    };

    @isTest
    static void shouldReturnDataTableOnValidateForAccount() {
        UploadObjectController.ValidatedDataWrapper validateData;

        User usr = TestUtility.createPartnerPortalUser('testKrzysUser6@flc.com.test.PCU', null);
        System.runAs(usr) {
            String base64Data ='TmFtZSxEaXN0cmlidXRvciBMb2NhdGlvbixPd25lcixEaXN0cmlidXRvciBTYWxlcyBNYW5hZ2VyLEJ1c2luZXNzIFNlZ21lbnQsU3ViLVNlZ21lbnQsQXBwbGljYXRpb24sQ291bnRyeSxTdHJlZXQsWmlwL1Bvc3RhbCxDaXR5LERlc2NyaXB0aW9uDQp0ZXN0S3J6eXMxNDYsSU1DRCBJdGFseSBTcGEsbm9AZW1haWwuY29tLFRlc3RDb250YWN0IEtyenlzLEFkdWx0IE51dHJpdGlvbixBY3RpdmUgTnV0cml0aW9uLENsZWFyIGRyaW5rcyxJdGFseSx0ZXN0U3RyZWV0IDEsMjA1MCxCYW5nYWxvcmUsdGVzdERlc2MNCg==';
            String objectAPIName = Constants.ACCOUNT_API_NAME;
            String csvFileType = Constants.CSV_FILE_TYPE_NON_LOCALE;
            String csvCreationOption = Constants.CSV_UPLOAD_FILE_CREATION_OPTION_TEMPLATE;
            Boolean wasChangeOnReport = false;

            Test.startTest();

            validateData = UploadObjectController.validateFileData(base64Data, objectAPIName, csvFileType, csvCreationOption, wasChangeOnReport);

            Test.stopTest();
        }
        System.debug('Account'+validateData.tableValues.get(0).objectName);
        System.assertEquals('Account', validateData.tableValues.get(0).objectName);
        System.assertEquals(12, validateData.tableValues.get(0).headerValues.size());
        System.assertEquals(1, validateData.tableValues.get(0).bodyValues.size());
        System.assertEquals(validateData.tableValues.get(0).bodyValues.get(0).fieldValues.size(), validateData.tableValues.get(0).headerValues.size());

        System.assertEquals(Account.Description.getDescribe().getLabel(), validateData.tableValues.get(0).headerValues.get(11));
    }

    @isTest
    static void shouldReturnDataTableOnValidateForOpportunity() {
        UploadObjectController.ValidatedDataWrapper validateData;

        User usr = insertProductsAndReturnUser();
        System.runAs(usr) {
            String base64Data ='T3Bwb3J0dW5pdHkgTmFtZSxBY2NvdW50IE5hbWUsU2FsZXMgTWFuYWdlciBEaXN0cmlidXRvcixEaXN0cmlidXRvciBTYWxlcyBNYW5hZ2VyLEJ1c2luZXNzIFNlZ21lbnQsU3ViLVNlZ21lbnQsQXBwbGljYXRpb24sQ3VzdG9tZXIgTmVlZHMsUHJvYmFiaWxpdHksQ2xvc2UgRGF0ZSxPcHBvcnR1bml0eSBDdXJyZW5jeSxQcm9kdWN0cyBEZXNjcmlwdGlvbixUb3RhbCB2b2x1bWUgcGVyIGRlYWwNClRlc3RLcnp5c09wcCxUZXN0IEFjYyBLcnp5cyAxLG5vQGVtYWlsLmNvbSx0ZXN0QGt2cC5jb20sQWR1bHQgTnV0cml0aW9uLEFjdGl2ZSBOdXRyaXRpb24sQ2xlYXIgZHJpbmtzLGN1c3RvbWVyTmVlZCwzMCwxMC8xMi8yMDE5LFVTRCx0ZXN0IHByb2QgZGVjLDE1MA==';
            String objectAPIName = Constants.OPPORTUNITY_API_NAME;
            String csvFileType = Constants.CSV_FILE_TYPE_NON_LOCALE;
            String csvCreationOption = Constants.CSV_UPLOAD_FILE_CREATION_OPTION_TEMPLATE;
            Boolean wasChangeOnReport = false;

            Test.startTest();

            validateData = UploadObjectController.validateFileData(base64Data, objectAPIName, csvFileType, csvCreationOption, wasChangeOnReport);
			System.debug('validateData '+validateData);
            Test.stopTest();
        }
	    //system.debug('validateData.tableValues.get(0).objectName'+validateData.tableValues.get(0).objectName);
        System.assertEquals('Opportunity', validateData.tableValues.get(0).objectName);
        System.assertEquals(13, validateData.tableValues.get(0).headerValues.size());
        System.assertEquals(1, validateData.tableValues.get(0).bodyValues.size());
       // System.assertEquals(validateData.tableValues.get(0).bodyValues.get(0).fieldValues.size(), validateData.tableValues.get(0).headerValues.size());
       // System.assertEquals(Opportunity.StageName.getDescribe().getLabel(), validateData.tableValues.get(0).headerValues.get(4));
        
        //System.assertEquals([SELECT Id, FCI_Opp_Stage_Name__c FROM Opportunity_Stage_Mapping__mdt WHERE Related_Account_Name__c = 'IMCD Holding' AND External_Opp_Stage_Probability__c = '50'].FCI_Opp_Stage_Name__c, (String)validateData.tableValues.get(0).bodyValues.get(0).fieldValues.get(4).fieldValue);
       // System.assertEquals([SELECT Id, FCI_Opp_Stage_Name__c FROM Opportunity_Stage_Mapping__mdt WHERE External_probability_greater_than__c = 25 and External_probability_less_than_equal_to__c = 50 ].FCI_Opp_Stage_Name__c, (String)validateData.tableValues.get(0).bodyValues.get(0).fieldValues.get(4).fieldValue);

    }

   /* @isTest
    static void shouldReturnDataTableOnValidateForOpportunityDirectFromReport() {
        UploadObjectController.ValidatedDataWrapper validateData;

        User usr = insertProductsAndReturnUser();
        System.runAs(usr) {
            
           // String base64Data = 'Ik9wcG9ydHVuaXR5IE5hbWUiOyJBY2NvdW50IE5hbWUiOyJTdGFnZSI7IlByb2JhYmlsaXR5IjsiQ2xvc2UgRGF0ZSI7Ik9wcG9ydHVuaXR5IEN1cnJlbmN5IjsiUHJvZHVjdHMgRGVzY3JpcHRpb24iOyJUb3RhbCB2b2x1bWUgcGVyIGRlYWwiOyJhc2QiDQoiVGVzdEtyenlzT3BwIjsiVGVzdCBBY2MgS3J6eXMgMSI7ImZpcnN0IGxhc3QiOyJjdXRvbWVyTmVlZDEiOyJFbmdhZ2VtZW50IjsiNTAiOyIxMC0xMi0yMDE5IjsiVVNEIjsidGVzdCBwcm9kIGRlc2MiOyIxNTAiOyJ0ZXN0IGFkZCBjb21tZW50Ig%3D%3D';
            String base64Data ='Ik9wcG9ydHVuaXR5IE5hbWUiOyJBY2NvdW50IE5hbWUiOyJTYWxlcyBNYW5hZ2VyIERpc3RyaWJ1dG9yIjsiQnVzaW5lc3MgU2VnbWVudCI7IlN1Yi1TZWdtZW50IjsiQXBwbGljYXRpb24iOyJDdXN0b21lciBOZWVkcyI7IlByb2JhYmlsaXR5IjsiQ2xvc2UgRGF0ZSI7Ik9wcG9ydHVuaXR5IEN1cnJlbmN5IjsiUHJvZHVjdHMgRGVzY3JpcHRpb24iOyJUb3RhbCB2b2x1bWUgcGVyIGRlYWwiDQoiVGVzdEtyenlzT3BwIjsiVGVzdCBBY2MgS3J6eXMgMSI7Im5vQGVtYWlsLmNvbSI7IkFkdWx0IE51dHJpdGlvbiI7IkFjdGl2ZSBOdXRyaXRpb24iOyJDbGVhciBkcmlua3MiOyJjdXN0b21lck5lZWQiOyIzMCI7IjEwLzEyLzIwMTkiOyJVU0QiOyJ0ZXN0IHByb2QgZGVzYyI7IjE1MCI=';
            String objectAPIName = Constants.OPPORTUNITY_API_NAME;
            String csvFileType = Constants.CSV_FILE_TYPE_LOCALE;
            String csvCreationOption = Constants.CSV_UPLOAD_FILE_CREATION_OPTION_REPORT;
            Boolean wasChangeOnReport = false;

            Test.startTest();

            validateData = UploadObjectController.validateFileData(base64Data, objectAPIName, csvFileType, csvCreationOption, wasChangeOnReport);

            Test.stopTest();
        }

        System.assertEquals('Opportunity', validateData.tableValues.get(0).objectName);
        System.assertEquals(12, validateData.tableValues.get(0).headerValues.size());
        System.assertEquals(1, validateData.tableValues.get(0).bodyValues.size());
        System.assertEquals(validateData.tableValues.get(0).bodyValues.get(0).fieldValues.size(), validateData.tableValues.get(0).headerValues.size());
      //  System.assertEquals(Opportunity.StageName.getDescribe().getLabel(), validateData.tableValues.get(0).headerValues.get(4));
		
       // System.assertEquals([SELECT Id, FCI_Opp_Stage_Name__c FROM Opportunity_Stage_Mapping__mdt WHERE External_probability_greater_than__c = 25 and External_probability_less_than_equal_to__c = 50].FCI_Opp_Stage_Name__c, (String)validateData.tableValues.get(0).bodyValues.get(0).fieldValues.get(4).fieldValue);

    }*/

    @isTest
    static void shouldUploadAccountWithoutError() {
        UploadObjectController.ValidatedDataWrapper validateData;

        User usr = TestUtility.createPartnerPortalUser('testKrzysUser7@flc.com.test.PCU', null);
        Contact cont = TestUtility.createContact('TestContact', 'Krzys', [SELECT Id FROM Account WHERE Name = 'IMCD Holding'], [SELECT Id FROM Account WHERE Name = 'IMCD Italy Spa']);
        insert cont;

        System.runAs(usr) {
            //String base64Data = 'TmFtZTtEaXN0cmlidXRvcjtEaXN0cmlidXRvciBMb2NhdGlvbjtPd25lcjtEaXN0cmlidXRvciBTYWxlcyBNYW5hZ2VyO0NvdW50cnk7U3RyZWV0O1ppcC9Qb3N0YWw7Q2l0eTtEZXNjcmlwdGlvbg0KdGVzdE5ld0FjY0tyenlzO0lNQ0QgSG9sZGluZztJTUNEIEl0YWx5IFNwYTtmaXJzdCBsYXN0O1Rlc3RDb250YWN0IEtyenlzO0l0YWx5O3Rlc3RTdHJlZXQgMTsyMC0yMDUwO0JhbmdhbG9yZTt0ZXN0RGVzYw%3D%3D';
            String base64Data = 'TmFtZSxEaXN0cmlidXRvciBMb2NhdGlvbixPd25lcixEaXN0cmlidXRvciBTYWxlcyBNYW5hZ2VyLEJ1c2luZXNzIFNlZ21lbnQsU3ViLVNlZ21lbnQsQXBwbGljYXRpb24sQ291bnRyeSxTdHJlZXQsWmlwL1Bvc3RhbCxDaXR5LERlc2NyaXB0aW9uDQp0ZXN0S3J6eXMxNDYsSU1DRCBJdGFseSBTcGEsbm9AZW1haWwuY29tLHRlc3RAa3ZwLmNvbSxBZHVsdCBOdXRyaXRpb24sQWN0aXZlIE51dHJpdGlvbixDbGVhciBkcmlua3MsSXRhbHksdGVzdFN0cmVldCAxLDIwNTAsQmFuZ2Fsb3JlLHRlc3REZXNjDQo=';
            String objectAPIName = Constants.ACCOUNT_API_NAME;
            String uploadOption = Constants.CSV_UPSERT_OPTION_INSERT;
            String csvFileType = Constants.CSV_FILE_TYPE_NON_LOCALE;
            String csvCreationOption = Constants.CSV_UPLOAD_FILE_CREATION_OPTION_TEMPLATE;
            Boolean wasChangeOnReport = false;

            Test.startTest();

            validateData = UploadObjectController.uploadFileData(base64Data, objectAPIName, uploadOption, csvFileType, csvCreationOption, wasChangeOnReport);

            Test.stopTest();
        }
       /* System.debug('Error'+validateData.errors);
        System.assertEquals(true, validateData.errors.isEmpty());
        System.assertEquals(null, validateData.tableValues);
        System.assertEquals(1, [SELECT Id FROM Account WHERE Name = 'testKrzys146'].size());*/
    }

    @isTest
    static void shouldUploadOpportunityWithoutError() {
        UploadObjectController.ValidatedDataWrapper validateData;

        User usr = insertProductsAndReturnUser();
        System.runAs(usr) {
           //original
           // String base64Data = 'T3Bwb3J0dW5pdHkgTmFtZTtBY2NvdW50IE5hbWU7U3RhZ2U7UHJvYmFiaWxpdHk7Q2xvc2UgRGF0ZTtPcHBvcnR1bml0eSBDdXJyZW5jeTtQcm9kdWN0cyBEZXNjcmlwdGlvbjtUb3RhbCB2b2x1bWUgcGVyIGRlYWw7YXNkDQpUZXN0S3J6eXNPcHA7VGVzdCBBY2MgS3J6eXMgMTtmaXJzdCBsYXN0O2N1dG9tZXJOZWVkMTtFbmdhZ2VtZW50OzUwOzEwLzEyLzIwMTk7VVNEO3Rlc3QgcHJvZCBkZXNjOzE1MDt0ZXN0IGFkZCBjb21tZW50';
           // String base64Data = 'T3Bwb3J0dW5pdHkgTmFtZTtBY2NvdW50IE5hbWU7T3duZXIgTmFtZTtDdXN0b21lciBOZWVkcztTdGFnZTtQcm9iYWJpbGl0eTtDbG9zZSBEYXRlO09wcG9ydHVuaXR5IEN1cnJlbmN5O1Byb2R1Y3RzIERlc2NyaXB0aW9uO1RvdGFsIHZvbHVtZSBwZXIgZGVhbDtFeHRlcm5hbCBDb21tZW50cw0KVGVzdEtyenlzT3BwO1Rlc3QgQWNjIEtyenlzIDE7bm9AZW1haWwuY29tO2N1dG9tZXJOZWVkMTtFbmdhZ2VtZW50OzUwOzEwLzEyLzIwMTk7VVNEO3Rlc3QgcHJvZCBkZXNjOzE1MDt0ZXN0IGFkZCBjb21tZW50';
            String base64Data ='T3Bwb3J0dW5pdHkgTmFtZSxBY2NvdW50IE5hbWUsU2FsZXMgTWFuYWdlciBEaXN0cmlidXRvcixEaXN0cmlidXRvciBTYWxlcyBNYW5hZ2VyLEJ1c2luZXNzIFNlZ21lbnQsU3ViLVNlZ21lbnQsQXBwbGljYXRpb24sQ3VzdG9tZXIgTmVlZHMsUHJvYmFiaWxpdHksQ2xvc2UgRGF0ZSxPcHBvcnR1bml0eSBDdXJyZW5jeSxQcm9kdWN0cyBEZXNjcmlwdGlvbixUb3RhbCB2b2x1bWUgcGVyIGRlYWwNClRlc3RLcnp5c09wcCxUZXN0IEFjYyBLcnp5cyAxLG5vQGVtYWlsLmNvbSx0ZXN0QGt2cC5jb20sQWR1bHQgTnV0cml0aW9uLEFjdGl2ZSBOdXRyaXRpb24sQ2xlYXIgZHJpbmtzLGN1c3RvbWVyTmVlZCwzMCwxMC8xMi8yMDE5LFVTRCx0ZXN0IHByb2QgZGVjLDE1MA==';
            String objectAPIName = Constants.OPPORTUNITY_API_NAME;
            String uploadOption = Constants.CSV_UPSERT_OPTION_INSERT;
            String csvFileType = Constants.CSV_FILE_TYPE_NON_LOCALE;
            String csvCreationOption = Constants.CSV_UPLOAD_FILE_CREATION_OPTION_TEMPLATE;
            Boolean wasChangeOnReport = false;

            Test.startTest();

            validateData = UploadObjectController.uploadFileData(base64Data, objectAPIName, uploadOption, csvFileType, csvCreationOption, wasChangeOnReport);

            Test.stopTest();
        }
		
        System.debug('validateData.errors '+validateData.errors);
       // System.assertEquals(true, validateData.errors.isEmpty());
        System.assertEquals(null, validateData.tableValues);

    }
    @isTest
    static void shouldUploadOpportunityWithError() {
        UploadObjectController.ValidatedDataWrapper validateData;

        User usr = insertProductsAndReturnUser();
        System.runAs(usr) {
           //original
           // String base64Data = 'T3Bwb3J0dW5pdHkgTmFtZTtBY2NvdW50IE5hbWU7U3RhZ2U7UHJvYmFiaWxpdHk7Q2xvc2UgRGF0ZTtPcHBvcnR1bml0eSBDdXJyZW5jeTtQcm9kdWN0cyBEZXNjcmlwdGlvbjtUb3RhbCB2b2x1bWUgcGVyIGRlYWw7YXNkDQpUZXN0S3J6eXNPcHA7VGVzdCBBY2MgS3J6eXMgMTtmaXJzdCBsYXN0O2N1dG9tZXJOZWVkMTtFbmdhZ2VtZW50OzUwOzEwLzEyLzIwMTk7VVNEO3Rlc3QgcHJvZCBkZXNjOzE1MDt0ZXN0IGFkZCBjb21tZW50';
           // String base64Data = 'T3Bwb3J0dW5pdHkgTmFtZTtBY2NvdW50IE5hbWU7T3duZXIgTmFtZTtDdXN0b21lciBOZWVkcztTdGFnZTtQcm9iYWJpbGl0eTtDbG9zZSBEYXRlO09wcG9ydHVuaXR5IEN1cnJlbmN5O1Byb2R1Y3RzIERlc2NyaXB0aW9uO1RvdGFsIHZvbHVtZSBwZXIgZGVhbDtFeHRlcm5hbCBDb21tZW50cw0KVGVzdEtyenlzT3BwO1Rlc3QgQWNjIEtyenlzIDE7bm9AZW1haWwuY29tO2N1dG9tZXJOZWVkMTtFbmdhZ2VtZW50OzUwOzEwLzEyLzIwMTk7VVNEO3Rlc3QgcHJvZCBkZXNjOzE1MDt0ZXN0IGFkZCBjb21tZW50';
            String base64Data ='T3Bwb3J0dW5pdHkgTmFtZSxBY2NvdW50IE5hbWUsU2FsZXMgTWFuYWdlciBEaXN0cmlidXRvcixCdXNpbmVzcyBTZWdtZW50LFN1Yi1TZWdtZW50LEFwcGxpY2F0aW9uLEN1c3RvbWVyIE5lZWRzLFByb2JhYmlsaXR5LENsb3NlIERhdGUsT3Bwb3J0dW5pdHkgQ3VycmVuY3ksUHJvZHVjdHMgRGVzY3JpcHRpb24sVG90YWwgdm9sdW1lIHBlciBkZWFsDQpUZXN0S3J6eXNPcHAsVGVzdCBBY2MgS3J6eXMgMSxub0BlbWFpbC5jb20sQWR1bHQgTnV0cml0aW9uLEFjdGl2ZSBOdXRyaXRpb24sQ2xlYXIgZHJpbmssY3VzdG9tZXJOZWVkLDMwLDEwLzEyLzIwMTksVVNELHRlc3QgcHJvZCBkZWMsMTUw';
            String objectAPIName = Constants.OPPORTUNITY_API_NAME;
            String uploadOption = Constants.CSV_UPSERT_OPTION_INSERT;
            String csvFileType = Constants.CSV_FILE_TYPE_NON_LOCALE;
            String csvCreationOption = Constants.CSV_UPLOAD_FILE_CREATION_OPTION_TEMPLATE;
            Boolean wasChangeOnReport = false;

            Test.startTest();

            validateData = UploadObjectController.uploadFileData(base64Data, objectAPIName, uploadOption, csvFileType, csvCreationOption, wasChangeOnReport);

            Test.stopTest();
            
            System.assertEquals(true, !(validateData.errors.isEmpty()));
        }
    }

    private static String getDataRow(Map<String, String> accValues) {
        String row = '';
        for (String fieldValue : accValues.values()) {
            row += fieldValue + ';';
        }
        row = row.removeEnd(';');
        return row;
    }

    private static User insertProductsAndReturnUser() {

        Account commercialCustIMCD = TestUtility.createAccount('IMCD Holding');
        insert commercialCustIMCD;

        Account customerLocIMCDItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCustIMCD);
        insert customerLocIMCDItaly;

        Account acc = TestUtility.createEndCustomerAccount('Test Acc Krzys 1');
        acc.Distributor__c = commercialCustIMCD.Id;
        acc.Distributor_Location__c = customerLocIMCDItaly.Id;
        //acc.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'End Customer' LIMIT 1].Id;
        insert acc;

        Product2 prod = TestUtility.createProduct('Allevo Forest Fruit Type 2 330ml');
        insert prod;

        PricebookEntry prb = TestUtility.createPricebookEntry(prod, Test.getStandardPricebookId());
        insert prb;

        Pricebook2 prBook = TestUtility.createPriceBook('Custom Pricebook');
        insert prBook;

        PricebookEntry prb3 = TestUtility.createPricebookEntry(prod, prBook.Id);
        insert prb3;

        Contact cItalySU = TestUtility.createContact(commercialCustIMCD, customerLocIMCDItaly);
        insert cItalySU;

        User usrIMCDItalySU = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrIMCDItalySU.ContactId = cItalySU.Id;
        insert usrIMCDItalySU;

        //return TestUtility.createPartnerPortalUser('testKrzysUser8@flc.com.test.PCU', null);
        return usrIMCDItalySU;
    }
}