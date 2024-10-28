/* *******************************************************************************************************
 * Name               : SupplierContractTriggerHandler                                                   *
 * Description        : SRM - Trigger handler for Supplier_Contract__c object                                  *
 * Created Date       : 06-Aug-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       06-Aug-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
public with sharing class SupplierContractTriggerHandler extends SRM_TriggerHandler {


    public override void beforeInsert() {
        List<Supplier_Contract__c> newSupplierContractList = (List<Supplier_Contract__c>) Trigger.new;
        setNextReminderDateOnContract(null, newSupplierContractList);
    }

    public override void afterInsert() {
        Map<Id, Supplier_Contract__c> newSupplierContractMap = (Map<Id, Supplier_Contract__c>) Trigger.newMap;

        subscribeSupplierContracts(null, newSupplierContractMap);
    }

    public override void beforeUpdate() {
        Map<Id, Supplier_Contract__c> oldSupplierContractMap = (Map<Id, Supplier_Contract__c>) Trigger.oldMap;
        Map<Id, Supplier_Contract__c> newSupplierContractMap = (Map<Id, Supplier_Contract__c>) Trigger.newMap;
        setNextReminderDateOnContract(oldSupplierContractMap, newSupplierContractMap.values());
    }

    public override void afterUpdate() {
        Map<Id, Supplier_Contract__c> oldSupplierContractMap = (Map<Id, Supplier_Contract__c>) Trigger.oldMap;
        Map<Id, Supplier_Contract__c> newSupplierContractMap = (Map<Id, Supplier_Contract__c>) Trigger.newMap;

        subscribeSupplierContracts(oldSupplierContractMap, newSupplierContractMap);
    }

    private void subscribeSupplierContracts(Map<Id, Supplier_Contract__c> oldSupplierContractMap, Map<Id, Supplier_Contract__c> newSupplierContractMap) {
        Map<Id, List<Supplier_Contract__c>> supplierId2supplierContractMap = new Map<Id, List<Supplier_Contract__c>>();
        List<Supplier_Contract__c> supplierContractsToQueryAdditionalInfoList = new List<Supplier_Contract__c>();
        Map<Id, User> userMap = new Map<Id, User>();

        if(oldSupplierContractMap == null && newSupplierContractMap != null) { //insert
            for(Supplier_Contract__c newSc : newSupplierContractMap.values()) {
                if(String.isNotBlank(newSc.Supplier_Hub__c)) {
                    if(supplierId2supplierContractMap.containsKey(newSc.Supplier_Hub__c)) {
                        supplierId2supplierContractMap.get(newSc.Supplier_Hub__c).add(newSc);
                    } else {
                        supplierId2supplierContractMap.put(newSc.Supplier_Hub__c, new List<Supplier_Contract__c> { newSc });
                    }
                }
            }
        } else if(oldSupplierContractMap != null && newSupplierContractMap != null) { //update
            for (Supplier_Contract__c newSc : newSupplierContractMap.values()) {
                Supplier_Contract__c oldSc = oldSupplierContractMap.get(newSc.Id);
                if(oldSc.Supplier_Hub__c != newSc.Supplier_Hub__c && String.isNotBlank(newSc.Supplier_Hub__c)) {
                    if(supplierId2supplierContractMap.containsKey(newSc.Supplier_Hub__c)) {
                        supplierId2supplierContractMap.get(newSc.Supplier_Hub__c).add(newSc);
                    } else {
                        supplierId2supplierContractMap.put(newSc.Supplier_Hub__c, new List<Supplier_Contract__c> { newSc });
                    }
                }else if(oldSc.OwnerId != newSc.OwnerId  && String.isNotBlank(newSc.Supplier_Hub__c)) {
                    supplierContractsToQueryAdditionalInfoList.add(newSc);
                    userMap.put(newSc.OwnerId, new User(Id = newSc.OwnerId));
                }
            }
        }

        if(!supplierId2supplierContractMap.isEmpty()) {
            //do not allow duplicate records
            Set<EntitySubscription> entitySubscriptionInsertList = new Set<EntitySubscription>();
            userMap = new Map<Id, User>([SELECT IsActive, UserType FROM User WHERE Id IN :userMap.keySet()]);
            //for each supplier team member subsribe for a contract
            for(Supplier_Team__c st : [
                    SELECT User__c, User__r.IsActive, User__r.UserType, Supplier_Hub__c
                    FROM Supplier_Team__c
                    WHERE Supplier_Hub__c =: supplierId2supplierContractMap.keySet()
            ]) {
                if(st.User__r.IsActive && st.User__r.UserType == ConstUtils.USER_USER_TYPE_STANDARD) {
                    for(Supplier_Contract__c sc : supplierId2supplierContractMap.get(st.Supplier_Hub__c)) {
                        entitySubscriptionInsertList.add(new EntitySubscription(ParentId = sc.Id, SubscriberId = st.User__c));
                    }
                }
            }
            //contract owner should have a contract subscrition as well
            for(Supplier_Contract__c sc : supplierContractsToQueryAdditionalInfoList) {
                if(userMap.containsKey(sc.OwnerId) && userMap.get(sc.OwnerId).IsActive && userMap.get(sc.OwnerId).UserType == ConstUtils.USER_USER_TYPE_STANDARD) {
                    entitySubscriptionInsertList.add(new EntitySubscription(ParentId = sc.Id, SubscriberId = sc.OwnerId));
                }
            }
            if(!entitySubscriptionInsertList.isEmpty()) {
                insert new List<EntitySubscription>(entitySubscriptionInsertList);
            }

        }
    }

    private void setNextReminderDateOnContract(Map<Id, Supplier_Contract__c> oldSupplierContractMap, List<Supplier_Contract__c> newSupplierContractList) {
        List<Supplier_Contract__c> supplierContractList = new List<Supplier_Contract__c>();
        Set<Id> supplierHubIds = new Set<Id>();

        if(oldSupplierContractMap == null && newSupplierContractList != null) { //insert
            for(Supplier_Contract__c newSc : newSupplierContractList) {
                if(String.isNotBlank(newSc.Supplier_Hub__c)  && ( String.isNotBlank(newSc.Volume_commitment_given_by_FC__c) || String.isNotBlank(newSc.Bonus_clause__c) )) {
                    supplierContractList.add(newSc);
                    supplierHubIds.add(newSc.Supplier_Hub__c);
                }
            }
        } else if(oldSupplierContractMap != null && newSupplierContractList != null) { //update
            for (Supplier_Contract__c newSc : newSupplierContractList) {
                Supplier_Contract__c oldSc = oldSupplierContractMap.get(newSc.Id);
                if(String.isNotBlank(newSc.Supplier_Hub__c) && ( String.isNotBlank(newSc.Volume_commitment_given_by_FC__c) || String.isNotBlank(newSc.Bonus_clause__c) )) {
                    if(
                            oldSc.Volume_commitment_given_by_FC__c != newSc.Volume_commitment_given_by_FC__c ||
                            oldSc.Bonus_clause__c != newSc.Bonus_clause__c ||
                            (
                                oldSc.Next_Reminder_Commitment_Clause_Date__c != newSc.Next_Reminder_Commitment_Clause_Date__c &&
                                newSc.Next_Reminder_Commitment_Clause_Date__c == null
                            )
                    ) {
                        supplierContractList.add(newSc);
                        supplierHubIds.add(newSc.Supplier_Hub__c);
                    }
                } else if(String.isBlank(newSc.Volume_commitment_given_by_FC__c) && String.isBlank(newSc.Bonus_clause__c) && newSc.Next_Reminder_Commitment_Clause_Date__c != null) {
                    newSc.Next_Reminder_Commitment_Clause_Date__c = null;
                }
            }
        }


        if(!supplierContractList.isEmpty()) {
            Map<Id, Supplier_Hub__c> supplierHubMap = new Map<Id, Supplier_Hub__c>([SELECT Segment__c FROM Supplier_Hub__c WHERE Id IN :supplierHubIds]);
            for(Supplier_Contract__c sc : supplierContractList) {
                if(supplierHubMap.get(sc.Supplier_Hub__c).Segment__c == ConstUtils.SUPPLIER_HUB_SEGMENT_STRATEGIC) {
                    sc.Next_Reminder_Commitment_Clause_Date__c = Date.today().addMonths(3);
                } else if(supplierHubMap.get(sc.Supplier_Hub__c).Segment__c == ConstUtils.SUPPLIER_HUB_SEGMENT_KEY || supplierHubMap.get(sc.Supplier_Hub__c).Segment__c == ConstUtils.SUPPLIER_HUB_SEGMENT_MANAGED) {
                    sc.Next_Reminder_Commitment_Clause_Date__c = Date.today().addMonths(6);
                }
            }
        }
    }
}