/**      
* @description          To recalculate the account teams when the account owner is updated
*/
public without sharing class AddAccountOwnerToAccountTeamHelper {
    
    /**  
        * @description  To remove previous account owner from account teams and add new account owner
        * @param        updatedAccountIdsSet			DESCRIPTION: Set of Accountids for which the account owner is updated
        * @param		oldAccountMap					DESCRIPTION: Map(old version) of account records that are updated
        * @param		newAccountMap					DESCRIPTION: Map(new version) of account records that are updated
    */
    public static void recalculateAccountTeamsOnAccountOwnerUpdate(Set<Id> updatedAccountIdsSet, Map<Id, Account> oldAccountMap, Map<Id, Account> newAccountMap){
        List<Account_Team__c> accountTeamsToBeCreated = new List<Account_Team__c>();//Store account teams to be created
        List<DebugLog__c> debugLogs = new List<DebugLog__c>();//Store debug log records to be created
        List<Account_Team__c> accTeamsToBeDeleted = new List<Account_Team__c>();//Store account teams to be deleted
        Set<String> previousOwnerDefaultAccTeamSet = new Set<String>();//Store if the previous account owner is present as the default member in the account teams
        
        for(Account_Team__c accTeam : [SELECT Business_Segment__c, Is_Default_Account_Team_Member__c, Primary__c,
                                       Team_Role__c, Team_Member__c, Source_Account__c FROM Account_Team__c
                                       WHERE Team_Role__c =: Constants.ACCOUNT_TEAM_ROLE_SALES_MANAGER AND
                                       Source_Account__c IN: updatedAccountIdsSet AND
                                       Is_Default_Account_Team_Member__c = true AND
                                       Team_Member__c != null ORDER BY Source_Account__c])
        {
            if(
                accTeam.Team_Member__c == oldAccountMap.get(accTeam.Source_Account__c).OwnerId &&
                accTeam.Is_Default_Account_Team_Member__c && accTeam.Business_Segment__c == null
            )
            {
                accTeamsToBeDeleted.add(accTeam);
                accountTeamsToBeCreated.add(createAccountTeamMember(accTeam.Source_Account__c, newAccountMap.get(accTeam.Source_Account__c).OwnerId));
                previousOwnerDefaultAccTeamSet.add(accTeam.Source_Account__c+'-'+accTeam.Team_Member__c);
            }else if(
                accTeam.Team_Member__c == oldAccountMap.get(accTeam.Source_Account__c).OwnerId &&
                accTeam.Is_Default_Account_Team_Member__c && accTeam.Business_Segment__c != null
            ){
                accountTeamsToBeCreated.add(createAccountTeamMember(accTeam.Source_Account__c, newAccountMap.get(accTeam.Source_Account__c).OwnerId));
                previousOwnerDefaultAccTeamSet.add(accTeam.Source_Account__c+'-'+accTeam.Team_Member__c);
            }
        }
        
        for(Id accId : updatedAccountIdsSet){
            if(!previousOwnerDefaultAccTeamSet.contains(accId+'-'+oldAccountMap.get(accId).OwnerId)){
                accountTeamsToBeCreated.add(createAccountTeamMember(accId, newAccountMap.get(accId).OwnerId));
            }
        }
        
            deleteTeamMemberRecord(accTeamsToBeDeleted, debugLogs, 'recalculateAccountTeamsOnAccountOwnerUpdate');
        
            insertTeamMemberRecord(accountTeamsToBeCreated, debugLogs, 'recalculateAccountTeamsOnAccountOwnerUpdate');
    }
    
    /**  
        * @description  To Instantiate the new Accoun team record that needs to be inserted
        * @param        accountId				DESCRIPTION: Account record id
        * @param        accountOwnerId			DESCRIPTION: Account record owner id
        * @return       Account_Team__c			DESCRIPTION: Instantiates the account team record by populating the values and returns the same
    */
    public static Account_Team__c createAccountTeamMember(Id accountId, Id accountOwnerId){
        Account_Team__c accountTeamMember 		= new Account_Team__c(
            Account_Access__c					= 'Edit',
            Case_Access__c						= 'Edit',
            Contact_Access__c					= 'Edit',
            Opportunity_Access__c				= 'Edit',
            Is_Default_Account_Team_Member__c	= true,
            Primary__c							= true,
            Source_Account__c					= accountId,
            Team_Member__c						= accountOwnerId,
            Team_Role__c						= 'Sales Manager'
        );
        return accountTeamMember;
    }
    
    /**
        * @description  To insert the new account team member record
        * @param        toInsert
        * @param        errorLogs
        * @param		methodName
    */ 
    public static void insertTeamMemberRecord(List<Account_Team__c> toInsert,list<DebugLog__c> errorLogs, String methodName){
        if(toInsert.size() > 0) {
			Database.SaveResult[] srList = Database.insert(toInsert, false);            
            for(Integer i=0;i<srList.size();i++){
                if(!srList[i].isSuccess()){  
                    for(Database.Error err : srList[i].getErrors()) {
						DebugLog__c errs = AccountTeamHelper.logError(string.valueof(toInsert[i]),methodName,err.getStatusCode()+': '+err.getMessage(),'Occured when inserting account team member');
                        errorLogs.add(errs);
                    }
                }    
            } 
        }    
    }
    
    /**
        * @description  To delete the account team member record
        * @param        toDelete
        * @param        errorLogs
        * @param		methodName
    */
    public static void deleteTeamMemberRecord(List<Account_Team__c> toDelete,list<DebugLog__c> errorLogs, String methodName){
        if(toDelete.size() > 0) {
			Database.DeleteResult[] srList = Database.delete(toDelete, false);            
            for(Integer i=0;i<srList.size();i++){
                if(!srList[i].isSuccess()){  
                    for(Database.Error err : srList[i].getErrors()) {
						DebugLog__c errs = AccountTeamHelper.logError(string.valueof(toDelete[i]),methodName,err.getStatusCode()+': '+err.getMessage(),'Occured when deleting account team member');
                        errorLogs.add(errs);
                    }
                }  
            }
        }    
    }
}