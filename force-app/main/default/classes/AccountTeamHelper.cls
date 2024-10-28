/**  
* @description  To perform validations before dml operation and to execute dml for 
*/     

public without sharing class AccountTeamHelper {
    public static Map<String,Integer> hierarchyCheck = new Map<String,Integer>{'Sales Manager' =>3 ,'CMO' =>2 ,'OFO' =>1};
    public static List<String> roles = new List<String> {Constants.ACCOUNT_TEAM_ROLE_SALES_MANAGER,Constants.ACCOUNT_TEAM_ROLE_CMO,Constants.ACCOUNT_TEAM_ROLE_OFO};
        
/**  
* @description  To return map of custom accountteammember records with accountid as key as accountteammember as values
* @param        customAccountTeams
* @return       map of accountID and related account team member records
*/      
    public static Map<Id,List<Account_Team__c>>  getcustomAccountTeamMap(List<Account_Team__c> customAccountTeams){
           Map<Id,List<Account_Team__c>> catRecords = new  Map<Id,List<Account_Team__c>>();
           Map<Id,List<Account_Team__c>> finalrecords = new Map<Id,List<Account_Team__c>>();
           for(Account_Team__c cat : customAccountTeams){
            if( !String.isBlank(cat.Source_Account__c) && !String.isBlank(cat.Team_Role__c) && !String.isBlank(cat.Team_Member__c)){
                if(catRecords.containskey(cat.Source_Account__c)){
                    catRecords.get(cat.Source_Account__c).add(cat);
                }else{
                    catRecords.put(Id.valueOf(cat.Source_Account__c),new List<Account_Team__c>{cat});
                }               
            }            
        }
        fliterDuplicates(catRecords,finalrecords);
        return finalrecords;
		
    }
    
/**  
* @description  To add only highest hierarchy role team members, if a team member exist with mutiple roles
* @param        catRecords 
* @param        finalrecords
*/  
    public static void fliterDuplicates(Map<Id,List<Account_Team__c>> catRecords,Map<Id,List<Account_Team__c>> finalrecords){
            Map<Id,List<Account_Team__c>> records = catRecords.clone();
            for(Id accId : records.keySet()){
                Map<ID,Integer> maprec = new Map<ID,Integer>();
                for(Account_Team__c at : records.get(accId)){
                    if(maprec.containskey(at.Team_Member__c)){
                            if(maprec.get(at.Team_Member__c) > hierarchyCheck.get(at.Team_Role__c)){
                                 system.debug('removed');
                            }else{
                                finalrecords.get(at.Source_Account__c).add(at);
                                maprec.put(at.Team_Member__c,hierarchyCheck.get(at.Team_Role__c));    
                            }                        

                    }else{
                         if(finalrecords.containskey(at.Source_Account__c)){
                            finalrecords.get(at.Source_Account__c).add(at);
                         }else{
                             finalrecords.put(Id.valueOf(at.Source_Account__c),new List<Account_Team__c>{at});
                         }                         
                         maprec.put(at.Team_Member__c,hierarchyCheck.get(at.Team_Role__c));                         
                    }
                }
            }          
           
    }
    
/**  
* @description  if custom accountteammember record get updated, update the same standard accountteammember
* @param        oldcat 
* @param        newcat
* @param        catRecords
*/    
     public static void updateCheck(Map<Id,Account_Team__c> oldcat,Map<Id,Account_Team__c> newcat,Map<Id,List<Account_Team__c>> catRecords){
        for(Account_Team__c accTeam : newcat.values()){
            Account_Team__c oldAct = oldcat.get(accTeam.Id);
            boolean userChange = accTeam.Team_Member__c != oldAct.Team_Member__c;
            boolean changeInOtherTMRecords = !roles.contains(accTeam.Team_Role__c) && !roles.contains(oldAct.Team_Role__c) && !userChange;
            boolean changeInStdTMRecords = roles.contains(accTeam.Team_Role__c) && !userChange && (accTeam.Account_Access__c != oldAct.Account_Access__c || accTeam.Contact_Access__c != oldAct.Contact_Access__c || accTeam.Opportunity_Access__c != oldAct.Opportunity_Access__c || accTeam.Case_Access__c != oldAct.Case_Access__c );
            if(changeInOtherTMRecords || changeInStdTMRecords){
                if(catRecords.containskey(accTeam.Source_Account__c)){
                    catRecords.get(accTeam.Source_Account__c).add(oldAct);
                }else{
                    catRecords.put(Id.valueOf(accTeam.Source_Account__c),new List<Account_Team__c>{oldAct});
                }      
            }
      	}
    }
    
/**
* @description  To insert the new account team member record
* @param        toInsert
* @param        errorLogs
*/ 
    public static void insertTeamMemberRecord(List<AccountTeamMember> toInsert,list<DebugLog__c> errorLogs){
        if(toInsert.size() > 0) {
			Database.SaveResult[] srList = Database.insert(toInsert, false);            
            for(Integer i=0;i<srList.size();i++){
                if(!srList[i].isSuccess()){  
                    for(Database.Error err : srList[i].getErrors()) {
						DebugLog__c errs = logError(string.valueof(toInsert[i]),'addAccountTeamMember',err.getStatusCode()+': '+err.getMessage(),'Occured when inserting account team member');
                        errorLogs.add(errs);
                    }
                }    
            } 
        }    
    }
    
    
/**
* @description  To update the existing team member record
* @param        toUpdate
* @param        errorLogs
*/ 
    public static void updateTeamMemberRecord(List<AccountTeamMember> toUpdate,list<DebugLog__c> errorLogs){
           if(toUpdate.size() > 0) {
                Database.SaveResult[] srList = Database.update(toUpdate, false);            
                for(Integer i=0;i<srList.size();i++){
                    if(!srList[i].isSuccess()){  
                        for(Database.Error err : srList[i].getErrors()) {
                            DebugLog__c errs = logError(string.valueof(toUpdate[i]),'updateAccountTeamMember',err.getStatusCode()+': '+err.getMessage(),'Occured when updating account team member');
                            errorLogs.add(errs);
                        }
                    } 
                } 
           }    
    }
    
/**
* @description  To delete the existing team member record
* @param        toDelete
* @param        errorLogs
*/ 
    public static void deleteTeamMemberRecord(List<AccountTeamMember> toDelete,list<DebugLog__c> errorLogs){
        if(toDelete.size() > 0) {
			Database.DeleteResult[] srList = Database.delete(toDelete, false);            
            for(Integer i=0;i<srList.size();i++){
                if(!srList[i].isSuccess()){  
                    for(Database.Error err : srList[i].getErrors()) {
						DebugLog__c errs = logError(string.valueof(toDelete[i]),'deleteTeamMember',err.getStatusCode()+': '+err.getMessage(),'Occured when deleting account team member');
                        errorLogs.add(errs);
                    }
                }  
            }
        }
    }
    
    /**
        * @description  To delete the existing team member record
        * @param        toDelete
        * @param        errorLogs
    */ 
    public static void updateCustomAccountTeamMemberRecord(List<Account_Team__c> toUpdate,list<DebugLog__c> errorLogs){
        if(toUpdate.size() > 0) {
            Database.SaveResult[] srList = Database.update(toUpdate, false);            
            for(Integer i=0;i<srList.size();i++){
                if(!srList[i].isSuccess()){
                    for(Database.Error err : srList[i].getErrors()) {
                        DebugLog__c errs = logError(string.valueof(toUpdate[i]),'recalculatePrimarySMOnDeletion',err.getStatusCode()+': '+err.getMessage(),'Occured when updating account team member');
                        errorLogs.add(errs);
                    }
                } 
            }
        }
    }
    


/**
* @description  To add  errors in errorlog custom object
* @param        record
* @param        opertationName
* @param        errorMessage
* @param        comment
* @return       DebugLog__c
*/ 
    public static DebugLog__c logError(string record,string opertationName,string errorMessage,string comment){
        DebugLog__c errorLog = new DebugLog__c(); 
        errorLog.Object__c = 'AccountTeamMember';
        errorLog.Record__c = record;
        errorLog.Errored_Process_Type__c = 'Apex Class';
        errorLog.Errored_Process_Name__c = 'AccountTeam';      
        errorLog.Operation_Name__c = opertationName; 
        errorLog.Severity__c = 'Error';
        errorLog.Message__c = errorMessage;
        errorLog.TypeName__c = 'INTERNAL ERROR';
        errorLog.Comments__c = comment;  
        return errorLog;
    }
    
    /*
        * @description  To add deleted AccountTeamMembers in the Standard Account Team object, when the Account owner is updated
        * @param        accountIds DESCRIPTION: Accepts the list of custom account team ids passed from the flow
	*/
    @InvocableMethod(label='Reinsert deleted AccountTeamMembers' description='Recreates the deleted AccountTeamMembers when the Account owner is changed')
    public static void retainAccountTeam(List<Id> accountIds){
            List<Account_Team__c> customAccountTeamRecords = [SELECT Id, Business_Segment__c, Source_Account__c,
                                                              Team_Member__c, Team_Role__c, Account_Access__c, Case_Access__c,
                                                              Contact_Access__c, Opportunity_Access__c
                                                              FROM Account_Team__c WHERE Source_Account__c IN: accountIds];
            if(!customAccountTeamRecords.isEmpty()){
                AccountTeam.addAccountTeamMember(customAccountTeamRecords);
            }
    }
    
    /*
		* @description		To Mark the remaining SM/CMO/OFO (This works only if there are 2 SMs/CMOs/OFOs) in the account teams as primary when the existing primary SM/CMO/OFO is deleted
		* @param			oldAccTeamList DESCRIPTION: Accepts List of Account_Team__c records - records that are being deleted
	*/
    public static void recalculatePrimarySMOnDeletion(List<Account_Team__c> oldAccTeamList){
        try{
            
            Set<Id> accountIdSet = new Set<Id>();//it stores the source accounts ids when the primary SM/CMO/OFO associated to that account is being deleted
            List<Account_Team__c> accountTeamListToDelete = new List<Account_Team__c>();//list of primary SM/CMO/OFO of a specific business segment is being deleted
            List<Account_Team__c> accountTeamsToUpdate = new List<Account_Team__c>();//list of SM/CMO/OFO account team member records to be updated as primary
            list<DebugLog__c> errorLogs = new list<DebugLog__c>();//list of debug log records if there is any error
            
            //Loop through the Primary SM/CMO/OFO that are being deleted and collect the source account ids
            for(Account_Team__c atm : oldAccTeamList){
                if(
                    atm.Primary__c && atm.Business_Segment__c != null && atm.Source_Account__c != null &&
                    roles.contains(atm.Team_Role__c) &&
                    atm.Team_Member__c != null
                ){
                    system.debug('account team to delete');
                    accountIdSet.add(atm.Source_Account__c);
                    accountTeamListToDelete.add(atm);
                }
            }
            
            //check if there is any matching SM/CMO/OFO of the same business segment of which the primary is being deleted and mark it as primary if there is only one match found
            if(!accountTeamListToDelete.isEmpty()){
                Map<String, List<Account_Team__c>> accBusSegTeamRoleCountMap = new Map<String, List<Account_Team__c>>();
                String accBusSegTeamRoleKey;
                for(Account_Team__c existingAccTeam : [SELECT Id, Primary__c, Business_Segment__c, Source_Account__c,
                                                       Team_Role__c, Team_Member__c
                                                       FROM Account_Team__c
                                                       WHERE Id NOT IN: accountTeamListToDelete AND
                                                       Source_Account__c IN: accountIdSet AND
                                                       Team_Role__c IN: roles AND
                                                       Business_Segment__c != null AND
                                                       Team_Member__c != null])
                {
                    accBusSegTeamRoleKey = existingAccTeam.Source_Account__c+'-'+existingAccTeam.Team_Role__c+'-'+existingAccTeam.Business_Segment__c;
                    if(!accBusSegTeamRoleCountMap.containsKey(accBusSegTeamRoleKey)){
                        system.debug('existing account team');
                        accBusSegTeamRoleCountMap.put(accBusSegTeamRoleKey, new List<Account_Team__c>{existingAccTeam});
                    }else{
                        accBusSegTeamRoleCountMap.get(accBusSegTeamRoleKey).add(existingAccTeam);
                    }
                }
                
                if(!accBusSegTeamRoleCountMap.isEmpty()){
                    String accTeamKey;
                    for(Account_Team__c accTeam : accountTeamListToDelete){
                        accTeamKey = accTeam.Source_Account__c+'-'+accTeam.Team_Role__c+'-'+accTeam.Business_Segment__c;
                        system.debug('account team list to delete for loop');
                        if(accBusSegTeamRoleCountMap.containsKey(accTeamKey) && accBusSegTeamRoleCountMap.get(accTeamKey) != null && accBusSegTeamRoleCountMap.get(accTeamKey).size() == 1){
                            system.debug('update account team');
                            accBusSegTeamRoleCountMap.get(accTeamKey)[0].Primary__c = true;
                            accountTeamsToUpdate.add(accBusSegTeamRoleCountMap.get(accTeamKey)[0]);
                        }
                    }
                }
                
            }
            
            //update the custom account team member records and log the errors if any
            if(!accountTeamsToUpdate.isEmpty()){
                updateCustomAccountTeamMemberRecord(accountTeamsToUpdate, errorLogs);
            }
            
            if(!errorLogs.isEmpty()){
                insert errorLogs;
            }
        }catch(exception e){
            system.debug('line number '+e.getLineNumber()+'error message '+e.getMessage()+'error message'+e.getStackTraceString());
        }
    }
    
    /*
		* @description		To recalculate the end customer owner when the primary SM is deleted from the account team
		* @param			oldAccTeamList DESCRIPTION: Accepts List of Account_Team__c records - records that are being deleted
	*/
    public static void recalculateEndCustomerOwner(List<Account_Team__c> accountTeamList){
        Id endCustomerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_End_Customer').getRecordTypeId();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> teamMemberIdsSet = new Set<Id>();
        Set<String> businessSegmentSet = new Set<String>();
        List<Account> endCustomersList = new List<Account>();
        for(Account_Team__c act : accountTeamList){
            if(act.Primary__c && act.Team_Role__c == Constants.ACCOUNT_TEAM_ROLE_SALES_MANAGER &&
               act.Business_Segment__c != null && act.Source_Account__c != null && act.Team_Member__c != null)
            {
                accountIdSet.add(act.Source_Account__c);
                teamMemberIdsSet.add(act.Team_Member__c);
                businessSegmentSet.add(act.Business_Segment__c);
            }
        }
        
        if(!accountIdSet.isEmpty() && !teamMemberIdsSet.isEmpty() && !businessSegmentSet.isEmpty()){
            endCustomersList = [SELECT Id, Business_Segment__c, RecordTypeId, Distributor_Location__c, OwnerId
                                FROM Account WHERE OwnerId IN: teamMemberIdsSet AND Distributor_Location__c IN: accountIdSet AND
                                Business_Segment__c IN: businessSegmentSet AND RecordTypeId =: endCustomerRecordTypeId];
        }
        
        if(!endCustomersList.isEmpty()){
            UpdateAccountOwner.updateOwner(endCustomersList);
        }
    }
}