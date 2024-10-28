@IsTest
public class SRM_CreateRiskDetailsControllerTest {
     @TestSetup
    static void testSetup() {
        List<Value_Element__c> valueELements = TestUtils.newValueElements(new Value_Element__c(Is_Active__c = true), 5, true);
        List<Location__c> locations = TestUtils.newLocations(null, 2, true);
        locations[0].Is_Active__c = true;
        update locations[0];
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(new Supplier_Hub__c(Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_KEY), true);
        List<Supplier_Location__c> supplierLocations = TestUtils.newSupplierLocations(new Supplier_Location__c(Supplier_Hub__c = supplierHub.Id, Location__c = locations[0].Id, Business_Group__c = 'INGREDIENTS'), 1, true);
        Supplier_SAP_Numbers_And_Payment_Terms__c vendorbk = new Supplier_SAP_Numbers_And_Payment_Terms__c();
        vendorbk.Supplier_Hub__c = supplierHub.id;
        vendorbk.Vendor_Sap_Number__c = '1234567';
        insert vendorbk;
    }
    @isTest
    static void testgetSupplierDetails(){
        SRM_CreateRiskDetailsController.getSupplierDetails('1234567');
    }
    @isTest
    static void testgetSupplierHubdetals(){
        SRM_CreateRiskDetailsController.getSupplierLocationDetails('1234567');
    }

}