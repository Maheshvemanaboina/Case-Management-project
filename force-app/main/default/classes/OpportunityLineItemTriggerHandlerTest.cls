@isTest
public class OpportunityLineItemTriggerHandlerTest {
    
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
        pro1.Name = 'Product1';
        pro1.IsActive =true;
        pro1.Product_Code__c = 'SAPPRODUCTcode1';
        pro1.ProductCode ='PRODUCTcode1';
        pro1.RecordTypeId = productRecordTypeid;
        product.add(pro1);
        
        Product2 pro2 = new Product2();
        pro2.Name = 'Product2';
        pro2.IsActive =true;
        pro2.Product_Code__c = 'SAPPRODUCTcode2';
        pro2.ProductCode ='PRODUCTcode2';
        pro2.RecordTypeId = productRecordTypeid;
        product.add(pro2);
        
        Product2 pro3 = new Product2();
        pro3.Name = 'Product3';
        pro3.IsActive =true;
        pro3.Product_Code__c = 'SAPPRODUCTcode3';
        pro3.ProductCode ='PRODUCTcode3';
        pro3.RecordTypeId = productRecordTypeid;	
        product.add(pro3);
        
        Product2 pro4 = new Product2();
        pro4.Name = 'Product4';
        pro4.IsActive =true;
        pro4.Product_Code__c = 'SAPPRODUCTcode4';
        pro4.ProductCode ='PRODUCTcode4';
        pro4.RecordTypeId = productRecordTypeid;
        product.add(pro4);
        
        Product2 pro5 = new Product2();
        pro5.Name = 'Product5';
        pro5.IsActive =true;
        pro5.Product_Code__c = 'SAPPRODUCTcode5';
        pro5.ProductCode ='PRODUCTcode5';
        pro5.RecordTypeId = productRecordTypeid;
        product.add(pro5);
        
        Product2 pro6 = new Product2();
        pro6.Name = 'Plt Pea 85A K/H IA2 Bwh20 Eu540 B9 Trl';
        pro6.IsActive =true;
        pro6.Product_Code__c = 'PRODUCTcode6';
        pro6.ProductCode ='PRODUCTcode6';
        pro6.RecordTypeId = productRecordTypeid;
        product.add(pro6);
        
        Product2 pro7 = new Product2();
        pro7.Name = 'Plt Faba 90A K/H IA2 Bwh20 EU540 B9 Trl';
        pro7.IsActive =true;
        pro7.Product_Code__c = 'PRODUCTcode7';
        pro7.ProductCode ='PRODUCTcode7';
        pro7.RecordTypeId = productRecordTypeid;
        product.add(pro7);
        
        insert product;
        
        PriceBookEntry PE1 = new PriceBookEntry();
        PE1.Pricebook2Id = [select id from Pricebook2 where id=:priceBookObj.id].id;
        PE1.Product2Id = product.get(0).id;
        PE1.IsActive = true;
        PE1.UseStandardPrice = false;
        PE1.UnitPrice = 1000;
        priceEntry.add(PE1);
        
         PriceBookEntry PE2 = new PriceBookEntry();
        PE2.Pricebook2Id = [select id from Pricebook2 where id=:priceBookObj.id].id;
        PE2.Product2Id = product.get(1).id;
        PE2.IsActive = true;
        PE2.UseStandardPrice = false;
        PE2.UnitPrice = 1000;
        priceEntry.add(PE2);
        
        PriceBookEntry PE3 = new PriceBookEntry();
        PE3.Pricebook2Id = [select id from Pricebook2 where id=:priceBookObj.id].id;
        PE3.Product2Id = product.get(2).id;
        PE3.IsActive = true;
        PE3.UseStandardPrice = false;
        PE3.UnitPrice = 1000;
        priceEntry.add(PE3);
        
         PriceBookEntry PE4 = new PriceBookEntry();
        PE4.Pricebook2Id = [select id from Pricebook2 where id=:priceBookObj.id].id;
        PE4.Product2Id = product.get(3).id;
        PE4.IsActive = true;
        PE4.UseStandardPrice = false;
        PE4.UnitPrice = 1000;
        priceEntry.add(PE4);
        
        PriceBookEntry PE5 = new PriceBookEntry();
        PE5.Pricebook2Id = [select id from Pricebook2 where id=:priceBookObj.id].id;
        PE5.Product2Id = product.get(4).id;
        PE5.IsActive = true;
        PE5.UseStandardPrice = false;
        PE5.UnitPrice = 1000;
        priceEntry.add(PE5);
        
