@isTest
public class ValidateRegionBusinessSegment_Test {
    
    private static testmethod void dataSetup() {
        
        List<account> accList = new List<account>();
        
        Account accobj = TestUtility.createAccount('FCI Test 1');
        accList.add(accobj);
       
        Account accobj2 = TestUtility.createAccount('Test 2');
        accobj2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Commercial_Customer').getRecordTypeId();
        accList.add(accobj2);
        
        insert accList;
        System.assertNotEquals(accList.size(),0);
        
        Opportunity opp = TestUtility.createOpportunity('testOppname', Constants.OPPORTUNITY_RECORD_TYPE_CURRENT_BUSINESS_ID, accList[0], accList[1]);
        opp.Name = 'Clone Test Opp';
        opp.OwnerId = UserInfo.getUserId();
        opp.CloseDate = System.today();
        opp.Business_Segment__c ='Adult Nutrition';
        insert opp;
        System.assertEquals(System.today(),opp.CloseDate);
        List<Product2> product = new List<Product2>();
        Product2 pro1 = TestUtility.createProduct('Product1');
        product.add(pro1);        
        Product2 pro2 = TestUtility.createProduct('Product2');
        product.add(pro2);                
        insert product;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c();
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.SBQQ__PriceBook__c = Test.getStandardPricebookId();
        quote.SBQQ__Primary__c = true;
        quote.Sales_Region__c ='APAC';
        quote.EffectiveDate__c = System.today();
        insert quote;
        
        System.assertEquals(System.today(),quote.EffectiveDate__c);
        System.assertEquals('APAC',quote.Sales_Region__c);
        System.assertEquals(FALSE,quote.Valid_for_Approval__c);
        
        string quoteId = quote.id;
        list<string> idList = new list<string>();
        idList.add(quoteId);
        System.assertNotEquals(idList.size(),0);
        ValidateRegionBusinessSegment.processData(idList);
        SBQQ__Quote__c obj = [SELECT id,Valid_for_Approval__c FROM SBQQ__Quote__c WHERE id IN : idList ];
        System.assertEquals(TRUE,obj.Valid_for_Approval__c);
    }
}