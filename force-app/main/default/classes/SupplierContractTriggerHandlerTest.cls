/* *******************************************************************************************************
 * Name               : SupplierContractTriggerHandlerTest                                               *
 * Description        : SRM - Test class for SupplierContractTriggerHandler.cls                                *
 * Created Date       : 07-Aug-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       07-Aug-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
@IsTest
private class SupplierContractTriggerHandlerTest {

    @IsTest
    static void shouldSubscribeSupplierContracts() {
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(null, true);
        List<Supplier_Team__c> supplierTeamList = TestUtils.newSupplierTeams(new Supplier_Team__c(Supplier_Hub__c = supplierHub.Id), 5, true);

        Test.startTest();

        Map<Id, Supplier_Contract__c> supplierContractList = new Map<Id, Supplier_Contract__c>(TestUtils.newSupplierContracts(new Supplier_Contract__c(Supplier_Hub__c = supplierHub.Id), 2, true));

        Test.stopTest();

        Set<String> userIds = Utils.fetchSet(supplierTeamList, 'User__c');

        List<EntitySubscription> entitySubscriptionList = [
                SELECT ParentId
                FROM EntitySubscription
                WHERE SubscriberId IN: userIds
        ];

        System.assert(!entitySubscriptionList.isEmpty());
        for(EntitySubscription es : entitySubscriptionList) {
            System.assert(supplierContractList.containsKey(es.ParentId));
        }
    }



    @IsTest
    static void shouldUpdateSupplierContractSubscription() {
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(null, true);
        List<Supplier_Team__c> supplierTeamList = TestUtils.newSupplierTeams(new Supplier_Team__c(Supplier_Hub__c = supplierHub.Id), 5, true);
        List<Supplier_Contract__c> supplierContractList = TestUtils.newSupplierContracts(new Supplier_Contract__c(Supplier_Hub__c = supplierHub.Id), 2, false);
        for(Supplier_Contract__c sc : supplierContractList) {
            sc.Supplier_Hub__c = null;
        }
        insert supplierContractList;

        Test.startTest();

        List<EntitySubscription> entitySubscriptionBeforeList = [
                SELECT Id
                FROM EntitySubscription
        ];

        for(Supplier_Contract__c sc : supplierContractList) {
            sc.Supplier_Hub__c = supplierHub.Id;
        }
        update supplierContractList;

        Test.stopTest();


        List<EntitySubscription> entitySubscriptionAfterList = [
                SELECT Id
                FROM EntitySubscription
        ];

        System.assert(entitySubscriptionBeforeList.isEmpty());
        System.assert(!entitySubscriptionAfterList.isEmpty());
    }

    @IsTest
    static void shouldSetNextReminderDateOnContractOnInsert() {
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(new Supplier_Hub__c(Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_KEY), true);
        Supplier_Team__c supplierTeam = TestUtils.newSupplierTeam(new Supplier_Team__c(Supplier_Hub__c = supplierHub.Id, Role__c = ConstUtils.SUPPLIER_TEAM_ROLE_CONTRACT_MANAGER), true);
        Supplier_Contract__c supplierContract = TestUtils.newSupplierContract(new Supplier_Contract__c(Supplier_Hub__c = supplierHub.Id, Bonus_clause__c = 'sample'),false);

        Test.startTest();

        insert supplierContract;

        Test.stopTest();

        supplierContract = [SELECT Next_Reminder_Commitment_Clause_Date__c FROM Supplier_Contract__c WHERE Id = :supplierContract.Id];

        System.assertNotEquals(null, supplierContract.Next_Reminder_Commitment_Clause_Date__c);
    }

    @IsTest
    static void shouldSetNextReminderDateOnContractonUpdate() {
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(new Supplier_Hub__c(Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_KEY), true);
        Supplier_Team__c supplierTeam = TestUtils.newSupplierTeam(new Supplier_Team__c(Supplier_Hub__c = supplierHub.Id, Role__c = ConstUtils.SUPPLIER_TEAM_ROLE_CONTRACT_MANAGER), true);
        Supplier_Contract__c supplierContract = TestUtils.newSupplierContract(new Supplier_Contract__c(Supplier_Hub__c = supplierHub.Id),true);

        supplierContract = [SELECT Next_Reminder_Commitment_Clause_Date__c FROM Supplier_Contract__c WHERE Id = :supplierContract.Id];
        Date dateBefore = supplierContract.Next_Reminder_Commitment_Clause_Date__c;

        Test.startTest();

        supplierContract.Bonus_clause__c = 'sample';
        update supplierContract;

        Test.stopTest();

        supplierContract = [SELECT Next_Reminder_Commitment_Clause_Date__c FROM Supplier_Contract__c WHERE Id = :supplierContract.Id];

        System.assertEquals(null, dateBefore);
        System.assertNotEquals(null, supplierContract.Next_Reminder_Commitment_Clause_Date__c);
    }

}