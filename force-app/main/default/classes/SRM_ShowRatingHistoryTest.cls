@IsTest
public class SRM_ShowRatingHistoryTest {
    @IsTest
    static void testListReturned() {
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(new Supplier_Hub__c(Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_STRATEGIC), true);
        List<Supplier_Rating__c> supplierRatings = TestUtils.newSupplierRatings(new Supplier_Rating__c(Supplier_Hub__c = supplierHub.Id), 5, true);
        Test.startTest();
        Test.setCurrentPage(Page.SRM_showHistoryData);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(supplierRatings);
         stdSetController.setSelected(supplierRatings);
        SRM_ShowRatingHistory ext = new SRM_ShowRatingHistory(stdSetController);
        Test.stopTest();

    }

}