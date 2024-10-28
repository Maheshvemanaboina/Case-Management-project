@IsTest
public class SRM_CrateMultiRecordsTest {
     @testSetup static void setup() {
        // Create common test accounts
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(null, true);
    }
    @isTest static void testMethod1() {
        SRM_CrateMultiRecords.getSUpplier('Supplier Name','Givaudan SA');
    }
    @isTest static void testMethod2() {
        SRM_CrateMultiRecords.getSUpplier('Duns Number','123456');
    }
    @isTest static void testMethod3() {
        try{
             SRM_CrateMultiRecords.getSUpplier('Vendor BK Number','123456');
        }catch(exception e){
            
            
        }
       
    }

}