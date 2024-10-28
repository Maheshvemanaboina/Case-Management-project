@IsTest
public with sharing class SalesAgreementVolumeUpdateActionTest {
    @TestSetup
    private static void dataSetup() {

        OrderStatusIntegration__c settings = new OrderStatusIntegration__c();
        settings.Name = 'test';
        settings.Endpoint__c = 'https://test.com';
        settings.API_Key__c = 'someTestKey';
        Database.insert(settings);

        List<Product2> testProducts = DataFactoryTest.getProductSKUs(2);
        Database.insert(testProducts);

        Pricebook2 priceBookObj = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
        );
        Database.update(priceBookObj);

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for (Product2 prod : testProducts) {
            pricebookEntries.add(new PricebookEntry(UnitPrice = 0.01, Product2Id = prod.Id, Pricebook2Id = priceBookObj.Id,
                    IsActive = true, UseStandardPrice = false));
        }
        Database.insert(pricebookEntries);

        List<Account> testAccounts = DataFactoryTest.getAccountCommercialCustomers(2);
        testAccounts[0].OwnerId = testAccounts[1].OwnerId = UserInfo.getUserId();
        Database.insert(testAccounts);

        SalesAgreement sa = new SalesAgreement();
        sa.SAP_Number__c = '000123';
        sa.ScheduleCount = 1;
        sa.StartDate = Date.today();
        sa.EndDate = Date.today() + 20;
        sa.PricebookId = priceBookObj.Id;
        sa.Name = 'test';
        sa.AccountId = testAccounts[0].Id;
        Database.insert(sa);

        Integer position = 1;
        List<SalesAgreementProduct> prods = new List<SalesAgreementProduct>();
        for (PricebookEntry pricebookEntry : pricebookEntries) {
            SalesAgreementProduct sap1 = new SalesAgreementProduct();
            sap1.SalesAgreementId = sa.Id;
            sap1.Ordered_Quantity__c = 5;
            sap1.Position_Number__c = position;
            sap1.PricebookEntryId = pricebookEntry.Id;
            sap1.InitialPlannedQuantity = 1;
            sap1.Name = 'test';
            prods.add(sap1);

            position++;
        }
        Database.insert(prods);
    }

    @IsTest
    private static void testScenario1() {
        Test.setMock(HttpCalloutMock.class, new SalesAgreementVolumeUpdateCalloutMock());

        List<SalesAgreementProduct> sapList = [SELECT SalesAgreementId, Ordered_Quantity__c FROM SalesAgreementProduct];
        for (SalesAgreementProduct sap : sapList) {
            System.assertEquals(5, sap.Ordered_Quantity__c);
        }

        Test.startTest();
        SalesAgreementVolumeUpdateAction.processData(new List<String>{sapList[0].SalesAgreementId});
        Test.stopTest();

        sapList = [SELECT Ordered_Quantity__c FROM SalesAgreementProduct];
        for (SalesAgreementProduct sap : sapList) {
            System.assertEquals(0, sap.Ordered_Quantity__c);
        }
    }

    @IsTest
    private static void testScenario2() {
        Test.setMock(HttpCalloutMock.class, new SalesAgreementVolumeUpdateCalloutMock());

        VolumeResponseWrapper wrapper = new VolumeResponseWrapper();
        wrapper.RecordSet = new VolumeResponseWrapper.RecordDetails();
        wrapper.RecordSet.APIRuntimeResponse = 'test1';
        wrapper.RecordSet.APIRuntimeResponseDesc = 'test2';
        wrapper.RecordSet.Response = new List<VolumeResponseWrapper.ResponseDetails>();

        VolumeResponseWrapper.ResponseDetails detail = new VolumeResponseWrapper.ResponseDetails();
        detail.SAPResponse = 'test';
        detail.SAPResponseDesc = 'test';
        detail.SAPOrderNumber = 'test';
        detail.HeaderStatus = 'test';
        detail.HeaderEstimatedDeliveryDate = 'test';
        detail.ContractHeaderStatus = 'test';
        detail.Item = new List<VolumeResponseWrapper.ItemDetails>();

        VolumeResponseWrapper.ItemDetails item = new VolumeResponseWrapper.ItemDetails();
        item.ItemNumber = 'test';
        item.ItemStatus = 'test';
        item.ItemEstimatedDeliveryDate = 'test';
        item.ItemDeliveryQty = 'test';
        item.ItemOrderedQty = 'test';
    }
}