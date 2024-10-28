/******************************************************************************************************************************************************************
* Class Name    : BatchToAddLookupOnLSDProductGroupTest
* Modified Date : 05/05/2024
* User Story    : 143421-[Imp] As a Developer, I should be able to see all the impacted components are updated with the picklist value changes on the LSD object
* Description   : Replaced the correct picklist values for Business_Group__c,Leading_Business_Segment__c,FC_Legal_Entity__c of LSD object.
********************************************************************************************************************************************************************/
@isTest
public class BatchToAddLookupOnLSDProductGroupTest {
      @testSetup 
    static void setup(){
        Account acc1 = new Account();
        acc1.Name = 'ABC';
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Customer_Location').getRecordTypeId();
        insert acc1;
        Legal_Sales_Document__c lsd = new Legal_Sales_Document__c();
        RecordType recType = [SELECT Id,Name FROM RecordType WHERE Name='LSD Creation'];
        lsd.RecordTypeId = recType.Id;
        lsd.Status_of_LSD__c = 'NO LSD';
        lsd.Total_Net_Sales_Value__c = 200000000;
        lsd.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
        lsd.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        lsd.Business_Group__c = 'MEPA';//143421
        lsd.Leading_Business_Segment__c = 'Rest of Sub Saharan Africa';//143421
        lsd.FC_Legal_Entity__c = 'FrieslandCampina Saudi Arabia Limited';//143421
        lsd.Account_Name__c = acc1.Id;
        insert lsd;
        Product2 Prod = new Product2();
        RecordType proRecType = [SELECT ID FROM RecordType WHERE Name='Product Group'];
        prod.RecordTypeId = proRecType.Id;
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
        prod.IsActive = true;
        insert prod;
        LSD_Products_New__c lsdPro1 = new LSD_Products_New__c();
        lsdPro1.Parent_Product__c = prod.Id;
        lsdPro1.Active__c = true;
        lsdPro1.Name = 'test1';
        insert lsdPro1;
        LSD_Product__c lsdProductGroup = new LSD_Product__c();
        lsdProductGroup.Legal_Sales_Document__c = lsd.Id;
        lsdProductGroup.Product_Group__c = prod.Id;
        insert lsdProductGroup;
        
    }
    static testmethod void test(){
          Test.startTest();
        BatchToAddLookupOnLSDProductGroup batch = new BatchToAddLookupOnLSDProductGroup();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();  
    }
}