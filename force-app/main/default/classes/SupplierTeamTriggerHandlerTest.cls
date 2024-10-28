/* *******************************************************************************************************
 * Name               : SupplierTeamTriggerHandlerTest                                                   *
 * Description        : SRM - Test class for SupplierTeamTriggerHandler.cls                                    *
 * Created Date       : 07-Aug-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       07-Aug-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
@IsTest
private class SupplierTeamTriggerHandlerTest {

    @IsTest
    static void shouldSubscribeSupplierContracts() {
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(null, true);
        Map<Id, Supplier_Contract__c> supplierContractList = new Map<Id, Supplier_Contract__c>(TestUtils.newSupplierContracts(new Supplier_Contract__c(Supplier_Hub__c = supplierHub.Id), 2, true));

        Test.startTest();

        List<Supplier_Team__c> supplierTeamList = TestUtils.newSupplierTeams(new Supplier_Team__c(Supplier_Hub__c = supplierHub.Id), 5, true);

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
    static void shouldDeleteSupplierContractSubscription() {
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(null, true);
        List<Supplier_Contract__c> supplierContractList = TestUtils.newSupplierContracts(new Supplier_Contract__c(Supplier_Hub__c = supplierHub.Id), 2, true);
        List<Supplier_Team__c> supplierTeamList = TestUtils.newSupplierTeams(new Supplier_Team__c(Supplier_Hub__c = supplierHub.Id), 5, true);

        Test.startTest();

        delete supplierTeamList;

        Test.stopTest();


        List<EntitySubscription> entitySubscriptionList = [
                SELECT Id
                FROM EntitySubscription
        ];

        System.assert(entitySubscriptionList.isEmpty());
    }

    @IsTest
    static void shouldUpdateSupplierContractSubscription() {
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(null, true);
        List<Supplier_Contract__c> supplierContractList = TestUtils.newSupplierContracts(new Supplier_Contract__c(Supplier_Hub__c = supplierHub.Id), 2, true);
        List<Supplier_Team__c> supplierTeamList = TestUtils.newSupplierTeams(new Supplier_Team__c(Supplier_Hub__c = supplierHub.Id), 5, false);
        for(Supplier_Team__c st : supplierTeamList) {
            st.User__c = userinfo.getUserId();
            st.Type__c = 'Internal';
        }
        insert supplierTeamList;

        Test.startTest();

        List<EntitySubscription> entitySubscriptionBeforeList = [
                SELECT Id
                FROM EntitySubscription
        ];

        for(Supplier_Team__c st : supplierTeamList) {
            st.User__c = UserInfo.getUserId();
        }
        update supplierTeamList;

        Test.stopTest();


        List<EntitySubscription> entitySubscriptionAfterList = [
                SELECT Id
                FROM EntitySubscription
        ];

        System.assert(! entitySubscriptionBeforeList.isEmpty());
        System.assert(!entitySubscriptionAfterList.isEmpty());
    }

    @IsTest
    static void createAndUpdateContact() {
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(null, true);

        List<Supplier_Team__c> supplierTeamList = TestUtils.newSupplierTeams(new Supplier_Team__c(Supplier_Hub__c = supplierHub.Id), 1, false);
        for(Supplier_Team__c st : supplierTeamList) {
            st.Contact_First_Name__c = 'FirstName';
            st.Contact_Last_Name__c = 'LastName';
            st.Contact_Email__c = 'testcontactemail@waeg.com.test';
            st.Contact_Phone__c = '+48456321789';
        }

        Test.startTest();
            insert supplierTeamList;
            List<Contact> resultList = [SELECT Id FROM Contact WHERE Email = 'testcontactemail@waeg.com.test'];
            System.assertEquals(1, resultList.size());

            for(Supplier_Team__c st : supplierTeamList) {
                st.Contact_Email__c = 'testcontactemailAfterUpdate@waeg.com.test';
            }
            update supplierTeamList;

        Test.stopTest();
        List<Contact> resultList2 = [SELECT Id FROM Contact WHERE Email = 'testcontactemail@waeg.com.test'];
        //System.assertEquals(0, resultList2.size());


    }

}