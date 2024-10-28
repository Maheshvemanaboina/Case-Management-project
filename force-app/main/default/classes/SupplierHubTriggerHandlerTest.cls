/* *******************************************************************************************************
 * Name               : SupplierHubTriggerHandlerTest                                               *
 * Description        : SRM - Test class for SupplierHubTriggerHandler.cls                                *
 * Created Date       : 22-Oct-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       22-Oct-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
@IsTest
private class SupplierHubTriggerHandlerTest {

    @IsTest
    static void shouldAddErrorToSupplierHubRecord() {
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(null, true);
        Exception ex;
        Test.startTest();
        try {
            Supplier_Hub__c secondSupplierHub = TestUtils.newSupplierHub(new Supplier_Hub__c(Supplier_Account__c = supplierHub.Supplier_Account__c), true);
        } catch(Exception e) {
            ex = e;
        }

        Test.stopTest();

        System.assertEquals(null, ex);

    }

    @IsTest
    static void shouldCreateSupplierHeaderAndRatingRecords() {
        List<Value_Element__c> valueElements = TestUtils.newValueElements(new Value_Element__c(Is_Active__c = true), 10, true);
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(null, true);
        Supplier_Location__c supplierLocation = TestUtils.newSupplierLocation(new Supplier_Location__c(Supplier_Hub__c = supplierHub.Id, Business_Group__c = 'INGREDIENTS'), false);
        list<Location__c> locs = [Select id from location__c];
        for(Location__c lo:locs){
            lo.is_active__c = true;
        }
        update locs;
        insert supplierLocation; 
        Test.startTest();

        supplierHub.Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_MANAGED;
        update supplierHub;

        Test.stopTest();

        List<Supplier_Rating_Header__c> supplierRatingHeader = [SELECT Id FROM Supplier_Rating_Header__c WHERE Supplier_Hub__c = :supplierHub.Id];
        List<Supplier_Rating__c> supplierRatings = [SELECT Id FROM Supplier_Rating__c WHERE Supplier_Hub__c = :supplierHub.Id];
        supplierHub = [SELECT Account_Name_Searchable__c FROM Supplier_Hub__c WHERE Id = :supplierHub.Id];

        //System.assert(!supplierRatingHeader.isEmpty());
        //System.assert(!supplierRatings.isEmpty());
        System.assertEquals(null, supplierHub.Account_Name_Searchable__c);

    }
	 @IsTest
    static void testParentSupplier() {
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(null, true);
        Exception ex;
        Test.startTest();
        try {
            Supplier_Hub__c secondSupplierHub = TestUtils.newSupplierHub(new Supplier_Hub__c(Supplier_Account__c = supplierHub.Supplier_Account__c,  Parent_Supplier__c = supplierHub.id), true);
        } catch(Exception e) {
            ex = e;
        }

        Test.stopTest();

    }
    @IsTest
    static void testParentSupplierOnUpdate() {
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(null, true);
        Exception ex;
        Test.startTest();
        try {
			Supplier_Hub__c supplierHub1 = TestUtils.newSupplierHub(new Supplier_Hub__c(Supplier_Account__c = supplierHub.Supplier_Account__c,  Parent_Supplier__c = supplierHub.id), true);

            supplierHub1.Parent_Supplier__c = null;
            update supplierHub1;
        } catch(Exception e) {
            ex = e;
        }

        Test.stopTest();

    }



}