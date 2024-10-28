@isTest
public class BatchClassForLSDProductRecordCreatTest {

    @testSetup 
    static void setup(){
        Product2 Prod = new Product2();
        RecordType recType = [SELECT ID FROM RecordType WHERE Name='Product Group'];
        prod.RecordTypeId = recType.Id;
        prod.Name = 'testProd';
        prod.Description = 'test';
        prod.Business_Segment_Non_Restricted__c = 'Industry';
        prod.Product_Segment_1__c = 'Butter';
        prod.Product_Segment_2__c = 'Quarks';
        prod.Product_Segment_3__c = 'AMF';
        prod.Product_Segment_4__c = 'Buttercheese';
        prod.StockKeepingUnit = 'test';
        prod.Application__c = 'DMV: Bakery';
        prod.Brand_Segment_1__c = 'Non branded';
        prod.Brand_Segment_2__c = 'Alpine';
        prod.Brand_Segment_3__c = 'Chantibic';
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
    }
    static testmethod void test() {
     Test.startTest();
        BatchClassForLSDProductRecordCreation batch = new BatchClassForLSDProductRecordCreation();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();   
    }
    
}