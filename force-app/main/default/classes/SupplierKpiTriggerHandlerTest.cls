/* *******************************************************************************************************
 * Name               : SupplierKpiTriggerHandlerTest                                                    *
 * Description        : SRM - Test class for SupplierKpiTriggerHandler                                         *
 * Created Date       : 07-Aug-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       17-Aug-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
@IsTest(SeeAllData=true) //ConnectApi methods are not supported in data siloed tests
private class SupplierKpiTriggerHandlerTest {

    @IsTest
    static void shouldMentionSupplierTeamMemberAndContractOwner() {
        Supplier_KPI__c supplierKPI = TestUtils.newSupplierKPI(new Supplier_KPI__c(Source__c = ConstUtils.SUPPLIER_KPI_SOURCE_SUPPLIER), false);
        Supplier_Team__c supplierTeam = TestUtils.newSupplierTeam(new Supplier_Team__c(Supplier_Hub__c = supplierKPI.Supplier_Hub__c, Role__c = ConstUtils.SUPPLIER_TEAM_ROLE_BUYER), true);

        Test.startTest();

        insert supplierKPI;

        Test.stopTest();

    }

}