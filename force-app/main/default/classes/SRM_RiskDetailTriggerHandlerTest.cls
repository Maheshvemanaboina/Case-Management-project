@isTest
private class SRM_RiskDetailTriggerHandlerTest {
    @testSetup static void setup() {
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(null, true);
		List<Supplier_Team__c> supplierTeamList = TestUtils.newSupplierTeams(new Supplier_Team__c(Supplier_Hub__c = supplierHub.Id), 5, true);
		supplierTeamList[0].Role__c = 'Relationship Manager';
        update supplierTeamList[0];
        
        Supplier_Category__c category = new Supplier_Category__c(Name = 'AEROSOLS & VALVES', IsActive__c =true);
        insert category;
        
        Risk__c objRisk = new Risk__c(Supplier__c = supplierHub.id,
                                      Risk_Title__c	= 'Test Risk title', 
                                      Classification_incident__c	= 'Quality', 
                                      Severity_assessment_date__c= date.today(),
                                      Visibility__c	= 'Joined', Category_Subgroup__c = category.Id);
        insert objRisk;
        
        
        
        
    }
    @isTest static void TestAccountsToShareWith(){
        Supplier_Hub__c objHub = [SELECT Id, Supplier_Account__c FROM Supplier_Hub__c limit 1];
        Risk__c objRisk =[SELECT Id, Account_to_share_with__c FROM Risk__c LIMIT 1];
        SYSTEM.debug(''+ objRisk.Account_to_share_with__c);
        system.assertEquals(objHub.Supplier_Account__c, objRisk.Account_to_share_with__c);
    }
    @isTest static void TestAccountsToShareWithUpdate(){
        Supplier_Hub__c objHub = [SELECT Id, Supplier_Account__c FROM Supplier_Hub__c limit 1];
        Risk__c objRisk =[SELECT Id, Account_to_share_with__c FROM Risk__c LIMIT 1];
        SYSTEM.debug(''+ objRisk.Account_to_share_with__c);
        Test.startTest();
        objRisk.Visibility__c = 'Internal';
        update objRisk;
        Test.stopTest();
    }
}