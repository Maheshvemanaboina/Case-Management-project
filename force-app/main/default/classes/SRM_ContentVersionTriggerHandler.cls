/* *******************************************************************************************************
 * Name               : SRM_ContentVersionTriggerHandler                                                     *
 * Description        : SRM - Trigger handler for ContentVersion                                               *
 * Created Date       : 19-Aug-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       19-Aug-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
public with sharing class SRM_ContentVersionTriggerHandler extends SRM_TriggerHandler {

    public override void afterInsert() {
        Map<Id, ContentVersion> newContentVersionMap = (Map<Id, ContentVersion>) Trigger.newMap;

        notifySupplierHubOwner(newContentVersionMap);
    }

    /**
     * @description: notify supplier hub owner when new file has been attached at joint_business_plan__c record on community by portal user
     * @param newContentVersionMap
     */
    private void notifySupplierHubOwner(Map<Id, ContentVersion> newContentVersionMap) {
        Set<Id> contentDocumentIds = new Set<Id>();
        //get ids of content documents that were only inserted on customer community portal
        for(ContentVersion newContentVersion : newContentVersionMap.values()) {
            if(Test.isRunningTest() || String.isNotBlank(newContentVersion.NetworkId)) {
                contentDocumentIds.add(newContentVersion.ContentDocumentId);
            }
        }

        if(!contentDocumentIds.isEmpty()) {
            notifySupplierHubOwnerFuture(contentDocumentIds);
        }
    }

    /**
     * @description: ConnectApi.ConnectApiException: EntityLink segment not allowed for external users - use future method to overcome this
     * @param contentDocumentIds
     */
    @Future
    private static void notifySupplierHubOwnerFuture(Set<Id> contentDocumentIds) {
        if(!contentDocumentIds.isEmpty()) {
            Map<Id, Set<Id>> linkedEntityId2ContentDocumentIdsMap = new Map<Id, Set<Id>>();
            //for each contentdocumentlink check if it's related to Joint_Business_Plan__c record - only this object gets notifications
            for(ContentDocumentLink contentDocumentLink : [SELECT LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocumentIds]) {
                if(
                    contentDocumentLink.LinkedEntityId.getSobjectType() == Schema.Joint_Business_Plan__c.SObjectType ||
                    contentDocumentLink.LinkedEntityId.getSobjectType() == Schema.Risk__c.SObjectType ||
                    contentDocumentLink.LinkedEntityId.getSobjectType() == Schema.Supplier_Hub__c.SObjectType ||
                    contentDocumentLink.LinkedEntityId.getSobjectType() == Schema.Supplier_KPI__c.SObjectType
                ) {
                    if(linkedEntityId2ContentDocumentIdsMap.containsKey(contentDocumentLink.LinkedEntityId)) {
                        linkedEntityId2ContentDocumentIdsMap.get(contentDocumentLink.LinkedEntityId).add(contentDocumentLink.ContentDocumentId);
                    } else {
                        linkedEntityId2ContentDocumentIdsMap.put(contentDocumentLink.LinkedEntityId, new Set<Id> { contentDocumentLink.ContentDocumentId });
                    }
                }
            }

            if(!linkedEntityId2ContentDocumentIdsMap.isEmpty()) {
                for(Joint_Business_Plan__c jointBusinessPlan : [SELECT Supplier_Hub__c, Supplier_Hub__r.OwnerId FROM Joint_Business_Plan__c WHERE Id IN :linkedEntityId2ContentDocumentIdsMap.keySet() AND Supplier_Hub__c <> NULL]) {
                    String chatterPostMessage = '', usersToMention = '', objectType = '', record = '';
                    //build string helpers to use them in formatting
                    usersToMention = '{' + jointBusinessPlan.Supplier_Hub__r.OwnerId + '}';
                    objectType = jointBusinessPlan.Id.getSobjectType().getDescribe().getLabel();
                    record = '{record:' + jointBusinessPlan.Id + '}';
                    //format chatter message
                    chatterPostMessage = String.format(Label.SRM_New_File_Attached_By_Portal_User, new List<String> { usersToMention, objectType, record });
                    //post to chatter
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), jointBusinessPlan.Supplier_Hub__c, chatterPostMessage);
                }

                for(Risk__c riskRecord : [SELECT Supplier__c, Supplier__r.OwnerId FROM Risk__c WHERE Id IN :linkedEntityId2ContentDocumentIdsMap.keySet() AND Supplier__c <> NULL]) {
                    String chatterPostMessage = '', usersToMention = '', objectType = '', record = '';
                    //build string helpers to use them in formatting
                    usersToMention = '{' + riskRecord.Supplier__r.OwnerId + '}';
                    objectType = riskRecord.Id.getSobjectType().getDescribe().getLabel();
                    record = '{record:' + riskRecord.Id + '}';
                    //format chatter message
                    chatterPostMessage = String.format(Label.SRM_New_File_Attached_By_Portal_User, new List<String> { usersToMention, objectType, record });
                    //post to chatter
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), riskRecord.Supplier__c, chatterPostMessage);
                }

                for(Supplier_Hub__c supplierHub : [SELECT Supplier_Name__c, OwnerId FROM Supplier_Hub__c WHERE Id IN :linkedEntityId2ContentDocumentIdsMap.keySet()]) {
                    String chatterPostMessage = '', usersToMention = '', files = ' ';
                    //build string helpers to use them in formatting
                    usersToMention = '{' + supplierHub.OwnerId + '}';
                    for(Id contentDocumentId : linkedEntityId2ContentDocumentIdsMap.get(supplierHub.Id)) {
                        files += '{record:' + contentDocumentId + '}, ';
                    }
                    files = files.removeEndIgnoreCase(', ');
                    //format chatter message
                    chatterPostMessage = String.format(Label.SRM_Supplier_Uploaded_Forecast_Volume, new List<String> { usersToMention, supplierHub.Supplier_Name__c, files});
                    //post to chatter
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), supplierHub.Id, chatterPostMessage);
                }

                for(Supplier_KPI__c supplierKPI : [SELECT Supplier_Hub__c, Supplier_Hub__r.Supplier_Name__c, Supplier_Hub__r.OwnerId FROM Supplier_KPI__c WHERE Id IN :linkedEntityId2ContentDocumentIdsMap.keySet() AND Supplier_Hub__c <> NULL]) {
                    String chatterPostMessage = '', usersToMention = '', files = ' ';
                    //build string helpers to use them in formatting
                    usersToMention = '{' + supplierKPI.Supplier_Hub__r.OwnerId + '}';
                    files += '{record: ' + supplierKPI.Id + '} - ';
                    for(Id contentDocumentId : linkedEntityId2ContentDocumentIdsMap.get(supplierKPI.Id)) {
                        files += '{record:' + contentDocumentId + '}, ';
                    }
                    files = files.removeEndIgnoreCase(', ');
                    //format chatter message
                    chatterPostMessage = String.format(Label.SRM_Supplier_Uploaded_Forecast_Accuracy, new List<String> { usersToMention, supplierKPI.Supplier_Hub__r.Supplier_Name__c, files});
                    //post to chatter
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), supplierKPI.Supplier_Hub__c, chatterPostMessage);
                }
            }
        }
    }

}