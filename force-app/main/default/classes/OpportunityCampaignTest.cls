@isTest
public class OpportunityCampaignTest {
    @testSetup
    static void setup() {
        List<Product2> product = new List<Product2>();
        List<PriceBookEntry> priceEntry = new List<PriceBookEntry>();
        id productRecordTypeid = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('BGI_Product_Group').getRecordTypeId();
        
        Account commercialCust = TestUtility.createAccount('IMCD Holding');
        commercialCust.Active__c=true;
        insert commercialCust; 
        
        Account customerLocItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCust);
        customerLocItaly.Active__c=true;
        customerLocItaly.Partner_Role__c='Sold-to';
        insert customerLocItaly;
        
        Pricebook2 priceBookObj = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );       
        update priceBookObj;
        
        Product2 pro1 = new Product2();
        pro1.Name = 'Plt Faba 90A K/H IA2 Bwh20 EU540 B9 Trl';
        pro1.IsActive =true;
        pro1.Product_Code__c = 'SAPPRODUCTcode1';
        pro1.ProductCode ='PRODUCTcode1';
        pro1.RecordTypeId = productRecordTypeid;
        product.add(pro1);
        insert product;

        PriceBookEntry PE1 = new PriceBookEntry();
        PE1.Pricebook2Id = [select id from Pricebook2 where id=:priceBookObj.id].id;
        PE1.Product2Id = product.get(0).id;
        PE1.IsActive = true;
        PE1.UseStandardPrice = false;
        PE1.UnitPrice = 1000;
        priceEntry.add(PE1);
        insert priceEntry;

        Campaign cmp = new Campaign(); 
        cmp.Business_Segment__c = 'Industry';
        cmp.Sub_Segment__c = 'Beverages';
        cmp.Name = 'test cmp';
        cmp.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('FCP_Campaign').getRecordTypeId();
        insert cmp;
    }
    @isTest
    public static void testCampaignUpdateOnOpportunity(){
        List<Account> acc = [SELECT Id, Name FROM Account];
        List<Product2> productlst = [SELECT id,ProductCode from Product2];
        Campaign cmp = [SELECT id from Campaign limit 1];
        List<PriceBookEntry> priceEntry = [SELECT id from PriceBookEntry];
        Opportunity oppItaly = TestUtility.createFCINewBusinessOpportunity('testOppname',acc.get(0) , acc.get(1));
        oppItaly.CampaignId = cmp.id;
        insert oppItaly;      
        OpportunityLineItem oppritem1 = new OpportunityLineItem();
        oppritem1.Product2Id = productlst[0].id;
        oppritem1.OpportunityId  = oppItaly.id;
        oppritem1.PricebookEntryId = priceEntry.get(0).id;
        oppritem1.UnitPrice = 1200;
        oppritem1.Quantity = 1;        
        insert oppritem1;
        oppItaly.CampaignId = null;
        update oppItaly;
        System.assert(oppItaly.CampaignId == null);
    }

}