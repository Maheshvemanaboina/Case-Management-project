/* *******************************************************************************************************
 * Name               : SupplierTeamTriggerHandler                                                       *
 * Description        : SRM - Trigger handler for Supplier_Team__c object                                      *
 * Created Date       : 06-Aug-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       06-Aug-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
/* without sharing needed for contact creation method */
public without sharing class SupplierTeamTriggerHandler extends SRM_TriggerHandler {

    public override void beforeInsert(){
        List<Supplier_Team__c> newSupplierTeamList = (List<Supplier_Team__c>) Trigger.new;
        populateSearchableField(newSupplierTeamList);

    }

    public override void beforeUpdate(){
        Map<Id, Supplier_Team__c> newSupplierTeamMap = (Map<Id, Supplier_Team__c>) Trigger.newMap;
        populateSearchableField(newSupplierTeamMap.values());
    }

    public override void afterInsert() {
        Map<Id, Supplier_Team__c> newSupplierTeamMap = (Map<Id, Supplier_Team__c>) Trigger.newMap;

        populateFieldsOnPortalRecordCreation(newSupplierTeamMap.values());
        subscribeSupplierContracts(null, newSupplierTeamMap);
        createContact(newSupplierTeamMap);
    }


    public override void afterUpdate() {
        Map<Id, Supplier_Team__c> oldSupplierTeamMap = (Map<Id, Supplier_Team__c>) Trigger.oldMap;
        Map<Id, Supplier_Team__c> newSupplierTeamMap = (Map<Id, Supplier_Team__c>) Trigger.newMap;

        subscribeSupplierContracts(oldSupplierTeamMap, newSupplierTeamMap);
        
        //removing udpate contact method.
        //updateContact(oldSupplierTeamMap, newSupplierTeamMap);
    }

    public override void afterDelete() {
        Map<Id, Supplier_Team__c> oldSupplierTeamMap = (Map<Id, Supplier_Team__c>) Trigger.oldMap;
        deleteContractSubscriptions(oldSupplierTeamMap);
    }


    /**
     * @description: if new supplier team is inserted or updated and meets the required conditions, make this user subscribe to a all supplier contracts related to supplier hub record
     * @param oldSupplierTeamMap
     * @param newSupplierTeamMap
     */
    private void subscribeSupplierContracts(Map<Id, Supplier_Team__c> oldSupplierTeamMap, Map<Id, Supplier_Team__c> newSupplierTeamMap) {
        Map<Id, List<Supplier_Team__c>> supplierId2supplierTeamsMap = new Map<Id, List<Supplier_Team__c>>();
        Map<Id, User> usersMap = new Map<Id, User>();

        if(oldSupplierTeamMap == null && newSupplierTeamMap != null) { //insert
            for(Supplier_Team__c newSt : newSupplierTeamMap.values()) {
                if(newSt.Type__c == ConstUtils.SUPPLIER_TEAM_TYPE_INTERNAL && String.isNotBlank(newSt.User__c) && String.isNotBlank(newSt.Supplier_Hub__c)) {
                    if(supplierId2supplierTeamsMap.containsKey(newSt.Supplier_Hub__c)) {
                        supplierId2supplierTeamsMap.get(newSt.Supplier_Hub__c).add(newSt);
                    } else {
                        supplierId2supplierTeamsMap.put(newSt.Supplier_Hub__c, new List<Supplier_Team__c> { newSt });
                    }
                    usersMap.put(newSt.User__c, new User(Id = newSt.User__c));
                }
            }
        } else if(oldSupplierTeamMap != null && newSupplierTeamMap != null) { //update
            for(Supplier_Team__c newSt : newSupplierTeamMap.values()) {
                Supplier_Team__c oldSt = oldSupplierTeamMap.get(newSt.Id);
                if(
                        (oldSt.Type__c != newSt.Type__c && newSt.Type__c == ConstUtils.SUPPLIER_TEAM_TYPE_INTERNAL) ||
                                (oldSt.User__c != newSt.User__c && String.isNotBlank(newSt.User__c)) ||
                                (oldSt.Supplier_Hub__c != newSt.Supplier_Hub__c && String.isNotBlank(newSt.Supplier_Hub__c))
                        ) {
                    if(supplierId2supplierTeamsMap.containsKey(newSt.Supplier_Hub__c)) {
                        supplierId2supplierTeamsMap.get(newSt.Supplier_Hub__c).add(newSt);
                    } else {
                        supplierId2supplierTeamsMap.put(newSt.Supplier_Hub__c, new List<Supplier_Team__c> { newSt });
                    }
                    usersMap.put(newSt.User__c, new User(Id = newSt.User__c));
                }
            }
        }

        if(!supplierId2supplierTeamsMap.isEmpty()) {
            //do not allow duplicates
            Set<EntitySubscription> entitySubscriptionInsertList = new Set<EntitySubscription>();
            usersMap = new Map<Id, User>([SELECT IsActive, UserType FROM User WHERE Id IN: usersMap.keySet()]);

            for(Supplier_Contract__c sc : [
                    SELECT Supplier_Hub__c
                    FROM Supplier_Contract__c
                    WHERE Supplier_Hub__c =: supplierId2supplierTeamsMap.keySet()
            ]) {
                for(Supplier_Team__c st : supplierId2supplierTeamsMap.get(sc.Supplier_Hub__c)) {
                    if(usersMap.containsKey(st.User__c) && usersMap.get(st.User__c).IsActive && usersMap.get(st.User__c).UserType == ConstUtils.USER_USER_TYPE_STANDARD) {
                        entitySubscriptionInsertList.add(new EntitySubscription(ParentId = sc.Id, SubscriberId = st.User__c));
                    }
                }
            }

            if(!entitySubscriptionInsertList.isEmpty()) {
                //use database.insert since there might be already subscription on specific records done - even manually
                Database.insert(new List<EntitySubscription>(entitySubscriptionInsertList), false);
            }
        }

    }

    /**
     * @description: when supplier team member is deleted unsubscribe the supplier contracts
     * @param oldSupplierTeamMap
     */
    private void deleteContractSubscriptions(Map<Id, Supplier_Team__c> oldSupplierTeamMap) {
        Set<String> userIds = Utils.fetchSet(oldSupplierTeamMap.values(), 'User__c');
        Set<String> supplierHubIds = Utils.fetchSet(oldSupplierTeamMap.values(), 'Supplier_Hub__c');
        if(!userIds.isEmpty() && !supplierHubIds.isEmpty()) {
            Map<Id, Supplier_Contract__c> supplierContractList = new Map<Id, Supplier_Contract__c>([
                    SELECT Supplier_Hub__c
                    FROM Supplier_Contract__c
                    WHERE Supplier_Hub__c =: supplierHubIds
            ]);

            List<EntitySubscription> entitySubscriptionList = [
                    SELECT Id
                    FROM EntitySubscription
                    WHERE ParentId IN: supplierContractList.keySet()
                    AND SubscriberId IN: userIds
            ];

            if(!entitySubscriptionList.isEmpty()) {
                delete entitySubscriptionList;
            }
        }
    }


    private static void createContact(Map<Id, Supplier_Team__c> newSupplierTeamMap)
    {
        Map<Id, Contact> supplierTeamIdToContactMap = new Map<Id, Contact>();
        Set<String> supplierTeamIds = Utils.fetchSet(newSupplierTeamMap.values(), 'Id');
        if(supplierTeamIds != null && supplierTeamIds.size() > 0){
            List<Supplier_Team__c> supplierTeamList = [SELECT Id, Name, Account__c, Contact__c, Supplier_Hub__c, Supplier_Hub__r.OwnerId, Account__r.OwnerId, Contact_First_Name__c, Contact_Last_Name__c, Contact_Email__c, Contact_Phone__c FROM Supplier_Team__c WHERE Contact__c = null AND Id IN :supplierTeamIds];
            for(Supplier_Team__c st: supplierTeamList){
                if(( (st.Supplier_Hub__c != null && st.Supplier_Hub__r.OwnerId != null) || (st.Account__c != null && st.Account__r.OwnerId != null) )
                        && st.Contact_Last_Name__c != null
                        && st.Contact_Email__c != null){
                    Contact newContact = new Contact();
                    newContact.RecordTypeId = ConstUtils.CONTACT_RECORD_TYPE;
                    newContact.FirstName = (st.Contact_First_Name__c != null) ? st.Contact_First_Name__c : '';
                    newContact.LastName = st.Contact_Last_Name__c;
                    newContact.Email = st.Contact_Email__c;
                    newContact.Phone = st.Contact_Phone__c;
                    newContact.AccountId = st.Account__c;
                    newContact.OwnerId = (st.Supplier_Hub__r.OwnerId != null) ? st.Supplier_Hub__r.OwnerId : st.Account__r.OwnerId;
                    supplierTeamIdToContactMap.put(st.Id, newContact);
                }
            }
            if(supplierTeamIdToContactMap.values().size() > 0){
                try {
                    insert supplierTeamIdToContactMap.values();
                    Boolean shouldUpdate = false;
                    for(Supplier_Team__c st : supplierTeamList){
                        if(supplierTeamIdToContactMap.get(st.Id) != null && supplierTeamIdToContactMap.get(st.Id).Id != null){
                            st.Contact__c = supplierTeamIdToContactMap.get(st.Id).Id;
                            shouldUpdate = true;
                        }
                    }
                    if(shouldUpdate){
                        update supplierTeamList;
                    }
                } catch (DmlException ex){
                    if(ex.getDmlType(0) == System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                        newSupplierTeamMap.values().get(0).addError(ex.getDmlMessage(0));
                    } else {
                        throw ex;
                    }
                }
            }
        }
    }

    /**
    * @description: when supplier team record is updated by portal user updates Contact record
    * @param newSupplierTeamMap
    
    private void updateContact(Map<Id, Supplier_Team__c> oldSupplierTeamMap, Map<Id, Supplier_Team__c> newSupplierTeamMap) {
        List<Contact> toUpdate = new List<Contact>();
        if(newSupplierTeamMap != null && newSupplierTeamMap.values().size() > 0){
            for(Id stId : newSupplierTeamMap.keySet()) {
                if(oldSupplierTeamMap != null && oldSupplierTeamMap.get(stId) != null && newSupplierTeamMap.get(stId) != null &&
                        newSupplierTeamMap.get(stId).Contact__c != null &&
                        (
                                (newSupplierTeamMap.get(stId).Contact_Email__c != null && oldSupplierTeamMap.get(stId).Contact_Email__c != newSupplierTeamMap.get(stId).Contact_Email__c) ||
                                        (newSupplierTeamMap.get(stId).Contact_First_Name__c != null && oldSupplierTeamMap.get(stId).Contact_First_Name__c != newSupplierTeamMap.get(stId).Contact_First_Name__c) ||
                                        (newSupplierTeamMap.get(stId).Contact_Last_Name__c != null && oldSupplierTeamMap.get(stId).Contact_Last_Name__c != newSupplierTeamMap.get(stId).Contact_Last_Name__c) ||
                                        (newSupplierTeamMap.get(stId).Contact_Phone__c != null && oldSupplierTeamMap.get(stId).Contact_Phone__c != newSupplierTeamMap.get(stId).Contact_Phone__c)
                        )
                        ){
                    toUpdate.add(new Contact(
                            Id = newSupplierTeamMap.get(stId).Contact__c,
                            Email= newSupplierTeamMap.get(stId).Contact_Email__c,
                            FirstName = newSupplierTeamMap.get(stId).Contact_First_Name__c,
                            LastName = newSupplierTeamMap.get(stId).Contact_Last_Name__c,
                            Phone = newSupplierTeamMap.get(stId).Contact_Phone__c,
                        	MobilePhone = newSupplierTeamMap.get(stId).Contact_Mobile__c
                    ));
                }
            }
        }

        if(!toUpdate.isEmpty()) {
            try {
                update toUpdate;
            } catch (DmlException ex){
                if(ex.getDmlType(0) == System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                    newSupplierTeamMap.values().get(0).addError(ex.getDmlMessage(0));
                } else {
                    throw ex;
                }
            }
        }
    }*/

    private static void populateSearchableField(List<Supplier_Team__c> newSupplierTeamList)
    {
        List<Id> contactIds = new List<Id>();
        List<Id> userIds = new List<Id>();
        if(newSupplierTeamList != null && newSupplierTeamList.size() > 0){
            for(Supplier_Team__c st: newSupplierTeamList){
                if(st.Contact__c != null  && ! st.User_Without_Supplier_Connect_Account__c){
                    contactIds.add(st.Contact__c);
                }
                if(st.User__c != null  && ! st.User_Without_Supplier_Connect_Account__c){
                    userIds.add(st.User__c);
                }
                if(st.User_Without_Supplier_Connect_Account__c){
                	String searchableName = '';
                    searchableName = st.First_Name__c + ' '+ st.Last_Name__c;
                    st.Searchable_Name__c = searchableName;
            	}
            }
            for(User usr : [SELECT Id, FirstName, LastName, Email FROM User WHERE Id IN :userIds]){
                for(Supplier_Team__c st: newSupplierTeamList){
                    if(st.User__c != null && usr.Id != null && st.User__c == usr.Id ){
                        String searchableName = '';
                        if(usr.FirstName != null) searchableName += usr.FirstName + ' ';
                        if(usr.LastName != null)  searchableName += usr.LastName;
                        if(searchableName.length() >0){
                            st.Searchable_Name__c = searchableName;
                        }
                    }
                }
            }

            for(Contact cont : [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id IN :contactIds]){
                for(Supplier_Team__c st: newSupplierTeamList){
                    if(st.Contact__c != null && cont.Id != null && st.Contact__c == cont.Id ){
                        String searchableName = '';
                        if(cont.FirstName != null) searchableName += cont.FirstName + ' ';
                        if(cont.LastName != null)  searchableName += cont.LastName;
                        if(searchableName.length() >0){
                            st.Searchable_Name__c = searchableName;
                        }
                    }
                }
            }
            
        }
    }

    /**
     * @description: when supplier team record is created by portal user, fill in Supplier_Hub__c and Account__c fields in backend
     * @param newSupplierTeamMap
     */
    private void populateFieldsOnPortalRecordCreation(List<Supplier_Team__c> newSupplierTeamList) {
        if(newSupplierTeamList != NULL) {
            Map<Id, List<Supplier_Team__c>> creatorId2SupplierTeamsMap = new Map<Id, List<Supplier_Team__c>>();
            List<Supplier_Team__c> supplierTeamToPopulateList = new List<Supplier_Team__c>();
            for(Supplier_Team__c st : newSupplierTeamList) {
                if(st.Created_By_Portal_User__c && (String.isBlank(st.Supplier_Hub__c) || String.isBlank(st.Account__c))) {
                    supplierTeamToPopulateList.add(st);
                    if(creatorId2SupplierTeamsMap.containsKey(st.CreatedById)) {
                        creatorId2SupplierTeamsMap.get(st.CreatedById).add(st);
                    } else {
                        creatorId2SupplierTeamsMap.put(st.CreatedById, new List<Supplier_Team__c> { st });
                    }
                }
            }

            if(!supplierTeamToPopulateList.isEmpty()) {
                supplierTeamToPopulateList = [SELECT Supplier_Hub__c, Account__c, CreatedBy.Contact.AccountId, CreatedBy.Supplier_Hub_ID__c FROM Supplier_Team__c WHERE Id IN :supplierTeamToPopulateList];

                for(Supplier_Team__c st : supplierTeamToPopulateList) {
                    if(String.isBlank(st.Account__c)) {
                        st.Account__c = st.CreatedBy.Contact.AccountId;
                    }
                    if(String.isBlank(st.Supplier_Hub__c)) {
                        st.Supplier_Hub__c = st.CreatedBy.Supplier_Hub_ID__c;
                    }
                }

                update supplierTeamToPopulateList;
            }
        }
    }
}