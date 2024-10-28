/* *******************************************************************************************************
 * Name               : ValueElementTriggerHandlerTest                                                   *
 * Description        : SRM - Test class for ValueElementTriggerHandler                                        *
 * Created Date       : 04-Aug-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       04-Aug-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
@IsTest
private class  ValueElementTriggerHandlerTest {

    @TestSetup
    static void testSetup() {
        List<Account> accounts = TestUtils.newAccounts(null, 2, true);
        List<Supplier_Hub__c> supplierHubs = new List<Supplier_Hub__c> {
                TestUtils.newSupplierHub(new Supplier_Hub__c(Supplier_Account__c = accounts[0].Id, Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_STRATEGIC), false),
                TestUtils.newSupplierHub(new Supplier_Hub__c(Supplier_Account__c = accounts[1].Id, Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_STRATEGIC), false)
        };
        insert supplierHubs;
        List<Supplier_Location__c> supplierLocations = new List<Supplier_Location__c>{
                TestUtils.newSupplierLocation(new Supplier_Location__c(Supplier_Hub__c = supplierHubs[0].Id), false)};
        
        list<Location__c> locs = [select id, Is_Active__c FROM Location__c]; 
        for(Location__c lo : locs ){
            lo.Is_Active__c  = true;
        }
        
        update locs;
        
        insert supplierLocations;
    }

    @IsTest
    static void shouldAttachNewValueElementsToSupplier() {

        Integer countBefore = [SELECT count() FROM Supplier_Rating__c];
        Test.startTest();

        List<Value_Element__c> valueElements = TestUtils.newValueElements(new Value_Element__c(Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_STRATEGIC, Is_Active__c = true), 4, true);

        Test.stopTest();

        Integer countAfter = [SELECT count() FROM Supplier_Rating__c];
        System.assertEquals(0, countBefore);
        //System.assertEquals(4, countAfter);

    }

    @IsTest
    static void shouldDeleteSupplierRatings() {

        Integer countBefore = [SELECT count() FROM Supplier_Rating__c];

        List<Value_Element__c> valueElements = TestUtils.newValueElements(new Value_Element__c(Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_STRATEGIC, Is_Active__c = true), 4, true);

        Test.startTest();

        for(Value_Element__c ve : valueElements) {
            ve.Is_Active__c = false;
        }

        update valueElements;

        Test.stopTest();

        Integer countAfter = [SELECT count() FROM Supplier_Rating__c];
        System.assertEquals(0, countBefore);
    }

    @IsTest
    static void shouldNotAllowDelete() {

        Exception ex;
        List<Value_Element__c> valueElements = TestUtils.newValueElements(new Value_Element__c(Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_STRATEGIC, Is_Active__c = true), 4, true);

        Test.startTest();

        try {
            delete valueElements;
        } catch(Exception e) {
            ex = e;
        }

        Test.stopTest();

        System.assertNotEquals(null, ex);
    }


}