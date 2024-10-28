@isTest
public class RollUpChildsToParentTest {
    @testSetup static void setup() {
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(null, true);
        Supplier_Hub__c childSupplierHub = TestUtils.newSupplierHub(null, true);
        childSupplierHub.Parent_Supplier__c = supplierHub.Id;
        update childSupplierHub;
        Map<Id, Supplier_Contract__c> supplierContractList = new Map<Id, Supplier_Contract__c>(TestUtils.newSupplierContracts(new Supplier_Contract__c(Supplier_Hub__c = supplierHub.Id), 2, true));
        Supplier_Project__c supplierProject = TestUtils.newSupplierProject(new Supplier_Project__c(Type__c = ConstUtils.SUPPLIER_PROJECT_TYPE_EXTERNAL), true);
        supplierProject.Supplier__c = supplierHub.id;
        update supplierProject;
        Supplier_Category__c objcategory = new Supplier_Category__c(Name = 'Test');
        insert objCategory;
		Location__c testLocation = new Location__c(Name = 'TestLocation', Is_Active__c = true, City__c = 'Jeddah', Country__c = 'Saudi Arabia');
        insert testLocation;

        
        Contingency_Plan__c plan = new Contingency_Plan__c(Supplier_Hub__c = supplierHub.Id);
        insert plan;
        
        Location__c location1 = new Location__c(Name = 'Delhi');
        insert location1;
        Complaints__c complaint = new Complaints__c(Complaint_Title__c	 = 'Test title', Location__c = location1.Id, Supplier__c = supplierHub.Id);
        insert complaint;
        Supplier_Combined_Categories__c combineCategory = new Supplier_Combined_Categories__c(Supplier_Hub_Number__c = supplierHub.Id, Combined_Category_Subgroup__c = objcategory.Id);
        insert combineCategory;
         Meeting_Structure__c obj = new Meeting_Structure__c();
        obj.Supplier_Hub_Number__c = supplierHub.Id;
        obj.Frequency_of_the_Meeting__c = 'Weekly';
        obj.Name= 'Weekly Meeting';
        obj.Type__c = 'External';
        insert obj;
        
        Meeting_Notes__c objNotes = new Meeting_Notes__c();
        objNotes.Meeting_Date__c= date.today();
        objNotes.Meeting_Structure__c = obj.id;
        objNotes.Meeting_Type__c = 'Relationship building';
        objNotes.Name = 'Test meeting note - Created via Meeting Notes';
        objNotes.Supplier_Hub_Number__c= supplierHub.Id;
        objNotes.Type__c= 'External';
        insert objNotes;
        
        Supplier_SAP_Numbers_And_Payment_Terms__c objTerm = new Supplier_SAP_Numbers_And_Payment_Terms__c();
        objTerm.Supplier_Hub__c = supplierHub.Id;
            objTerm.Vendor_Sap_Number__c= '11044';
            objTerm.Payment_Term_Code__c= 'Z840';
            objTerm.Vendor_Source__c='SAP FCDFPRD400 Client 400';
            objTerm.Duns_Sid__c='412141921';
            insert objTerm;
    }
    @isTest static void collateContracts() {
        Supplier_Hub__c supplierHub = [SELECT Id FROM Supplier_Hub__c WHERE Parent_Supplier__c = NULL limit 1];
        List<Supplier_Contract__c>  contracts = RollUpChildsToParent.getContractdata(supplierHub.Id);
    }
    @isTest static void deleteContracts() {
        Supplier_Contract__c supplierContract = [SELECT Id FROM Supplier_Contract__c limit 1];
        RollUpChildsToParent.delContract(supplierContract);
    }
     @isTest static void collateSuplierProjects() {
        Supplier_Hub__c supplierHub = [SELECT Id FROM Supplier_Hub__c WHERE Parent_Supplier__c = NULL limit 1];
        List<Supplier_Project__c>  contracts = RollUpChildsToParent.collateAllSupplierProjects(supplierHub.Id);
    }
    @isTest static void deleteSupplierProjects() {
        Supplier_Project__c supplierContract = [SELECT Id FROM Supplier_Project__c limit 1];
        RollUpChildsToParent.delprojectRecord(supplierContract);
    }
    @isTest static void collateClaims() {
        Supplier_Hub__c supplierHub = [SELECT Id FROM Supplier_Hub__c WHERE Parent_Supplier__c = NULL limit 1];
        List<Claim__c>  contracts = RollUpChildsToParent.collateAllSupplierClaims(supplierHub.Id);
    }
    @isTest static void collateplans() {
        Supplier_Hub__c supplierHub = [SELECT Id FROM Supplier_Hub__c WHERE Parent_Supplier__c = NULL limit 1];
        List<Contingency_Plan__c>  plans = RollUpChildsToParent.collateAllSupplierCPlans(supplierHub.Id);
    }
    @isTest static void deleteplans() {
        Contingency_Plan__c supplierClaims = [SELECT Id FROM Contingency_Plan__c limit 1];
        RollUpChildsToParent.delCplan(supplierClaims);
    }
    @isTest static void collatecomplaints() {
        Supplier_Hub__c supplierHub = [SELECT Id FROM Supplier_Hub__c WHERE Parent_Supplier__c = NULL limit 1];
        List<Complaints__c>  plans = RollUpChildsToParent.collateAllSupplierComplaints(supplierHub.Id);
    }
    
    @isTest static void collateCategories() {
        Supplier_Hub__c supplierHub = [SELECT Id FROM Supplier_Hub__c WHERE Parent_Supplier__c = NULL limit 1];
         List<Supplier_Combined_Categories__c> supplierCategories =  RollUpChildsToParent.collateAllSupplierCategories(supplierHub.Id);
    }
    @isTest static void collatesummaries() {
        Supplier_Hub__c supplierHub = [SELECT Id FROM Supplier_Hub__c WHERE Parent_Supplier__c = NULL limit 1];
         List<Meeting_Notes__c> supplierCategories =  RollUpChildsToParent.getMeetingSummarydata(supplierHub.Id);
    }
    @isTest static void collatestructure() {
        Supplier_Hub__c supplierHub = [SELECT Id FROM Supplier_Hub__c WHERE Parent_Supplier__c = NULL limit 1];
         List<Meeting_Structure__c> supplierCategories =  RollUpChildsToParent.getMeetingStructuredata(supplierHub.Id);
    }
    @isTest static void collaVendorBkData() {
        Supplier_Hub__c supplierHub = [SELECT Id FROM Supplier_Hub__c WHERE Parent_Supplier__c = NULL limit 1];
         List<Supplier_SAP_Numbers_And_Payment_Terms__c> supplierCategories =  RollUpChildsToParent.getVendorBkdata(supplierHub.Id);
    }
}