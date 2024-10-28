/**      
* @description          To add account owner in custom account team member object whenever a new account is created or account owner is updated.
*/
public without sharing class AddAccountOwnerToAccountTeam extends TriggerHandler {
    
    /**  
        * @description  To add account owner in the custom account team object when a new prospect or customer location account is created
        * @param        accountList			DESCRIPTION: List of new Account records that are being inserted
    */ 
    public static void addAccountOwnerInAccountTeams(List<Account> accountList){
        
        List<Account_Team__c> accountTeamsToCreate = new List<Account_Team__c>();//Store account team member records to be created
        List<DebugLog__c> debugLogs = new List<DebugLog__c>();//store debug log records to be created
        
        //check if the logged in user is not distributor community profile user and the account being inserted is
        //customer location or prospect account and add account owner in the account teams only if it meets these conditions
        if(isNonDistiCommunityProfileUser()){
            for(Account acc : accountList){
                if(isCustomerLocationOrProspectAccount(acc.RecordTypeId)){
                    accountTeamsToCreate.add(AddAccountOwnerToAccountTeamHelper.createAccountTeamMember(acc.Id, acc.OwnerId));
                }
            }
            
            //check if the list is not empty and create the account team records
            if(!accountTeamsToCreate.isEmpty()){
                AddAccountOwnerToAccountTeamHelper.insertTeamMemberRecord(accountTeamsToCreate, debugLogs, 'addAccountOwnerInAccountTeams');
            }
        }
    }
    
    /**  
        * @description  To remove previous account owner in the custom account team object
        * and add new account owner to the account team only when the account owner is updated
        * @param        newAccountMap			DESCRIPTION: Map(new version) of account records that are updated
        * @param        oldAccountMap			DESCRIPTION: Map(old version) of account records that are updated
    */
    public static void removePreviousOwnerAndAddNewOwnerInAccTeams(Map<Id, Account> newAccountMap, Map<Id, Account> oldAccountMap){
        
        //get the account ids for which the account owner is updated
        Set<Id> accountOwnerUpdatedAccountIdsSet = getAccountOwnerUpdatedAccountIds(newAccountMap, oldAccountMap);
        
        //run the entire process only if the account owner is updated at least for one account record
        if(!accountOwnerUpdatedAccountIdsSet.isEmpty()){
            AddAccountOwnerToAccountTeamHelper.recalculateAccountTeamsOnAccountOwnerUpdate(
                accountOwnerUpdatedAccountIdsSet, oldAccountMap, newAccountMap
            );
        }
    }
    
    /**  
        * @description  To get the set of accountids for which the account owner is updated
        * @param        newAccountMap			DESCRIPTION: Map(new version) of account records that are updated
        * @param        oldAccountMap			DESCRIPTION: Map(old version) of account records that are updated
        * @return       Set<Id>					DESCRIPTION: returns the set of accountids for which the account owner is updated
    */
    private static Set<Id> getAccountOwnerUpdatedAccountIds(Map<Id, Account> newAccountMap, Map<Id, Account> oldAccountMap){
        Set<Id> updatedAccountIdsSet = new Set<Id>();
        if(isNonDistiCommunityProfileUser()){
            for(Account acc : newAccountMap.values()){
                if(isCustomerLocationOrProspectAccount(acc.RecordTypeId) && acc.OwnerId != oldAccountMap.get(acc.Id).OwnerId){
                    updatedAccountIdsSet.add(acc.Id);
                }
            }
            return updatedAccountIdsSet;
        }
        return updatedAccountIdsSet;
    }    
    
    /**  
        * @description  To check if the logged in user is disti community profile user or not
        * @return       Boolean			DESCRIPTION: returns true if the logged in user has not assigned with disti community user profile
    */
    private static Boolean isNonDistiCommunityProfileUser(){
        Map<Id, Profile> fciDistiCommunityProfiles = new Map<Id, Profile>(
            [SELECT Id FROM Profile 
             WHERE Name IN ('FCI Distributor Community User', 'FCI Distributor Community Restricted User')]
        );
        return !fciDistiCommunityProfiles.isEmpty() && !fciDistiCommunityProfiles.containsKey(UserInfo.getProfileId());
    }
    
    /**  
        * @description  To check if the record type of the account being inserted/updated is Customer Location or Prospect
        * @param		accRecordTypeId	DESCRIPTION: accepts the account record's record type id
        * @return       Boolean			DESCRIPTION: returns true if the record type of the account being inserted/updated is customer location or prospect
    */
    private static Boolean isCustomerLocationOrProspectAccount(Id accRecordTypeId){
        Set<Id> accRecordTypeIds = new Set<Id>{
            Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Customer_Location').getRecordTypeId(),
            Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Prospect').getRecordTypeId()
        };
        return !accRecordTypeIds.isEmpty() && accRecordTypeIds.contains(accRecordTypeId);
    }
}