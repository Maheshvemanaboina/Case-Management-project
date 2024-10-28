/**      
* @description          To rollup account team members from custom to standard account team member object.
*/
public without sharing class AccountTeam {
    public static List<String> roles = new List<String> {Constants.ACCOUNT_TEAM_ROLE_SALES_MANAGER,Constants.ACCOUNT_TEAM_ROLE_CMO,Constants.ACCOUNT_TEAM_ROLE_OFO};
    public static List<AccountTeamMember> toInsert;
    public static List<AccountTeamMember> toUpdate;

/**    
* @description  To rollup account team members from custom to standard account on insert event.
* @param        customAccountTeams DESCRIPTION: Accepts the trigger.new list 
*/  
    
    public static void addAccountTeamMember(List<Account_Team__c> customAccountTeams){
        try{
            list<DebugLog__c> errorLogs = new list<DebugLog__c>();
            Map<Id,List<Account_Team__c>> catRecords =  AccountTeamHelper.getcustomAccountTeamMap(customAccountTeams);        
                       
            
            Map<Id,List<AccountTeamMember>> actRecords = new Map<Id,List<AccountTeamMember>>();
            getAccountTeamMember(actRecords,catRecords.keySet());
            
           
            
            toInsert = new List<AccountTeamMember>();
            toUpdate = new List<AccountTeamMember>();
            
            for(Id accId : catRecords.keySet()){
                for(Account_Team__c at : catRecords.get(accId)){
                    system.debug('final list'+at);
                    AccountTeamMember atm = new AccountTeamMember();                   
                    if(!actRecords.containsKey(at.Source_Account__c)){                   
                        createTeamMember(at,atm);
                        toInsert.add(atm);   
                    }else{
                        AccountTeamMember existingAccountTeamMember = accountTeamMemberAlreadyExist(at,actRecords);
                        if(String.isBlank(existingAccountTeamMember.AccountId)){ 
                             createTeamMember(at,atm);
                             toInsert.add(atm);  
                             
                        }else{
                           compareExistingAccountTeamRecordWithCustomRecord(existingAccountTeamMember, at,atm);
                        }                   
                    }
                       
                }
            }
            AccountTeamHelper.insertTeamMemberRecord(toInsert,errorLogs);           
            AccountTeamHelper.updateTeamMemberRecord(toUpdate,errorLogs);
            if(!errorLogs.isEmpty()){
                insert errorLogs;
            }
        }
        
        catch(exception e){
            system.debug('line number '+e.getLineNumber()+'error message '+e.getMessage()+'error message'+e.getStackTraceString());
        }
        
    }
    
/**     
* @description  To rollup account team members from custom to standard account on update event.
* @param        oldcat DESCRIPTION: Accepts the trigger.old map 
* @param        newcat DESCRIPTION: Accepts the trigger.new map 
*/   
    public static void updateAccountTeamMember(Map<Id,Account_Team__c> oldcat,Map<Id,Account_Team__c> newcat){
        try{  
        List<AccountTeamMember> toUpdate = new List<AccountTeamMember>();
        list<DebugLog__c> errorLogs = new list<DebugLog__c>(); 
        Map<Id,List<Account_Team__c>> catRecords = new Map<Id,List<Account_Team__c>>();
        AccountTeamHelper.updateCheck(oldcat,newcat,catRecords);    	
        system.debug('catRecords ' +catRecords);
        Map<Id,List<AccountTeamMember>> actRecords = new Map<Id,List<AccountTeamMember>>();
        getAccountTeamMember(actRecords,catRecords.keySet());
        system.debug('actRecords ' +actRecords);
        
        for(Id accId : catRecords.keySet()){
            for(Account_Team__c at : catRecords.get(accId)){
                if(actRecords.containsKey(at.Source_Account__c)){                   
                    AccountTeamMember existingAccountTeamMember = accountTeamMemberRoleAlreadyExist(at,actRecords);
                    if(!String.isBlank(existingAccountTeamMember.AccountId)){                           
                         updateTeamMember(existingAccountTeamMember,newcat.get(at.Id));
                       	 toUpdate.add(existingAccountTeamMember);                                
                    }
                }                
            }
        }         
        AccountTeamHelper.updateTeamMemberRecord(toUpdate,errorLogs);
        }catch(exception e){
            system.debug('line number '+e.getLineNumber()+'error message '+e.getMessage()+'error message'+e.getStackTraceString());
        }
        
    }    

    
    
/**     
* @description  To rollup account team members from custom to standard account on delete event.
* @param        customAccountTeams DESCRIPTION: Accepts the trigger.old map 
* @return       TYPE:void 
*/     
    public static void deleteTeamMember(Map<Id,Account_Team__c> customAccountTeams){
        try{
            List<AccountTeamMember> toDelete = new List<AccountTeamMember>();    
            List<DebugLog__c> errorLogs = new List<DebugLog__c>(); 
            set<Id> accIds =new  set<Id>();
            
            for(Account_Team__c accTeam : customAccountTeams.values()){
                accIds.add(accTeam.Source_Account__c);
            }

            Map<Id,List<AccountTeamMember>> actRecords = new Map<Id,List<AccountTeamMember>>();
            getAccountTeamMember(actRecords,accIds);  	
            system.debug('actRecords ' +actRecords);
            
            
            for(Account_Team__c at : customAccountTeams.values()){
                  if(actRecords.containsKey(at.Source_Account__c)){  
                        system.debug('contains record '+actRecords); 
                        AccountTeamMember existingAccountTeamMember = accountTeamMemberRoleAlreadyExist(at,actRecords);
                        system.debug('Match Found '+existingAccountTeamMember); 
                        boolean check = String.isBlank(existingAccountTeamMember.AccountId);
                        if(!check && !toDelete.contains(existingAccountTeamMember)){                      
                            toDelete.add(existingAccountTeamMember);    
                        }      
                   }                    
             }     
        
             AccountTeamHelper.deleteTeamMemberRecord(toDelete,errorLogs);
        }
        catch(exception e){
            system.debug('line number '+e.getLineNumber()+'error message '+e.getMessage()+'error message'+e.getStackTraceString());
        }
        
    }



    
   
/**    
* @description  To instantiate standard accountteammember record with values of custom accountteammember
* @param        at DESCRIPTION: Accepts the standard accountteammember record
* @param        atm DESCRIPTION: Accepts the custom accountteammember record
*/     
    
    public static void createTeamMember(Account_Team__c at, AccountTeamMember atm){
          atm.UserId = at.Team_Member__c;
          atm.TeamMemberRole = at.Team_Role__c;
	      atm.AccountId = at.Source_Account__c;
          atm.Business_Segment__c = at.Business_Segment__c;
          atm.AccountAccessLevel = at.Account_Access__c;
          atm.ContactAccessLevel = at.Contact_Access__c;
          atm.OpportunityAccessLevel = at.Opportunity_Access__c;
          atm.CaseAccessLevel = at.Case_Access__c; 
    }
    
/**     
* @description  To update standard accountteammember record with values of custom accountteammember
* @param        at DESCRIPTION: Accepts the standard accountteammember record
* @param        atm DESCRIPTION: Accepts the custom accountteammember record
*/  
    public static void updateTeamMember(AccountTeamMember eat, Account_Team__c at){
          eat.TeamMemberRole = at.Team_Role__c;
          eat.AccountAccessLevel = at.Account_Access__c;
          eat.ContactAccessLevel = at.Contact_Access__c;
          eat.OpportunityAccessLevel = at.Opportunity_Access__c;
          eat.CaseAccessLevel = at.Case_Access__c;
          eat.Business_Segment__c = at.Business_Segment__c;
    }
    
/**     
* @description  To check if account team member already exist 
* @param        NAME:at DESCRIPTION: Accepts the custom accountteammember record
* @param        NAME:atm DESCRIPTION: Accepts the map of standard accountteammember records
* @return       AccountTeamMember 
*/ 
    public static AccountTeamMember accountTeamMemberAlreadyExist(Account_Team__c at, Map<Id,List<AccountTeamMember>> actRecords){
      AccountTeamMember existingatm = new AccountTeamMember();
        for(AccountTeamMember teamMember: actRecords.get(at.Source_Account__c)){
            if(teamMember.UserId == at.Team_Member__c){
                existingatm = teamMember;
            }
        }
        return existingatm;
    }
    
/**     
* @description  To check if account team member already exist with same role
* @param        NAME:at DESCRIPTION: Accepts the custom accountteammember record
* @param        NAME:atm DESCRIPTION: Accepts the map of standard accountteammember records
* @return       AccountTeamMember 
*/ 
    public static AccountTeamMember accountTeamMemberRoleAlreadyExist(Account_Team__c at, Map<Id,List<AccountTeamMember>> actRecords){
      AccountTeamMember existingatm = new AccountTeamMember();
        for(AccountTeamMember teamMember: actRecords.get(at.Source_Account__c)){
            if(teamMember.UserId == at.Team_Member__c && teamMember.TeamMemberRole == at.Team_Role__c){
                existingatm = teamMember;
            }
        }
        return existingatm;
    }
    
/**   
* @description  To fetch the existing account team member 
* @param        actRecords DESCRIPTION: Accepts the map of standard accountteammember records
* @param        accRecords DESCRIPTION: Accept set of account ids
*/ 
    
   public static void getAccountTeamMember( Map<Id,List<AccountTeamMember>> actRecords,set<id> accRecords){
         for(Account acc: [Select Id, (Select Id, AccountId,TeamMemberRole,UserId From AccountTeamMembers) From Account  Where Id in :accRecords]){
            if(acc.AccountTeamMembers.size() > 0){
                actRecords.put(acc.id,acc.AccountTeamMembers);
            }
        }
   }
   
   
/**   
* @description  To fetch the existing account team member 
* @param        existingAccountTeamMember DESCRIPTION: Accepts the map of standard accountteammember records
* @param        atm DESCRIPTION: Accept set of account ids
*/ 
    public static void compareExistingAccountTeamRecordWithCustomRecord(AccountTeamMember existingAccountTeamMember,Account_Team__c at,AccountTeamMember atm){
          if(roles.contains(existingAccountTeamMember.TeamMemberRole)){
                 boolean roleChanged =  existingAccountTeamMember.TeamMemberRole != at.Team_Role__c;
                 boolean salesManager = at.Team_Role__c == 'Sales Manager' && roleChanged;
                 boolean cmo = at.Team_Role__c == 'CMO' && roleChanged && existingAccountTeamMember.TeamMemberRole != 'Sales Manager';
                 boolean ofo = at.Team_Role__c == 'OFO' && roleChanged && existingAccountTeamMember.TeamMemberRole != 'Sales Manager' && existingAccountTeamMember.TeamMemberRole != 'CMO';
                 if(salesManager || cmo || ofo ){
                       updateTeamMember(existingAccountTeamMember,at);
                       toupdate.add(existingAccountTeamMember);
                 }
          }else if(existingAccountTeamMember.TeamMemberRole != ''){
                system.debug('TeamMemberRole :::::'+existingAccountTeamMember.TeamMemberRole);
                createTeamMember(at,atm);
                toInsert.add(atm);
         }
    }
    
   

        

}