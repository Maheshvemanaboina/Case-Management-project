/* *******************************************************************************************************
 * Name               : SRM_TaskTriggerHandlerTest                                                           *
 * Description        : SRM - Test class for SRM_TaskTriggerHandlerTest.cls                                        *
 * Created Date       : 10-Aug-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       10-Aug-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
@IsTest(SeeAllData=true) /* ConnectApi methods are not supported in data siloed tests. */
private class SRM_TaskTriggerHandlerTest {

    @IsTest
    static void should() {
        Id recordTypeId=Schema.SObjectType.Task.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(null, true);
        Supplier_Contract__c supplierContract = TestUtils.newSupplierContract(new Supplier_Contract__c(Supplier_Hub__c = supplierHub.Id), true);
        List<Supplier_Team__c> supplierTeamList = TestUtils.newSupplierTeams(new Supplier_Team__c(Supplier_Hub__c = supplierHub.Id), 5, true);

        Test.startTest();

        List<Task> tasks = TestUtils.newTasks(new Task(Type = ConstUtils.TASK_TYPE_CONTRACT_EXPIRY, WhatId = supplierContract.Id, recordtypeId = recordTypeId), 2, true);

        Test.stopTest();
    }


}