@isTest 
public class SRM_ListviewButtonControllerTest {
    @isTest static void testAccountOpportunity(){  
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(new Supplier_Hub__c(Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_STRATEGIC), true);
        List<Supplier_Rating__c> supplierRatings = TestUtils.newSupplierRatings(new Supplier_Rating__c(Supplier_Hub__c = supplierHub.Id), 5, true);
        ApexPages.StandardSetController sc = new  ApexPages.StandardSetController(supplierRatings);   
        PageReference testPage = Page.SRM_ShowHelpTextVF; 
        testPage.getParameters().put('vfRetURLInSFX', String.valueOf('testAccountPlanInsert.Id'));
        Test.setCurrentPage(testPage);
        SRM_ListviewButtonController tesSRM_ShowHelpTextVF = new SRM_ListviewButtonController(sc);
    }
    
}