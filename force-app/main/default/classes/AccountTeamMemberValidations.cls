/*       
@Name                  AccountTeamMemberValidations
@Author                Sharan Mulimani + Sharan.Mulimani@frieslandcampina.com
@ModifiedBy            Shoba Thummala + shoba.thummala@frieslandcampina.com
@Version               1.0
@CreatedDate           -----
@UsedBy                AccountTeamMemberTriggerHandler
@Description           Class to perform validations on insertion and updation of Account_Team__c 
@Changes
UserId           | Author-Email                         | Date                | Comment
================ |======================================|=====================|=========
 Shoba Thummala  | shoba.thummala@frieslandcampina.com   | February 11, 2021   | To ensure that only one primary account team member is inserted or updated per one business segment
 Rekha           | rekha.harshit@frieslandcampina.com    | October 19,2021     | To stop fetching role from user & To have common method to perform validation
 Shweta          | shweta.basavaraj@frieslandcampina.com | August 02,2022      | To  ensure that Account team member added from Partener role cannot be deleted
 Shweta          | shweta.basavaraj@frieslandcampina.com | August 04,2022      | To ensure that users are not allowed to add a member more than once
 Joao Almeida    | joao.almeida@frieslandcampina.com     | October 13,2023      | To ensure that users are not allowed to add a member more than once and multiple primary members for same role and business segment
*/
public  without sharing class AccountTeamMemberValidations{
      
    @TestVisible
    private static String ACC_TEAM_PRIMARY_VALIDATION_ERROR='Team Member with same Role and Business segment cannot be Primary';
    @TestVisible
    private static String ACC_TEAM_UNIQUE_VALIDATION_ERROR='Same Team Member with same Role and Business segment cannot be added';
    @TestVisible
    private static String ACC_TEAM_CANNOT_DELETE_MEMBER='You are not allowed to delete the member';

    /**
     * NEWC-2463 - validate duplicated account team on insert and on update
     * 
     * @param  beforeInsert  if it's a before insert or not
     * @param  newAccTeamList  the Trigger.New list
     * @param  oldAccTeamMap  the trigger.oldMap map
     */
    public static void validateMemberExistanceTwice(Boolean beforeInsert, List<Account_Team__c> newAccTeamList, map<id,Account_Team__c> oldAccTeamMap){
        set<Id> accSourceIDSet = new set<Id>();
        set<Id> updatedAccTeamIdsSet = new set<Id>();
        if (!beforeInsert) {
            updatedAccTeamIdsSet = (new Map<Id,SObject>(newAccTeamList)).keySet();
        }
        Map<Id,Map<String,Account_Team__c>> mapSourceAccToTeamMemberAccTeam = checkDuplicatesOnTriggerNewList(false,newAccTeamList, accSourceIDSet);
        
        if(!accSourceIDSet.isEmpty()){
            for(Account_Team__c act : [SELECT Id,Team_Role__c,Source_Account__c,Team_Member__c,Business_Segment__c 
                                        FROM Account_Team__c WHERE Id NOT IN :updatedAccTeamIdsSet AND Source_Account__c IN : accSourceIDSet WITH SECURITY_ENFORCED]){

                String duplicateCheckKey = act.Team_Member__c + '|' + act.Business_Segment__c + '|' + act.Team_Role__c;
                Map<String,Account_Team__c> currentAccSourceTeamMembersMap = mapSourceAccToTeamMemberAccTeam.get(act.Source_Account__c);
                Account_Team__c insertingDuplicatedAccTeam = currentAccSourceTeamMembersMap.get(duplicateCheckKey);
                if (insertingDuplicatedAccTeam != null) {                                                      
                    insertingDuplicatedAccTeam.addError(ACC_TEAM_UNIQUE_VALIDATION_ERROR);                     
                }                  
       		}
        }
    }

    /**
     * NEWC-2463 - validate duplicated primary account team member for same role and business segment on insert and on update
     * 
     * @param  beforeInsert  if it's a before insert or not
     * @param  newAccTeamList  the Trigger.New list
     * @param  oldAccTeamMap  the trigger.oldMap map
     */
    public static void accountTeamPrimaryValidation(Boolean beforeInsert, List<Account_Team__c> newAccTeamList, map<id,Account_Team__c> oldAccTeamMap){
        Map<Id,List<Account_Team__c>> accAccTeamTriggerMap = new Map<Id,List<Account_Team__c>>();
        Set<Id> accountIds = new Set<Id>();
        Map<Id,Account_Team__c> mapTeamMemberBusiness=New Map<Id,Account_Team__c>();
        set<id> updatedAccTeamIdsSet = new set<id>();
        if (!beforeInsert) {
            for (Account_Team__c accTeam : newAccTeamList) {
                updatedAccTeamIdsSet.add(accTeam.Id);
            }
        }
        Map<Id,Map<String,Account_Team__c>> mapSourceAccToTeamMemberAccTeam = checkDuplicatesOnTriggerNewList(true, newAccTeamList, accountIds);
        
        validatePrimaryMember(accountIds, updatedAccTeamIdsSet,mapSourceAccToTeamMemberAccTeam); 
    }
        
    /* Created By : Rekha on 19-10-2021
        * @Description : This Method performs validation on account team member 
        * Rule : Member with same role and business segment can not be marked as primary
        * @param NAME : accountIdSet,mapTeamMemberBusiness
        * @return TYPE : void 
    */
    public static void validatePrimaryMember(set<Id> accountIdSet, set<id> updatedAccTeamIdsSet, Map<Id,Map<String,Account_Team__c>> mapSourceAccToTeamMemberAccTeam){
        
        if(!accountIdSet.isEmpty()){
            for(Account_Team__c accounttm:[SELECT Id,Source_Account__c,Primary__c,Source_Account__r.Name,Business_Segment__c,Team_Role__c 
                                            FROM Account_Team__c
                                            WHERE Id NOT IN :updatedAccTeamIdsSet AND Source_Account__c IN: accountIdSet and Primary__c = true WITH SECURITY_ENFORCED order by Source_Account__c]){
                //If any of the Account Team Member is primary and its business Segment and role are same as the new Account Team Member business Segment and role then throw error 
                String duplicateCheckKey = accounttm.Primary__c + '|' + accounttm.Business_Segment__c + '|' + accounttm.Team_Role__c;
                Map<String,Account_Team__c> currentAccSourceTeamMembersMap = mapSourceAccToTeamMemberAccTeam.get(accounttm.Source_Account__c);
                Account_Team__c insertingDuplicatedAccTeam = currentAccSourceTeamMembersMap.get(duplicateCheckKey);
                if (insertingDuplicatedAccTeam != null) {                                                      
                    insertingDuplicatedAccTeam.addError(ACC_TEAM_PRIMARY_VALIDATION_ERROR);                     
                }                                    
            }                                        
        }   
        
    }

    /* Created By : Shweta on 02-08-2022
     * Description : This Method performs validation on account team  
     * Rule : Member available in the Partner Role for the same account cannot be deleted.
     * @param NAME : newAccTeamList
     * @return TYPE : void 
    */
    public static void validateDeleteMember(List<Account_Team__c> oldAccTeamList){
        
        Set<Id> accountIds = new Set<Id>();
        Set<Id> teamMemberId = new Set<Id>();
        List<Partner_Role__c> partnerList = new List<Partner_Role__c>();
        if(oldAccTeamList.size()>0 && !oldAccTeamList.isEmpty()){
        for(Account_Team__c act : oldAccTeamList){
            if(act.Source_Account__c != null && act.Team_Member__c!=null && (act.Team_Role__c == Constants.ACCOUNT_TEAM_ROLE_SALES_MANAGER ||
               act.Team_Role__c == Constants.ACCOUNT_TEAM_ROLE_CMO || act.Team_Role__c == Constants.ACCOUNT_TEAM_ROLE_OFO)){
                accountIds.add(act.Source_Account__c);
                teamMemberId.add(act.Team_Member__c);
            	}
        	}
        }
        
        if(!accountIds.isEmpty() && !teamMemberId.isEmpty()){
         partnerList = [Select Id, Active__c,Salesforce_User__c,Source_Account__c FROM Partner_Role__c Where Salesforce_User__c IN: teamMemberId and Source_Account__c IN: accountIds WITH SECURITY_ENFORCED];
        }
        System.debug('partnerList' + partnerList.size());
        Boolean byPassValidationRule = Test.isRunningTest() ? false : FeatureManagement.checkPermission('By_Pass_ValidationRule');
        
        System.debug('byPassValidationRule: ' + byPassValidationRule);
        for(Account_Team__c act : oldAccTeamList){
        	if(partnerList.size()>0 && !byPassValidationRule && (act.Team_Role__c == Constants.ACCOUNT_TEAM_ROLE_SALES_MANAGER ||
               act.Team_Role__c == Constants.ACCOUNT_TEAM_ROLE_CMO || act.Team_Role__c == Constants.ACCOUNT_TEAM_ROLE_OFO)){
           		act.addError(ACC_TEAM_CANNOT_DELETE_MEMBER);
        	}
        }
    }

    /**
     * NEWC-2463 - on a trigger, the newAccTeamList list can have its own duplicated values
     * 
     * @param  checkingPrimary  if true, don't check team member, otherwise it should be unique
     * @param  newAccTeamList  the trigger new list
     * @param  accSourceIDSet  passed by reference; a set with all source account Ids on the trigger new list
     * @return  a map between source account Id and the account team records unique data
     */
    private static Map<Id,Map<String,Account_Team__c>> checkDuplicatesOnTriggerNewList(Boolean checkingPrimary, List<Account_Team__c> newAccTeamList, set<id> accSourceIDSet) { 
        Map<Id,Map<String,Account_Team__c>> mapSourceAccToTeamMemberAccTeam = new Map<Id,Map<String,Account_Team__c>>();
        if(newAccTeamList.size()>0 && !newAccTeamList.isEmpty()){
            for(Account_Team__c act : newAccTeamList){
                String duplicateCheckKey = '';
                if (!checkingPrimary) {
                    duplicateCheckKey = act.Team_Member__c + '|';
                }
                else {
                    duplicateCheckKey = act.Primary__c + '|';
                }
                duplicateCheckKey+=act.Business_Segment__c + '|' + act.Team_Role__c;
                accSourceIDSet.add(act.Source_Account__c);
                Map<String,Account_Team__c> currentTeamMembersMap = mapSourceAccToTeamMemberAccTeam.get(act.Source_Account__c);
                if (currentTeamMembersMap == null) {
                    currentTeamMembersMap = new Map<String,Account_Team__c>();
                    currentTeamMembersMap.put(duplicateCheckKey,act);
                    mapSourceAccToTeamMemberAccTeam.put(act.Source_Account__c, currentTeamMembersMap);
                }
                else {
                    Account_Team__c duplicateDataCheck = currentTeamMembersMap.get(duplicateCheckKey);
                    // it means for the same source account, 1 team member (if unique) or primary with the same business segment and team role is already in pipeline to be inserted
                    if (duplicateDataCheck != null) {
                        act.addError(checkingPrimary ? ACC_TEAM_PRIMARY_VALIDATION_ERROR : ACC_TEAM_UNIQUE_VALIDATION_ERROR);
                    }
                    else {
                        currentTeamMembersMap.put(duplicateCheckKey,act);
                    }
                }
            }
        }
        return mapSourceAccToTeamMemberAccTeam;
    }
}