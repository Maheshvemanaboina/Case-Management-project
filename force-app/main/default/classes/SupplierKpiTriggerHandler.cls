/* *******************************************************************************************************
 * Name               : SupplierKpiTriggerHandler                                                        *
 * Description        : SRM - Trigger handler for Supplier KPI object                                          *
 * Created Date       : 14-Aug-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       14-Aug-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
public without sharing class SupplierKpiTriggerHandler extends SRM_TriggerHandler {

    public override void afterInsert() {
        Map<Id, Supplier_KPI__c> newSupplierKpiMap = (Map<Id, Supplier_KPI__c>)Trigger.newMap;

        postToChatterWithMentions(newSupplierKpiMap);
    }

    /**
     * @description: when portal user created a supplier kpi record, create a chatter message to a supplier hub owner and supplier team member of roles 'buyer'
     * @param newSupplierKpiMap
     */
    private void postToChatterWithMentions(Map<Id, Supplier_KPI__c> newSupplierKpiMap) {
        Set<Id> supplierKpiIds = new Set<Id>();
        Set<Id> supplierHubIds = new Set<Id>();

        for(Supplier_KPI__c supplierKPI : newSupplierKpiMap.values()) {
            if(String.isNotBlank(supplierKPI.Supplier_Hub__c) && supplierKPI.Source__c == ConstUtils.SUPPLIER_KPI_SOURCE_SUPPLIER) {
                supplierKpiIds.add(supplierKPI.Id);
                supplierHubIds.add(supplierKPI.Supplier_Hub__c);
            }
        }

        if(!supplierKpiIds.isEmpty() && !supplierHubIds.isEmpty()) {
            postFeedItems(supplierKpiIds, supplierHubIds);
        }


    }

    /**
     * @description: post feed items with mentions for supplier hub owner and team members with buyer roles
     * @param supplierKpiIds
     * @param supplierHubIds
     */
    @Future
    public static void postFeedItems(Set<Id> supplierKpiIds, Set<Id> supplierHubIds) {
        if(!supplierKPIIds.isEmpty() && !supplierHubIds.isEmpty()) {
            //find team members with Role__c == 'Buyer' and create helper map
            Map<Id, List<Supplier_Team__c>> supplierId2SupplierTeamsMap = new Map<Id, List<Supplier_Team__c>>();
            for(Supplier_Team__c supplierTeam : [SELECT Supplier_Hub__c, User__c FROM Supplier_Team__c WHERE Supplier_Hub__c IN :supplierHubIds AND Role__c = :ConstUtils.SUPPLIER_TEAM_ROLE_BUYER AND Type__c = :ConstUtils.SUPPLIER_TEAM_TYPE_INTERNAL]) {
                if(supplierId2SupplierTeamsMap.containsKey(supplierTeam.Supplier_Hub__c)) {
                    supplierId2SupplierTeamsMap.get(supplierTeam.Supplier_Hub__c).add(supplierTeam);
                } else {
                    supplierId2SupplierTeamsMap.put(supplierTeam.Supplier_Hub__c, new List<Supplier_Team__c> { supplierTeam });
                }
            }

            for(Supplier_KPI__c supplierKPI : [SELECT Id, Name, Supplier_Hub__c, Supplier_Hub__r.OwnerId, CreatedBy.Name FROM Supplier_KPI__c WHERE Id IN :supplierKpiIds]) {
                Set<Id> alreadyMentionedUserIds = new Set<Id>();
                //iterate through all buyers and mention them
                String chatterPostMessage = '';
                if(supplierId2SupplierTeamsMap.containsKey(supplierKPI.Supplier_Hub__c)) {
                    for (Supplier_Team__c supplierTeam : supplierId2SupplierTeamsMap.get(supplierKPI.Supplier_Hub__c)) {
                        if(!alreadyMentionedUserIds.contains(supplierTeam.User__c)) {
                            chatterPostMessage += '{' + supplierTeam.User__c + '}, ';
                            alreadyMentionedUserIds.add(supplierTeam.User__c);
                        }
                    }
                }
                //mention also supplier hub owner and add new line
                if(!alreadyMentionedUserIds.contains(supplierKPI.Supplier_Hub__r.OwnerId)) {
                    chatterPostMessage += '{' + supplierKPI.Supplier_Hub__r.OwnerId + '}';
                    alreadyMentionedUserIds.add(supplierKPI.Supplier_Hub__r.OwnerId);
                }
                //add new line
                chatterPostMessage += '\n';
                //append from a new line message to a supplier hub owner
                chatterPostMessage += String.format(Label.SRM_Supplier_uploaded_new_data_KPI, new List<String> { supplierKPI.CreatedBy.Name, '{record:' + supplierKPI.Id + '}' });
                //post to chatter
                ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), supplierKPI.Supplier_Hub__c, chatterPostMessage);
            }
        }
    }


}