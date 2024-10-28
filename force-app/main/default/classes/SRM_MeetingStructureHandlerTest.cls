@isTest
public class SRM_MeetingStructureHandlerTest {
    @testSetup static void setup() {
        // Create records to test
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(null, true);
        
        Meeting_Structure__c obj = new Meeting_Structure__c();
        obj.Supplier_Hub_Number__c = supplierHub.Id;
        obj.Frequency_of_the_Meeting__c = 'Weekly';
        obj.Name= 'Weekly Meeting';
        obj.Type__c = 'External';
        insert obj;
    }
    @isTest static void testMethod1() {
        Meeting_Structure__c objStructure = [SELECT id from Meeting_Structure__c LIMIT 1];
        objStructure.Type__c = 'Internal';
        update objStructure;
    }
}