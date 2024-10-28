/******************************
* Written By : Mahendra
* Purpose : To update the business segment of custom account records that are related to the partner roles when
			the business segment of related sales area (of partner role) gets updated
* ****************************/
public class UpdateAccountTeamsBusinessSegment {
    /**    
        * @description  To update account teams business segment when the sales areas' business segment is updated
        * @param        newSalesAreaMap DESCRIPTION: Accepts the trigger.newMap of Sales_Area__c
        * @param        oldSalesAreaMap DESCRIPTION: Accepts the trigger.oldMap of Sales_Area__c
    */  
    public static void updateAccTeamsBusinessSegmentOfRelatedPartnerRoles(Map<Id, Sales_Area__c> newSalesAreaMap, Map<Id, Sales_Area__c> oldSalesAreaMap){
        Set<Id> updatedSalesAreaSet = new Set<Id>();
        List<String> sapRoles = new List<String> {Constants.ACCOUNT_TEAM_ROLE_SALES_MANAGER,Constants.ACCOUNT_TEAM_ROLE_SALES_ASSISTANT,Constants.ACCOUNT_TEAM_ROLE_PERSON_RESPONSIBLE};
            List<String> sfRoles = new List<String> {Constants.ACCOUNT_TEAM_ROLE_SALES_MANAGER,Constants.ACCOUNT_TEAM_ROLE_CMO,Constants.ACCOUNT_TEAM_ROLE_OFO};
                
                for(Sales_Area__c salesArea : newSalesAreaMap.values()){
                    if(salesArea.Business_Segment__c != oldSalesAreaMap.get(salesArea.Id).Business_Segment__c){
                        updatedSalesAreaSet.add(salesArea.Id);
                    }
                }
        
        if(!updatedSalesAreaSet.isEmpty()){
            Map<String, String> keyFieldsBusinessSegmentMap = new Map<String, String>();
            Map<String, String> partnerRolesBusinessSegmentMap = new Map<String, String>();
            Set<Id> partnerRoleSourceAccountIdsSet = new Set<Id>();
            Set<Id> partnerRoleUsersSet = new Set<Id>();
            Set<String> keyFieldsTempSet = new Set<String>();
            List<Account_Team__c> accountTeamListToUpdate = new List<Account_Team__c>();
            List<DebugLog__c> errorLogs = new List<DebugLog__c>();
            
            for(Partner_Role__c partnerRole : [SELECT Id,SAP_Employee_Id__c,SAP_Employee_Id_Without_Zeros__c,
                                               Relation_Name__c,Source_Account__c,Salesforce_User__c,Sales_Area__c
                                               FROM Partner_Role__c
                                               WHERE Sales_Area__c IN: updatedSalesAreaSet AND
                                               Salesforce_User__c != null AND
                                               Active__c = true AND Relation_Name__c IN: sapRoles])
            {
                partnerRolesBusinessSegmentMap.put(
                    partnerRole.Source_Account__c+'-'+oldSalesAreaMap.get(partnerRole.Sales_Area__c).Business_Segment__c+'-'+(partnerRole.Relation_Name__c == Constants.ACCOUNT_TEAM_ROLE_SALES_ASSISTANT?Constants.ACCOUNT_TEAM_ROLE_CMO:  partnerRole.Relation_Name__c == Constants.ACCOUNT_TEAM_ROLE_PERSON_RESPONSIBLE?Constants.ACCOUNT_TEAM_ROLE_OFO:partnerRole.Relation_Name__c),
                    newSalesAreaMap.get(partnerRole.Sales_Area__c).Business_Segment__c
                );
                partnerRoleSourceAccountIdsSet.add(partnerRole.Source_Account__c);
                partnerRoleUsersSet.add(partnerRole.Salesforce_User__c);
            }
            
            Set<String> primarySMCMOOFOSet = CreateAccountTeamMember.getPrimarySMCMOOFOFromExistingAccTeams(partnerRoleSourceAccountIdsSet);
            
            for(Account_Team__c act : [SELECT Id, Source_Account__c, Business_Segment__c, Team_Role__c,
                                       Team_Member__c
                                       FROM Account_Team__c
                                       WHERE Source_Account__c IN: partnerRoleSourceAccountIdsSet AND
                                       Team_Role__c IN: sfRoles AND Team_Member__c IN: partnerRoleUsersSet])
            {
                if(partnerRolesBusinessSegmentMap.containsKey(act.Source_Account__c+'-'+act.Business_Segment__c+'-'+act.Team_Role__c)){
                    act.Business_Segment__c = partnerRolesBusinessSegmentMap.get(act.Source_Account__c+'-'+act.Business_Segment__c+'-'+act.Team_Role__c);
                    if(primarySMCMOOFOSet.contains(act.Source_Account__c+'-'+act.Business_Segment__c+'-'+act.Team_Role__c)){
                        act.Primary__c = false;
                    }
                    accountTeamListToUpdate.add(act);
                }
            }

            if(!accountTeamListToUpdate.isEmpty()){
                DebugLogUtility.DebugLogWrapper debugLogWrapObj = new DebugLogUtility.DebugLogWrapper(
                    'Account Team',//Object Label
                    'Account_Team__c',//Object ApiName
                    'Apex Class',//Process Type
                    'UpdateAccountTeamsBusinessSegment',//Class Name
                    'updateAccTeamsBusinessSegmentOfRelatedPartnerRoles',//Method Name
                    'Error'//Severity
                );
                DebugLogUtility.dynamicUpdate(accountTeamListToUpdate, debugLogWrapObj, errorLogs);
                
                if(!errorLogs.isEmpty()){
                    insert errorLogs;
                }
            }
        }
    }
}