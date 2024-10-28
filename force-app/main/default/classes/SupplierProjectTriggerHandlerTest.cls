/* *******************************************************************************************************
 * Name               : SupplierProjectTriggerHandlerTest                                                *
 * Description        : SRM - Test class for SupplierProjectTriggerHandler                                     *
 * Created Date       : 27-Aug-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       27-Aug-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
@IsTest
private class SupplierProjectTriggerHandlerTest {

    @isTest
    static void shouldCreateShareRecordOnInsert() {

        Test.startTest();

        Supplier_Project__c supplierProject = TestUtils.newSupplierProject(new Supplier_Project__c(Type__c = ConstUtils.SUPPLIER_PROJECT_TYPE_EXTERNAL), true);

        Test.stopTest();
    }

    @isTest
    static void shouldCreateShareRecordOnUpdate() {

        Supplier_Project__c supplierProject = TestUtils.newSupplierProject(new Supplier_Project__c(), true);

        Test.startTest();

        supplierProject.Type__c = ConstUtils.SUPPLIER_PROJECT_TYPE_EXTERNAL;
        update supplierProject;

        Test.stopTest();
    }
    @isTest
    static void testAccountToshareWithFeild() {
        Supplier_Project__c supplierProject = TestUtils.newSupplierProject(new Supplier_Project__c(), false);
        supplierProject.Type__c = 'External';
        Test.startTest();
        insert supplierProject;
        Test.stopTest();
        Supplier_Project__c supplierProject1 = [select id, Account_to_share_with__c FROM Supplier_Project__c where Account_to_share_with__c != NULL limit 1];
        system.assert(supplierProject1.Account_to_share_with__c != null);
    }
    @isTest
    static void testAccountToshareWithFeildUpdate() {
        Supplier_Project__c supplierProject = TestUtils.newSupplierProject(new Supplier_Project__c(), false);
        supplierProject.Type__c = 'External';
        insert supplierProject;
        Test.startTest();
        supplierProject.Type__c = 'Internal';
        update supplierProject;
        Test.stopTest();
        Supplier_Project__c supplierProject1 = [select id, Account_to_share_with__c FROM Supplier_Project__c where Account_to_share_with__c = NULL limit 1];
        system.assert(supplierProject1.Account_to_share_with__c == null);
    }
    


}