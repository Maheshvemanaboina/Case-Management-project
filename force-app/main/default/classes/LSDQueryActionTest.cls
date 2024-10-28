/**
* Author: Paweł Iwanowicz
* Description: Test Class for LSDQueryAction class
*/
@IsTest
private class LSDQueryActionTest {

    @TestSetup
    static void setupData() {

        //Create a sample user
        User sampleUser = DataFactoryTest.getCPQstdUser();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert sampleUser;
            PermissionSetAssignment[] assignments = new PermissionSetAssignment[]{};
            for (PermissionSet permissionSet : DataFactoryTest.getCPQpermissions()) {
                assignments.add(new PermissionSetAssignment(
                        PermissionSetId = permissionSet.Id,
                        AssigneeId      = sampleUser.Id
                ));
            }
            insert assignments;
        }

        //Create a sample product
        Product2 sampleProduct = DataFactoryTest.getProductSKUs(1)[0];
        sampleProduct.Product_Code__c = '000000000000094500';
        sampleProduct.RecordTypeId = DataFactoryTest.getRecordTypeByDeveloperName(Schema.SObjectType.Product2).get(DataFactoryTest.PRODUCT_SKU_RECORD_TYPE_DEVELOPER_NAME).getRecordTypeId();
        Database.insert(sampleProduct);

        //Create a sample account
        Account sampleAccount = DataFactoryTest.getAccountCommercialCustomers(1)[0];
        sampleAccount.Name          = 'Test Account';
        sampleAccount.OwnerId       = sampleUser.Id;
        sampleAccount.SAP_Number__c = '0000100655';
        Database.insert(sampleAccount);

        Account testCustomerLocation1  = DataFactoryTest.getAccountCustomerLocations(1)[0];
        testCustomerLocation1.ParentId = sampleAccount.Id;
        testCustomerLocation1.Name     = 'Customer Location1';
        testCustomerLocation1.Active__c = true;
        testCustomerLocation1.Partner_Role__c = 'Sold-to';

        Account testCustomerLocation2  = DataFactoryTest.getAccountCustomerLocations(1)[0];
        testCustomerLocation2.ParentId = sampleAccount.Id;
        testCustomerLocation2.Name     = 'Customer Location2';
        testCustomerLocation2.Active__c = true;
        testCustomerLocation2.Partner_Role__c = 'Sold-to';

        Account testCustomerLocation3 = DataFactoryTest.getAccountCustomerLocations(1)[0];
        testCustomerLocation3.ParentId = sampleAccount.Id;
        testCustomerLocation3.Name     = 'Customer Location2';
        testCustomerLocation3.Active__c = true;
        testCustomerLocation3.Partner_Role__c = 'Sold-to';
        Database.insert(new List<Account>{testCustomerLocation1, testCustomerLocation2, testCustomerLocation3});

        //Create a sample opportunity
        Opportunity sampleOpportunity = DataFactoryTest.getOpportunityNewBusinesses(1)[0];
        sampleOpportunity.OwnerId   = sampleUser.Id;
        sampleOpportunity.AccountId = testCustomerLocation1.Id;
        sampleOpportunity.StageName = 'Prospecting';
        sampleOpportunity.Reason_Won_Lost__c = '';
        sampleOpportunity.Business_Segment__c = 'Early Life Nutrition & Cell Nutrition';
        Database.insert(sampleOpportunity);

        //Create a sample quote with a group and line items
        SBQQ__Quote__c quote = DataFactoryTest.createQuote(sampleOpportunity, new Product2[]{sampleProduct});

        //Create sample LSDs
        Legal_Sales_Document__c lsd1 = new Legal_Sales_Document__c();
        lsd1.Account_Name__c = testCustomerLocation1.Id;
        lsd1.Status_of_LSD__c = 'LSD in Place';
        lsd1.Leading_Business_Segment__c = 'Adult Nutrition';
        lsd1.Other_Business_Segment__c = 'Adult Nutrition;Early Life Nutrition & Cell Nutrition';
        lsd1.LSD_StartEffective_Date__c = Date.today();
        lsd1.Initial_Term_of_LSD_In_Months__c = 3;
        lsd1.Termination_Notice_Period_In_Months__c = 3;

        Legal_Sales_Document__c lsd2 = new Legal_Sales_Document__c();
        lsd2.Account_Name__c = testCustomerLocation2.Id;
        lsd2.Status_of_LSD__c = 'LSD in Place';
        lsd2.Leading_Business_Segment__c = 'Early Life Nutrition & Cell Nutrition';
        lsd2.Other_Business_Segment__c = '';
        lsd2.LSD_StartEffective_Date__c = Date.today();
        lsd2.Initial_Term_of_LSD_In_Months__c = 3;
        lsd2.Termination_Notice_Period_In_Months__c = 3;

        Legal_Sales_Document__c lsd3 = new Legal_Sales_Document__c();
        lsd3.Account_Name__c = testCustomerLocation3.Id;
        lsd3.Status_of_LSD__c = 'LSD in Place';
        lsd3.Leading_Business_Segment__c = 'Adult Nutrition';
        lsd3.Other_Business_Segment__c = 'Adult Nutrition;Early Life Nutrition & Cell Nutrition';
        lsd3.LSD_StartEffective_Date__c = Date.today();
        lsd3.Initial_Term_of_LSD_In_Months__c = 3;
        lsd3.Termination_Notice_Period_In_Months__c = 3;

        List<Legal_Sales_Document__c> lsdsToInsert = new List<Legal_Sales_Document__c>{lsd1, lsd2, lsd3};
        Database.insert(lsdsToInsert);

        Other_Related_Customer_Location__c orcl1 = new Other_Related_Customer_Location__c();
        orcl1.Legal_Sales_Document__c = lsd2.Id;
        orcl1.Account_Name__c = testCustomerLocation1.Id;

        Other_Related_Customer_Location__c orcl2 = new Other_Related_Customer_Location__c();
        orcl2.Legal_Sales_Document__c = lsd3.Id;
        orcl2.Account_Name__c = testCustomerLocation1.Id;
        Database.insert(new List<Other_Related_Customer_Location__c>{orcl1, orcl2});
    }

    @IsTest
    static void getAllLSDsTest() {
        User sampleUser = [SELECT Id FROM User WHERE UserName = :DataFactoryTest.CPQ_STD_USERNAME];
        List<List<Legal_Sales_Document__c>> listOfListOfLSDs = LSDQueryAction.getAllLSDs(new List<String>{[SELECT Id FROM SBQQ__Quote__c LIMIT 1].Id});
        System.assertEquals(3, listOfListOfLSDs[0].size());
    }
}