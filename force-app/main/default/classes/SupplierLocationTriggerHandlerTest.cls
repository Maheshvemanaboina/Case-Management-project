/* *******************************************************************************************************
 * Name               : SupplierLocationTriggerHandlerTest                                               *
 * Description        : SRM - Test class for SupplierLocationTriggerHandler                                    *
 * Created Date       : 04-Aug-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       04-Aug-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
@IsTest
private class SupplierLocationTriggerHandlerTest {

    @TestSetup
    static void testSetup() {
        List<Value_Element__c> valueELements = TestUtils.newValueElements(new Value_Element__c(Is_Active__c = true), 5, true);
        List<Location__c> locations = TestUtils.newLocations(null, 2, true);
        locations[0].Is_Active__c = true;
        update locations[0];
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(new Supplier_Hub__c(Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_KEY), true);
        List<Supplier_Location__c> supplierLocations = TestUtils.newSupplierLocations(new Supplier_Location__c(Supplier_Hub__c = supplierHub.Id, Location__c = locations[0].Id, Business_Group__c = 'INGREDIENTS'), 1, true);
    }
	
    @isTest
    static void shouldCreateSupplierRatingsForLocations(){
        Supplier_Hub__c supplierHub = [SELECT Id FROM Supplier_Hub__c LIMIT 1];
        List<Supplier_Rating__c> supplierRatings = [SELECT Id FROM Supplier_Rating__c WHERE Supplier_Hub__c = :supplierHub.Id];
        //System.assert(!supplierRatings.isEmpty());        
    }
    @isTest
    static void shouldCreateSupplierRatingsForLocationsUpdate(){
        Supplier_Hub__c supplierHub = [SELECT Id FROM Supplier_Hub__c LIMIT 1];
        
        Supplier_Location__c supplierLocations = [SELECT Id, Location__c FROM Supplier_Location__c limit 1];
        Id locationId = supplierLocations.Location__c;
        List<Location__c> locations = [SELECT Id FROM Location__c WHERE Id != : locationId];
         locations[0].Is_Active__c = true;
        update locations[0];
        
        supplierLocations.Location__c = locations[0].Id;
        update supplierLocations;
        List<Supplier_Rating__c> supplierRatings = [SELECT Id FROM Supplier_Rating__c WHERE Supplier_Hub__c = :supplierHub.Id];
        //System.assert(!supplierRatings.isEmpty());
    }
    @isTest
    static void testPopulateSearchableName(){
        Test.startTest();
        database.executeBatch(new BatchPopulateSearchableNameFCLocation());
        Test.stopTest();
    }
    @isTest
    static void testPopulateRatings(){
        Test.startTest();
        database.executeBatch(new SRM_CrateSupplierRatingEachYear());
        Test.stopTest();
    }
    
}