        insert priceEntry;

        
    }
     @isTest
    public static void testCampaignUpdateOnOpportunity(){
        List<Account> acc = [SELECT Id, Name FROM Account];
        List<Product2> productlst = [SELECT id,ProductCode from Product2];
        List<PriceBookEntry> priceEntry = [SELECT id from PriceBookEntry];
        Opportunity oppItaly = TestUtility.createFCINewBusinessOpportunity('testOppname',acc.get(0) , acc.get(1));
        insert oppItaly;
        List<OpportunityLineItem> item = new List<OpportunityLineItem>();
        OpportunityLineItem oppritem1 = new OpportunityLineItem();
        oppritem1.Product2Id = productlst[5].id;
        oppritem1.OpportunityId  = oppItaly.id;
        oppritem1.PricebookEntryId = priceEntry.get(0).id;
        oppritem1.UnitPrice = 1200;
        oppritem1.Quantity = 2;
        item.add(oppritem1);
        OpportunityLineItem oppritem2 = new OpportunityLineItem();
        oppritem2.Product2Id = productlst[6].id;
        oppritem2.OpportunityId  = oppItaly.id;
        oppritem2.PricebookEntryId = priceEntry.get(0).id;
        oppritem2.UnitPrice = 1400;
        oppritem2.Quantity = 1;
        item.add(oppritem2);
        OpportunityLineItem oppritem3 = new OpportunityLineItem();
        oppritem3.Product2Id = productlst[4].id;
        oppritem3.OpportunityId  = oppItaly.id;
        oppritem3.PricebookEntryId = priceEntry.get(0).id;
        oppritem3.UnitPrice = 1400;
        oppritem3.Quantity = 1;
        item.add(oppritem3);
        Test.startTest();
        insert item;
        delete oppritem3;
        delete oppritem1;
        delete oppritem2;
        Test.stopTest();
    }
    @isTest
    public static void testProjectUpdateOnOpportunity(){
        
        List<OpportunityLineItem> opprLineitemsLst = new List<OpportunityLineItem>();
        List<Account> acc = [SELECT Id, Name FROM Account];
        List<Product2> productlst = [SELECT id,ProductCode from Product2];
        List<PriceBookEntry> priceEntry = [SELECT id from PriceBookEntry];
        List<project__c> projectLst = new List<Project__c>();
        List<Project_Product_Association__c> projectProductAssociation = new List<Project_Product_Association__c>();
        Id projectNPDRecordType = Schema.SObjectType.Project__c.getRecordTypeInfosByDeveloperName().get('FCI_NPD_Projects').getRecordTypeId();
        
        Opportunity oppItaly = TestUtility.createFCINewBusinessOpportunity('testOppname',acc.get(0) , acc.get(1));
        insert oppItaly;
        
        Project__c project1 = new Project__c();
        project1.RecordTypeId = projectNPDRecordType;
        project1.Name = 'project1';
        projectLst.add(project1);
        
        Project__c project2 = new Project__c();
        project2.RecordTypeId = projectNPDRecordType;
        project2.Name = 'project2';
        projectLst.add(project2);
        
        Project__c project3 = new Project__c();
        project3.RecordTypeId = projectNPDRecordType;
        project3.Name = 'project1';
        projectLst.add(project3);
        
        INSERT projectLst;
        
        Project_Product_Association__c productProjectAssociate1 = new Project_Product_Association__c();
        productProjectAssociate1.Product_Name__c = productlst.get(0).id;
        productProjectAssociate1.Project_Name__c = projectLst.get(0).id;
        projectProductAssociation.add(productProjectAssociate1);
        
        Project_Product_Association__c productProjectAssociate2 = new Project_Product_Association__c();
        productProjectAssociate2.Product_Name__c = productlst.get(1).id;
        productProjectAssociate2.Project_Name__c = projectLst.get(0).id;
        projectProductAssociation.add(productProjectAssociate2);
        
        Project_Product_Association__c productProjectAssociate3 = new Project_Product_Association__c();
        productProjectAssociate3.Product_Name__c = productlst.get(2).id;
        productProjectAssociate3.Project_Name__c = projectLst.get(1).id;
        projectProductAssociation.add(productProjectAssociate3);
        
        Project_Product_Association__c productProjectAssociate4 = new Project_Product_Association__c();
        productProjectAssociate4.Product_Name__c = productlst.get(3).id;
        productProjectAssociate4.Project_Name__c = projectLst.get(2).id;
        projectProductAssociation.add(productProjectAssociate4);
       
        Project_Product_Association__c productProjectAssociate5 = new Project_Product_Association__c();
        productProjectAssociate5.Product_Name__c = productlst.get(4).id;
        productProjectAssociate5.Project_Name__c = projectLst.get(2).id;
        projectProductAssociation.add(productProjectAssociate5);
       
        
        INSERT projectProductAssociation;
        
        Opportunity_Project_Association__c opprProjectAssociation = new Opportunity_Project_Association__c();
        opprProjectAssociation.Opportunity__c = oppItaly.id;
        opprProjectAssociation.Project_Name__c = projectLst.get(0).id;
        INSERT opprProjectAssociation;

        
        OpportunityLineItem oppritem1 = new OpportunityLineItem();
        oppritem1.Product2Id = productlst.get(0).id;
        oppritem1.OpportunityId  = oppItaly.id;
        oppritem1.PricebookEntryId = priceEntry.get(0).id;
        oppritem1.UnitPrice = 1200;
        oppritem1.Quantity = 2;
        opprLineitemsLst.add(oppritem1);
        
        OpportunityLineItem oppritem2 = new OpportunityLineItem();
        oppritem2.Product2Id = productlst.get(1).id;
        oppritem2.PricebookEntryId = priceEntry.get(1).id;
        oppritem2.OpportunityId  = oppItaly.id;
        oppritem2.UnitPrice = 1200;
        oppritem2.Quantity = 2;
        opprLineitemsLst.add(oppritem2);

        OpportunityLineItem oppritem3 = new OpportunityLineItem();
        oppritem3.Product2Id = productlst.get(2).id;
        oppritem3.PricebookEntryId = priceEntry.get(2).id;
        oppritem3.OpportunityId  = oppItaly.id;
        oppritem3.UnitPrice = 1200;
        oppritem3.Quantity = 2;
        opprLineitemsLst.add(oppritem3);
        
        OpportunityLineItem oppritem4 = new OpportunityLineItem();
        oppritem4.Product2Id = productlst.get(3).id;
        oppritem4.PricebookEntryId = priceEntry.get(3).id;
        oppritem4.OpportunityId  = oppItaly.id;
        oppritem4.UnitPrice = 1200;
        oppritem4.Quantity = 2;
        opprLineitemsLst.add(oppritem4);

        INSERT opprLineitemsLst;
        

    }

}