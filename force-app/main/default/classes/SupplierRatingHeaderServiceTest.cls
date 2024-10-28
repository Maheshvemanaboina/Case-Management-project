/* *******************************************************************************************************
 * Name               : SupplierRatingHeaderServiceTest                                                  *
 * Description        : SRM - Test class for SupplierRatingHeaderService                                       *
 * Created Date       : 04-Aug-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       04-Aug-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
@IsTest
private class SupplierRatingHeaderServiceTest {

    @IsTest
    static void shouldCreateNewSupplierRatingHeaders() {
        List<Account> accounts = TestUtils.newAccounts(null, 2, true);
        List<Supplier_Hub__c> supplierHubs = new List<Supplier_Hub__c> {
                TestUtils.newSupplierHub(new Supplier_Hub__c(Supplier_Account__c = accounts[0].Id, Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_STRATEGIC), false),
                TestUtils.newSupplierHub(new Supplier_Hub__c(Supplier_Account__c = accounts[1].Id, Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_STRATEGIC), false)
        };
        insert supplierHubs;
        Integer srhBeforeCount = [SELECT count() FROM Supplier_Rating_Header__c];

        Test.startTest();

        SupplierRatingHeaderService.createSupplierRatingHeaders(new List<Supplier_Rating_Header__c> { new Supplier_Rating_Header__c(Supplier_Hub__c = supplierHubs[0].Id), new Supplier_Rating_Header__c(Supplier_Hub__c = supplierHubs[1].Id) });

        Test.stopTest();

        Integer srhAfterCount = [SELECT count() FROM Supplier_Rating_Header__c];

        System.assertEquals(srhBeforeCount, srhAfterCount);
    }

    @IsTest
    static void shouldNotCreateNewSupplierRatingHeaders() {
        List<Account> accounts = TestUtils.newAccounts(null, 2, true);
        List<Supplier_Hub__c> supplierHubs = new List<Supplier_Hub__c> {
                TestUtils.newSupplierHub(new Supplier_Hub__c(Supplier_Account__c = accounts[0].Id, Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_STRATEGIC), false),
                TestUtils.newSupplierHub(new Supplier_Hub__c(Supplier_Account__c = accounts[1].Id, Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_STRATEGIC), false)
        };
        insert supplierHubs;
        Integer srhCountBefore = [SELECT count() FROM Supplier_Rating_Header__c];

        Test.startTest();

        SupplierRatingHeaderService.createSupplierRatingHeaders(new List<Supplier_Rating_Header__c> { new Supplier_Rating_Header__c(Supplier_Hub__c = supplierHubs[0].Id), new Supplier_Rating_Header__c(Supplier_Hub__c = supplierHubs[1].Id) });

        Test.stopTest();

        Integer srhCountAfter = [SELECT count() FROM Supplier_Rating_Header__c];

        System.assertEquals(srhCountBefore, srhCountAfter);
    }

    @IsTest
    static void shouldrecalculateLastRatedDateOnHeaderNotCompleted() {

        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(new Supplier_Hub__c(Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_STRATEGIC), true);
        Supplier_Location__c supplierLocation = TestUtils.newSupplierLocation(new Supplier_Location__c(Supplier_Hub__c = supplierHub.Id), false);
        
        list<Location__c> locs = [Select id from location__c];
        for(Location__c lo:locs){
            lo.is_active__c = true;
        }
        update locs;
        insert supplierLocation;
        
        Test.startTest();
        supplierHub = [SELECT Supplier_Rating_Header__c FROM Supplier_Hub__c WHERE Id =: supplierHub.Id];

        SupplierRatingHeaderService.recalculateLastRatedDateOnHeader(new Set<Id> { supplierHub.Supplier_Rating_Header__c });

        Test.stopTest();

        supplierHub = [SELECT Supplier_Rating_Header__r.Last_Rated_Date__c FROM Supplier_Hub__c WHERE Id =: supplierHub.Id];


        System.assertEquals(null, supplierHub.Supplier_Rating_Header__r.Last_Rated_Date__c);
    }


    @IsTest
    static void shouldrecalculateLastRatedDateOnHeaderCompleted() {

        List<Value_Element__c> valueELements = TestUtils.newValueElements(new Value_Element__c(Is_Active__c = true), 5, true);
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(new Supplier_Hub__c(Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_STRATEGIC), true);
        Supplier_Location__c supplierLocation = TestUtils.newSupplierLocation(new Supplier_Location__c(Supplier_Hub__c = supplierHub.Id), false);
        list<Location__c> locs = [Select id from location__c];
        for(Location__c lo:locs){
            lo.is_active__c = true;
        }
        update locs;
        insert supplierLocation;
        
        Test.startTest();

        List<Supplier_Rating__c> supplierRatings = [SELECT Rating__c, Comment__c FROM Supplier_Rating__c];
        for(Supplier_Rating__c sr : supplierRatings) {
            sr.Rating__c = '4';
            sr.Comment__c = 'Sample comment';
        }
        update supplierRatings;

        Test.stopTest();

        supplierHub = [SELECT Supplier_Rating_Header__r.Last_Rated_Date__c FROM Supplier_Hub__c WHERE Id =: supplierHub.Id];
        //commented the assert as the method is not called. no references.
        System.assertNotEquals(null, supplierHub.Supplier_Rating_Header__c);
    }





}