/* *******************************************************************************************************
 * Name               : SRM_TaskTriggerHandler                                                               *
 * Description        : SRM - Trigger handler for Task object                                                  *
 * Created Date       : 07-Aug-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       07-Aug-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
public with sharing class SRM_TaskTriggerHandler extends SRM_TriggerHandler {

    public override void afterInsert() {
        Map<Id, Task> newTaskMap = (Map<Id, Task>)Trigger.newMap;
        postToChatterWithMentions(newTaskMap);
    }
    
    public override void beforeInsert(){
        List<Task> newTaskList = (List<Task>)Trigger.new;
        //Method populating supplier reference
        PopulateSupplierReference.populateSupplier(newTaskList);
        //method Populating SRM Assigned to Field.
        mapSRMAssignedtoField(newTaskList);
        PopulateSupplierReference.populateSupplierforPartners(newTaskList);
    }
    public override void beforeUpdate(){
        List<Task> newTaskList = (List<Task>)Trigger.new;
        //Method populating supplier reference
        PopulateSupplierReference.populateSupplier(newTaskList);
        //method Populating SRM Assigned to Field.
        mapSRMAssignedtoField(newTaskList);
        PopulateSupplierReference.popualteRatingRelatedFields(newTaskList);
    }

    /**
     * @description: when task with Contract Expiry type was created - find users that are subscribing the following record and mention them in a chatter message
     * @param newTaskMap
     */
    private void postToChatterWithMentions(Map<Id, Task> newTaskMap) {
        Map<String, Set<Id>> taskTypeToWhatIdsMap = new Map<String, Set<Id>>();
		Id supplierRrecordTypeId=Schema.SObjectType.Task.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        for(Task task : newTaskMap.values()) {
            //check if whatid is not null and type of supplier contract and if task type is correct to post to chatter
            if(String.isNotBlank(task.WhatId) && task.RecordTypeId == supplierRrecordTypeId && task.WhatId.getSObjectType() == Supplier_Contract__c.SObjectType && String.isNotBlank(task.Type) && (task.Type.equalsIgnoreCase(ConstUtils.TASK_TYPE_CONTRACT_EXPIRY) || task.Type.equalsIgnoreCase(ConstUtils.TASK_TYPE_CLAUSE_CHECK))) {
                if(taskTypeToWhatIdsMap.containsKey(task.Type)) {
                    taskTypeToWhatIdsMap.get(task.Type).add(task.WhatId);
                } else {
                    taskTypeToWhatIdsMap.put(task.Type, new Set<Id> { task.WhatId });
                }
            }
        }
        if(!taskTypeToWhatIdsMap.isEmpty()) {
            Set<Id> whatIdsSet = new Set<Id>();
            for(String taskType : taskTypeToWhatIdsMap.keySet()) {
                whatIdsSet.addAll(taskTypeToWhatIdsMap.get(taskType));
            }
            Map<Id, Supplier_Contract__c> supplierContractMap = new  Map<Id, Supplier_Contract__c>([SELECT End_Date__c, Supplier_Hub__c, OwnerId, Owner.Name FROM Supplier_Contract__c WHERE Id IN: whatIdsSet]);
            Map<Id, List<EntitySubscription>> supplierContractId2entitySubscriptionsMap = new Map<Id, List<EntitySubscription>>();
            //build parentId2entitySubscriptions map
            for(EntitySubscription es : [SELECT ParentId, SubscriberId, Subscriber.Name FROM EntitySubscription WHERE ParentId IN: supplierContractMap.keySet()]) {
                if(taskTypeToWhatIdsMap.containsKey(ConstUtils.TASK_TYPE_CONTRACT_EXPIRY) && taskTypeToWhatIdsMap.get(ConstUtils.TASK_TYPE_CONTRACT_EXPIRY).contains(es.ParentId)) {
                    if(supplierContractId2entitySubscriptionsMap.containsKey(es.ParentId)) {
                        supplierContractId2entitySubscriptionsMap.get(es.ParentId).add(es);
                    } else {
                        supplierContractId2entitySubscriptionsMap.put(es.ParentId, new List<EntitySubscription> { es });
                    }
                }
            }
            for(Id supplierContractId : supplierContractId2entitySubscriptionsMap.keySet()) {
                Integer daysBetween = supplierContractMap.get(supplierContractId).End_Date__c != null ? Date.today().daysBetween(supplierContractMap.get(supplierContractId).End_Date__c) : 90;
                String chatterPostMessage = String.format(Label.SRM_Contract_expires_90_days, new List<String> { String.valueOf(daysBetween) }) + ' ';
                String chatterSupplierMessage = String.format(Label.SRM_Contract_expires_90_days, new List<String> { String.valueOf(daysBetween) }) + ' ';
                for(EntitySubscription es : supplierContractId2entitySubscriptionsMap.get(supplierContractId)) {
                    chatterPostMessage += '{' + es.SubscriberId + '}, ';
                    chatterSupplierMessage += es.Subscriber.Name + ', ';
                }
                chatterPostMessage = chatterPostMessage.removeEndIgnoreCase(', ');
                chatterSupplierMessage = chatterSupplierMessage.removeEndIgnoreCase(', ');
                chatterSupplierMessage = '{record:' + supplierContractId + '} ' + chatterSupplierMessage;
                ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), supplierContractId, chatterPostMessage);
                ConnectApi.FeedItem fiS = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), supplierContractMap.get(supplierContractId).Supplier_Hub__c, chatterSupplierMessage);
            }

            if(taskTypeToWhatIdsMap.containsKey(ConstUtils.TASK_TYPE_CLAUSE_CHECK)) {
                for(Id whatId : taskTypeToWhatIdsMap.get(ConstUtils.TASK_TYPE_CLAUSE_CHECK)) {
                    if(supplierContractMap.containsKey(whatId)) {
                        String chatterContractMessage = Label.SRM_Supplier_Has_Additional_Clauses;
                        String chatterSupplierMessage = Label.SRM_Supplier_Has_Additional_Clauses;
                        chatterContractMessage += ' {' + supplierContractMap.get(whatId).OwnerId + '}';
                        chatterSupplierMessage = '{record:' + whatId + '} ' + chatterSupplierMessage + ' ' + supplierContractMap.get(whatId).Owner.Name;
                        ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), whatId, chatterContractMessage);
                        ConnectApi.FeedItem fiS = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), supplierContractMap.get(whatId).Supplier_Hub__c, chatterSupplierMessage);
                    }
                }
            }
        }
    }
    public static void mapSRMAssignedtoField(List<Task> newList){
         Id supplierRecordTypeId=Schema.SObjectType.Task.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        for(Task objTask: newList){
            if(objTask.RecordTypeId == supplierRecordTypeId && objTask.SRM_Assigned_to__c != NULL){
                objTask.OwnerId =  objTask.SRM_Assigned_to__c;
            }
        }
    }

}