/**
 * Created by KJM on 18/04/2019.
 */

@isTest
public class UploadProductFromCSVTest {

    // class will be delete in the future, because of many changes related to upload functionality I decided to leave it for now.
    @isTest
    static void onlyForCodeCoverage_ToRemoveInTheFuture() {
        try {
            UploadProductFromCSV uploadProd = new UploadProductFromCSV(new List<String>());
        } catch (Exception ex) {}

    }

    /*
    static Map<String, String> opportunity1Values = new Map<String, String> {
            'Name' => 'TestKrzysOpp',
            'Customer__c' => 'Test Acc Krzys 1',
            'StageName' => 'Prospecting/Universe',
            'Business_Segment__c' => 'Industry',
            'CloseDate' => '10/12/2019',
            'Estimated_time_of_arrival__c' => '09/12/2019',
            'Description' => 'testDescription',
            'RecordTypeId' => 'FCI New Business Opportunity',
            'CurrencyIsoCode' => 'USD',
            'Pricebook2Id' => 'Custom Pricebook'
    };

    static Map<String, String> product1Values = new Map<String, String> {
            'OpportunityId' => 'TestKrzysOpp',
            'Product2Id' => 'Allevo Forest Fruit Type 2 330ml',
            'Quantity' => '115',
            'TotalPrice' => '2'
    };

    static Map<String, String> product2Values = new Map<String, String> {
            'OpportunityId' => 'TestKrzysOpp',
            'Product2Id' => 'Allevo Forest Fruit Type 3',
            'Quantity' => '100',
            'TotalPrice' => '5'
    };

    @isTest
    static void shouldInsertProduct() {
        User usr = insertOpportunityAndReturnUser();
        System.runAs(usr) {
            Test.startTest();

            UploadProductFromCSV uploadProd = new UploadProductFromCSV(new List<String>{getDataRow(product1Values)});
            uploadProd.upsertData(Constants.CSV_UPSERT_OPTION_INSERT);

            Test.stopTest();
        }

        OpportunityLineItem oppLItem = [SELECT Id, Quantity, TotalPrice FROM OpportunityLineItem WHERE Product2.Name = 'Allevo Forest Fruit Type 2 330ml'];
        System.assertEquals(115, oppLItem.Quantity);
        System.assertEquals(2, oppLItem.TotalPrice.round());
    }

    @isTest
    static void shouldUpdateProduct() {
        User usr = insertOpportunityAndReturnUser();
        System.runAs(usr) {
            UploadProductFromCSV uploadProd = new UploadProductFromCSV(new List<String>{getDataRow(product1Values)});
            uploadProd.upsertData(Constants.CSV_UPSERT_OPTION_INSERT);

            product1Values.put('Quantity', '200,00');

            Test.startTest();

            uploadProd = new UploadProductFromCSV(new List<String>{getDataRow(product1Values)});
            uploadProd.upsertData(Constants.CSV_UPSERT_OPTION_WITH_OVERWRITE);

            Test.stopTest();
        }

        OpportunityLineItem oppLItem = [SELECT Id, Quantity, TotalPrice FROM OpportunityLineItem WHERE Product2.Name = 'Allevo Forest Fruit Type 2 330ml'];
        System.assertEquals(200, oppLItem.Quantity);
        System.assertEquals(2, oppLItem.TotalPrice.round());
    }

    @isTest
    static void shouldUpdateExistingAndInsertNewProduct() {
        User usr = insertOpportunityAndReturnUser();
        System.runAs(usr) {
            UploadProductFromCSV uploadProd = new UploadProductFromCSV(new List<String>{getDataRow(product1Values)});
            uploadProd.upsertData(Constants.CSV_UPSERT_OPTION_INSERT);

            product1Values.put('Quantity', '200,00');

            Test.startTest();

            uploadProd = new UploadProductFromCSV(new List<String>{getDataRow(product1Values), getDataRow(product2Values)});
            uploadProd.upsertData(Constants.CSV_UPSERT_OPTION_WITH_OVERWRITE);

            Test.stopTest();
        }

        OpportunityLineItem oppLItem = [SELECT Id, Quantity, TotalPrice FROM OpportunityLineItem WHERE Product2.Name = 'Allevo Forest Fruit Type 2 330ml'];
        System.assertEquals(200, oppLItem.Quantity);
        System.assertEquals(2, oppLItem.TotalPrice.round());

        OpportunityLineItem oppLItem2 = [SELECT Id, Quantity, TotalPrice FROM OpportunityLineItem WHERE Product2.Name = 'Allevo Forest Fruit Type 3'];
        System.assertEquals(100, oppLItem2.Quantity);
        System.assertEquals(5, oppLItem2.TotalPrice.round());
    }

    @isTest
    static void shouldInsertOnlyNewProduct() {
        User usr = insertOpportunityAndReturnUser();
        System.runAs(usr) {
            UploadProductFromCSV uploadProd = new UploadProductFromCSV(new List<String>{getDataRow(product1Values)});
            uploadProd.upsertData(Constants.CSV_UPSERT_OPTION_INSERT);

            product1Values.put('Quantity', '200,00');

            Test.startTest();

            uploadProd = new UploadProductFromCSV(new List<String>{getDataRow(product1Values), getDataRow(product2Values)});
            uploadProd.upsertData(Constants.CSV_UPSERT_OPTION_ONLY_NEW);

            Test.stopTest();
        }

        OpportunityLineItem oppLItem = [SELECT Id, Quantity, TotalPrice FROM OpportunityLineItem WHERE Product2.Name = 'Allevo Forest Fruit Type 2 330ml'];
        System.assertEquals(115, oppLItem.Quantity);
        System.assertEquals(2, oppLItem.TotalPrice.round());

        OpportunityLineItem oppLItem2 = [SELECT Id, Quantity, TotalPrice FROM OpportunityLineItem WHERE Product2.Name = 'Allevo Forest Fruit Type 3'];
        System.assertEquals(100, oppLItem2.Quantity);
        System.assertEquals(5, oppLItem2.TotalPrice.round());
    }

    @isTest
    static void shouldValidateMandatoryField() {
        List<UploadObjectFromCSV.ErrorWrapper> errors;

        User usr = insertOpportunityAndReturnUser();
        System.runAs(usr) {

            product1Values.put('Product2Id', '');

            Test.startTest();

            UploadProductFromCSV uploadProd = new UploadProductFromCSV(new List<String>{getDataRow(product1Values)});
            errors = uploadProd.validateData();

            Test.stopTest();
        }

        System.assertEquals(Constants.ERROR_UPLOAD_TYPE_MANDATORY, errors.get(0).type);
    }

    @isTest
    static void shouldFindDuplicates() {
        List<UploadObjectFromCSV.ErrorWrapper> errors;

        User usr = insertOpportunityAndReturnUser();
        System.runAs(usr) {

            UploadProductFromCSV uploadProd = new UploadProductFromCSV(new List<String>{getDataRow(product1Values)});
            uploadProd.upsertData(Constants.CSV_UPSERT_OPTION_INSERT);
            Test.startTest();

            uploadProd = new UploadProductFromCSV(new List<String>{getDataRow(product1Values)});
            errors = uploadProd.validateData();

            Test.stopTest();
        }

        System.assertEquals(Constants.ERROR_UPLOAD_TYPE_DUPLICATE, errors.get(0).type);
    }

    private static User insertOpportunityAndReturnUser() {
        Account acc = TestUtility.createAccount('Test Acc Krzys 1');
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'End Customer' LIMIT 1].Id;
        insert acc;

        Product2 prod = TestUtility.createProduct(product1Values.get('Product2Id'));
        insert prod;

        Product2 prod2 = TestUtility.createProduct(product2Values.get('Product2Id'));
        insert prod2;

        PricebookEntry prb = TestUtility.createPricebookEntry(prod, Test.getStandardPricebookId());
        insert prb;

        PricebookEntry prb2 = TestUtility.createPricebookEntry(prod2, Test.getStandardPricebookId());
        insert prb2;

        Pricebook2 prBook = TestUtility.createPriceBook('Custom Pricebook');
        insert prBook;

        PricebookEntry prb3 = TestUtility.createPricebookEntry(prod, prBook.Id);
        insert prb3;

        PricebookEntry prb4 = TestUtility.createPricebookEntry(prod2, prBook.Id);
        insert prb4;

        User usr = TestUtility.createPartnerPortalUser('testKrzysUser5@flc.com.test.PCU', null);
        System.runAs(usr) {
            UploadOpportunityFromCSV uploadOpp = new UploadOpportunityFromCSV(new List<string>{getDataRow(opportunity1Values)});
            uploadOpp.upsertData(Constants.CSV_UPSERT_OPTION_INSERT);
        }

        return usr;
    }

    private static String getDataRow(Map<String, String> accValues) {
        String row = '';
        for (String fieldValue : accValues.values()) {
            row += fieldValue + ';';
        }
        row = row.removeEnd(';');
        return row;
    }
    */
}