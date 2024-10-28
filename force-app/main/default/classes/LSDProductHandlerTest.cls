@isTest
public class LSDProductHandlerTest {

    @isTest
    public static void test1(){
        Product2 ProdParent = new Product2();
        RecordType recType = [SELECT ID FROM RecordType WHERE Name='Product Group'];
        ProdParent.RecordTypeId = recType.Id;
        ProdParent.Name = 'testProd';
        ProdParent.Description = 'test';
        ProdParent.Business_Segment_Non_Restricted__c = 'Industry';
        ProdParent.Product_Segment_1__c = 'Butter';
        ProdParent.Product_Segment_2__c = 'Quarks';
        ProdParent.Product_Segment_3__c = 'AMF';
        ProdParent.Product_Segment_4__c = 'Buttercheese';
        ProdParent.StockKeepingUnit = 'test';
        ProdParent.IsActive = true;
        insert ProdParent;
         
        Product2 prod = new Product2();
        prod.FCI_matching_product__c = ProdParent.ID;
        prod.Product_Group_Lookup__c = ProdParent.ID;
        prod.RecordTypeId = recType.Id;
        prod.Name = 'testProd';
        prod.Description = 'test';
        prod.Business_Segment_Non_Restricted__c = 'Industry';
        prod.Product_Segment_1__c = 'Butter';
        prod.Product_Segment_2__c = 'Quarks';
        prod.Product_Segment_3__c = 'AMF';
        prod.Product_Segment_4__c = 'Buttercheese';
        prod.StockKeepingUnit = 'test1';
        prod.Application__c = 'DMV: Bakery';
        prod.Base_Unit_of_Measure__c = '';
        prod.Brand_Segment_1__c = 'Non branded';
        prod.Brand_Segment_2__c = 'Alpine';
        prod.Brand_Segment_3__c = 'Chantibic';
        prod.Business_Segment_Non_Restricted__c = 'Cheese';
        prod.Expected_Close_Date__c = Date.today();
        prod.Expected_Completion_Date__c = Date.today();
        prod.Hierarchy_1__c = 'Cream beverages';
        prod.Hierarchy_2__c = 'Alcoholic beverages';
        prod.Hierarchy_3__c = 'Others';
        prod.Hierarchy_4__c = 'Tanktruck';
        prod.Hierarchy_5__c = 'Others';
        prod.Hierarchy_6__c = 'TBD';
        prod.Lead_Time__c = 'test';
        prod.Market_Segment__c = 'Alcoholic Beverages';
        prod.Min_Remaining_Shelf_Live__c = 4;
        prod.Operating_Company_Non_Restricted__c = 'BGI';
        prod.Principal_Toolbox_Name__c = 'test';
        prod.Product_Code__c = 'EXTR1212';
        prod.Product_Group__c = 'Acilac';
        prod.Product_Hierarchy_Code__c = 'TEST12';
        prod.Production_Location__c = 'Sample Location 1';
        prod.Production_Plants__c = 'TEST';
        prod.Product_Lead_Time__c = 'TEST';
        prod.Region__c = 'EMEA';
        prod.Sales_Organization_Number__c = 'TEST';
        prod.Sub_Segment__c = 'Beverages';
        prod.Total_Shelf_Live__c = 4;
        insert prod;
        
        LSD_Products_New__c lsdPro1 = new LSD_Products_New__c();
        lsdPro1.Parent_Product__c = ProdParent.Id;
        lsdPro1.Active__c = true;
        lsdPro1.Name = 'test1';
        insert lsdPro1;
        LSD_Products_New__c lsdPro2 = new LSD_Products_New__c();
        lsdPro2.Parent_Product__c = prod.Id;
        lsdPro2.Name = 'test1';
        Test.startTest();
        insert lsdPro2;
        lsdPro2.Product_Lead_Time__c = 'test';
        update lsdPro2;
        Test.stopTest();
    }
}