/******************************
* Written By : Rekha
* Purpose : To Roll up of Sales Manager(SM), Sales Assistant(SA) and Person Responsible(PR) to Account Teams from Partner Role
          : To add salesforce user on partner role

@Changes
*Rekha : 19-10-2021 --- fetch relationship name/role from SAP partner role function into account teams 
*Rekha : 22-11-2021 --- To update account team member role when partner role relationship name get changes from SAP
*Mohan : 17-02-2022 --- To Update or create account team member role when partner role relationship name is Sales Assistant then Account Team member 
                        Create/update with role as CMO and when partner role relationship name is Person Responsible then Account Team member 
                        Create/update with role as OFO
*Rekha : 23-03-2022 --- To log errors when we are not able to find a SF user with the a SAP employee no or user is not active in SF anymore
*Mahendra : 07-09-2022 - To deactivate the partner role when the role (or) sales area has changed in SAP and pushed to SF
					   - To add/remove the account team member as per the changes of partner roles pushed from SAP
* ****************************/
public class CreateAccountTeamMember { 
    
    // method to create account team member from partner role
    @future
    public static void addMember(set<Id> partnerRoleIds, set<string> sapEmployeeIdSet){  
        
        //Variable declaration
        map<string,user> userIdMap = new map<string,user>();
        list<Account_Team__c> accountTeamMemberListToCreate = new list<Account_Team__c>();
        list<Account_Team__c> accountTeamMemberList = new list<Account_Team__c>();      
        list<Partner_Role__c> partnerRoleListUpdate = new list<Partner_Role__c>();
        list<DebugLog__c> errorLogs = new list<DebugLog__c>();
        map<id,list<Account_Team__c>> accountTeamMemberMap = new map<id,list<Account_Team__c>>();
        map<id,list<Account_Team__c>> existingAccountTeamMemberMap = new map<id,list<Account_Team__c>>();        
        Account_Team__c team;
     
    	
        // query partner role 
        map<id,Partner_Role__c> partnerRoleMap = new map<id,Partner_Role__c>([SELECT id,SAP_Employee_Id__c,SAP_Employee_Id_Without_Zeros__c,Relation_Name__c,Source_Account__c,Salesforce_User__c,Sales_Area__r.Business_Segment__c from Partner_Role__c WHERE ID IN : partnerRoleIds and SAP_Employee_Id__c!=NULL AND Sales_Area__c != null AND Sales_Area__r.Active__c = true AND Sales_Area__r.To_Be_Decommissioned__c = false]);         
        
        // query user record with SAP_Employee_Id__c
        for(user obj : [SELECT id,SAP_Employee_Id__c,IsActive,Business_Segment__c,SAP_Employee_Id_Without_Zeros__c,Friesland_Campina_Role__c FROM user WHERE SAP_Employee_Id_Without_Zeros__c IN : sapEmployeeIdSet]){
            userIdMap.put(obj.SAP_Employee_Id_Without_Zeros__c,obj);   
        }
        //system.debug('-----'+userIdMap);
        
             
        //create account team member        
        for(Partner_Role__c each : partnerRoleMap.values()){
            
            //when we are not able to find a SF user with the a SAP employee no
            if(userIdMap.isEmpty()){
            	DebugLog__c err = logError('Account_Team__c','',string.valueof(each),'Apex Class','CreateAccountTeamMember','addMember','Error',each.SAP_Employee_Id__c+'-Employee not found in SF','INTERNAL ERROR','When adding memeber to account teams','User not found in SF');    
            	errorLogs.add(err);
            }
            if(!userIdMap.isEmpty() && !userIdMap.containskey(each.SAP_Employee_Id_Without_Zeros__c)){
            	DebugLog__c err = logError('Account_Team__c','',string.valueof(each),'Apex Class','CreateAccountTeamMember','addMember','Error',each.SAP_Employee_Id__c+'-Employee not found in SF','INTERNAL ERROR','When adding memeber to account teams','User not found in SF');    
            	errorLogs.add(err);    
            }
            if(!userIdMap.isEmpty() && userIdMap.containskey(each.SAP_Employee_Id_Without_Zeros__c) && userIdMap.get(each.SAP_Employee_Id_Without_Zeros__c)!=NULL && !userIdMap.get(each.SAP_Employee_Id_Without_Zeros__c).isActive){
           		DebugLog__c err = logError('Account_Team__c','',string.valueof(each),'Apex Class','CreateAccountTeamMember','addMember','Error',each.SAP_Employee_Id__c+'-User is not active in SF','INTERNAL ERROR','When adding memeber to account teams','Inactive user -'+userIdMap.get(each.SAP_Employee_Id_Without_Zeros__c).id);    
            	errorLogs.add(err);    
            }    
            
            if(!userIdMap.isEmpty() && userIdMap.containskey(each.SAP_Employee_Id_Without_Zeros__c) && userIdMap.get(each.SAP_Employee_Id_Without_Zeros__c)!=NULL && userIdMap.get(each.SAP_Employee_Id_Without_Zeros__c).isActive){
                team = new Account_Team__c();
                team.Team_Member__c = userIdMap.get(each.SAP_Employee_Id_Without_Zeros__c).id; 
                //team.TeamMemberRole = userIdMap.get(each.SAP_Employee_Id_Without_Zeros__c).Friesland_Campina_Role__c;
                team.Team_Role__c = partnerRoleMap.get(each.id).Relation_Name__c == Constants.ACCOUNT_TEAM_ROLE_SALES_ASSISTANT?Constants.ACCOUNT_TEAM_ROLE_CMO: partnerRoleMap.get(each.id).Relation_Name__c == Constants.ACCOUNT_TEAM_ROLE_PERSON_RESPONSIBLE?Constants.ACCOUNT_TEAM_ROLE_OFO:partnerRoleMap.get(each.id).Relation_Name__c ;
                team.Source_Account__c = partnerRoleMap.get(each.id).Source_Account__c;
                team.Business_Segment__c = each.Sales_Area__r.Business_Segment__c;
                team.Primary__c = false;
                // add team sourcewise
                if(!accountTeamMemberMap.isEmpty() && accountTeamMemberMap.containskey(each.Source_Account__c) && accountTeamMemberMap.get(each.Source_Account__c)!=NULL)
                	accountTeamMemberMap.get(each.Source_Account__c).add(team);	    
                else
                    accountTeamMemberMap.put(each.Source_Account__c,new list<Account_Team__c>{team});              
                               
                //add user to partner role
                
                each.Salesforce_User__c = userIdMap.get(each.SAP_Employee_Id_Without_Zeros__c).id;
                partnerRoleListUpdate.add(each);
            }
        }        
        
        //Mark primary Team member
        // user with same role and same business segment with existing member can not be marked as primary
        if(accountTeamMemberMap.size()>0){
            accountTeamMemberList = [SELECT id,Team_Member__c,Team_Role__c,Business_Segment__c,Primary__c,Source_Account__c FROM Account_Team__c WHERE Team_Role__c	!=NULL and Business_Segment__c!=NULL and Source_Account__c IN : accountTeamMemberMap.keyset()];    
            for(Account_Team__c each : accountTeamMemberList){
            	if(!existingAccountTeamMemberMap.isEmpty() && existingAccountTeamMemberMap.containskey(each.Source_Account__c) && existingAccountTeamMemberMap.get(each.Source_Account__c)!=NULL)
                	existingAccountTeamMemberMap.get(each.Source_Account__c).add(each);    
                else
                    existingAccountTeamMemberMap.put(each.Source_Account__c,new list<Account_Team__c>{each});
            }
            
            for(id accId : accountTeamMemberMap.keyset()){
            	if(!existingAccountTeamMemberMap.isEmpty() && existingAccountTeamMemberMap.containskey(accId) &&  existingAccountTeamMemberMap.get(accId)!=NULL)    
            		existingAccountTeamMemberMap.get(accId).addAll(accountTeamMemberMap.get(accId));
                else{
                    list<Account_Team__c> accTeamList = new list<Account_Team__c>();
                    accTeamList.addAll(accountTeamMemberMap.get(accId));
                    existingAccountTeamMemberMap.put(accId,accTeamList);    
                }
                
                list<Account_Team__c> listToCreate = new list<Account_Team__c>();
                listToCreate.addAll(accountTeamMemberMap.get(accId));
                
                list<Account_Team__c> existAccTeamList = new list<Account_Team__c>();
                existAccTeamList.addAll(existingAccountTeamMemberMap.get(accId));
                
                Set<String> businessSegmentTeamRolePrimarySet = new Set<String>();
                for(Account_Team__c each : listToCreate){
                    integer count=0; 
                    integer userCount = 0;
                    if(!existAccTeamList.isEmpty()){ //if starts                    	
                        for(Account_Team__c atm : existAccTeamList){   
                            
                            if(each.Team_Member__c == atm.Team_Member__c)
                            userCount++;                            
                            if(userCount>1)
                            continue;
                            
                            if(String.isNotBlank(String.valueOf(atm.Id)) && atm.Primary__c){
                                businessSegmentTeamRolePrimarySet.add(atm.Business_Segment__c+'-'+atm.Team_Role__c);
                            }
                            
                            /*if(each.Business_Segment__c == atm.Business_Segment__c && each.Team_Role__c == atm.Team_Role__c)
                            count++;*/
                            
                            if(
                                each.Business_Segment__c == atm.Business_Segment__c && 
                                each.Team_Role__c == atm.Team_Role__c &&
                                !businessSegmentTeamRolePrimarySet.contains(atm.Business_Segment__c+'-'+atm.Team_Role__c)
                            )
                            {
                                businessSegmentTeamRolePrimarySet.add(atm.Business_Segment__c+'-'+atm.Team_Role__c);
                                each.Primary__c = true;
                            }
                        }//inner for loop ends
                        /*if(count==1)
                            each.primary__c = true;*/                 
                        
                    } //if ends
                    accountTeamMemberListToCreate.add(each);
                } //outer for loop ends
                
                
            }            
         
           
        }
        //system.debug('-----'+accountTeamMemberListToCreate);
        //system.debug('-----'+partnerRoleListUpdate);
        
        //update partner role with user
        try{
            
            if(partnerRoleListUpdate.size()>0){ 
                RecursionHandler.inFutureContext = true;
                update partnerRoleListUpdate;                
            }  
       
        }catch(exception excp){
        	String  errorMessage = ' Line Number '+excp.getLineNumber() + ' Error message'+excp.getMessage()+' Stack Trace:'+excp.getStackTraceString();            
        	// log error in Debug log object  
        	DebugLog__c err = logError('Partner_Role__c','',string.valueof(partnerRoleListUpdate),'Apex Class','CreateAccountTeamMember','addMember','Error',errorMessage,'INTERNAL ERROR','When updating salesforce user on Partner Role',excp.getStackTraceString());
        	errorLogs.add(err);
        }
         
        //insert accountTeamMemberListToCreate
        if(accountTeamMemberListToCreate.size()>0){            
        	// DML statement
			Database.SaveResult[] srList = Database.insert(accountTeamMemberListToCreate, false);            
            for(Integer i=0;i<srList.size();i++){
                if(!srList[i].isSuccess()){  
                    for(Database.Error err : srList[i].getErrors()) {
                    	DebugLog__c errs = logError('Account_Team__c','',string.valueof(accountTeamMemberListToCreate[i]),'Apex Class','CreateAccountTeamMember','addMember','Error',err.getStatusCode()+': '+err.getMessage(),'INTERNAL ERROR','When adding member to account teams','');
                    	errorLogs.add(errs);
                    }
                }    
            }    
            
        }        
       
        //upsert debug log
        if(!errorLogs.isEmpty())
        insert errorLogs;
             
    }
    
    //*Rekha - 22-11-2021 - To update account team member role
    //this method update account team member role when there is a change in partner role relationship name
    @future
    public static void updateAccountTeamMemberRole(set<id> partnerRoleIdsRoleUpdate,set<id> sourceAccountSetRoleUpdate,set<string> sapEmployeeIdSetRoleUpdate){
        
        list<Account_Team__c> accountTeamMemberListToUpdate = new list<Account_Team__c>();
        list<DebugLog__c> errorLogs = new list<DebugLog__c>();       
        set<id> userIdsFromPartnerRole = new set<id>();
        
        // query partner role 
        map<id,Partner_Role__c> partnerRoleMap = new map<id,Partner_Role__c>([SELECT id,SAP_Employee_Id__c,SAP_Employee_Id_Without_Zeros__c,Relation_Name__c,Source_Account__c,Salesforce_User__c from Partner_Role__c WHERE ID IN : partnerRoleIdsRoleUpdate and Salesforce_User__c!=null AND Sales_Area__c != null AND Sales_Area__r.Active__c = true AND Sales_Area__r.To_Be_Decommissioned__c = false]);         
        
        if(!partnerRoleMap.isEmpty()){
            for(Partner_Role__c each : partnerRoleMap.values()){
            	userIdsFromPartnerRole.add(each.Salesforce_User__c);    
            }
            Set<String> primarySMCMOOFOSet = getPrimarySMCMOOFOFromExistingAccTeams(sourceAccountSetRoleUpdate);
            for(Account_Team__c each : [SELECT id,Team_Member__c,Source_Account__c,Team_Role__c,Primary__c,Business_Segment__c FROM Account_Team__c
                                                     WHERE Team_Member__c IN : userIdsFromPartnerRole and Source_Account__c IN : sourceAccountSetRoleUpdate]){
                for(Partner_Role__c obj : partnerRoleMap.values()){
                    if(each.Team_Member__c == obj.Salesforce_User__c && each.Source_Account__c == obj.Source_Account__c){
                        each.Team_Role__c = obj.Relation_Name__c == Constants.ACCOUNT_TEAM_ROLE_SALES_ASSISTANT?Constants.ACCOUNT_TEAM_ROLE_CMO:  obj.Relation_Name__c == Constants.ACCOUNT_TEAM_ROLE_PERSON_RESPONSIBLE?Constants.ACCOUNT_TEAM_ROLE_OFO:obj.Relation_Name__c;
                        if(primarySMCMOOFOSet.contains(each.Source_Account__c+'-'+each.Business_Segment__c+'-'+each.Team_Role__c)){
                            each.Primary__c = false;
                        }
                        accountTeamMemberListToUpdate.add(each);
                    }                                                 
                }                
            }
        }
        
        if(!accountTeamMemberListToUpdate.isEmpty()){
            
            Database.SaveResult[] srList = Database.update(accountTeamMemberListToUpdate, false);            
            for(Integer i=0;i<srList.size();i++){
                if(!srList[i].isSuccess()){  
                    for(Database.Error err : srList[i].getErrors()) {
                        DebugLog__c errs = logError('Account_Team__c','',string.valueof(accountTeamMemberListToUpdate[i]),'Apex Class','CreateAccountTeamMember','updateAccountTeamMemberRole','Error',err.getStatusCode()+': '+err.getMessage(),'INTERNAL ERROR','When updating role on account teams','');
                        errorLogs.add(errs);
                    }
                }    
            } 
        }
        if(!errorLogs.isEmpty())
            insert errorLogs;
     
    }
    
    
    //Rekha - 22-11-2021 - get the updated set of partner role records and compare those with the existing set of partner records for an account
    //Identify the one which is not in the updated list of records and deactivate it.
    //Purpose : Deactivated/Deleted partner roles are not sent from SAP.
    //Deactivating a partner role in SF should remove the member from the account team for a particular account.
    @future
    public static void deactivatePartnerRole(set<id> updatedPartnerRoleIds,set<id> sourceAccountOfUpdatedPartnerRoles,Set<String> sourceAccountUserSet){
        deactivatePartnerRoleNonFuture(updatedPartnerRoleIds, sourceAccountOfUpdatedPartnerRoles, sourceAccountUserSet);
    }
    
    public static void deactivatePartnerRoleNonFuture(set<id> updatedPartnerRoleIds,set<id> sourceAccountOfUpdatedPartnerRoles,Set<String> sourceAccountUserSet){
    	list<Partner_Role__c> partnerRoleListToUpdate = new list<Partner_Role__c>();
        list<DebugLog__c> errorLogs = new list<DebugLog__c>();
        set<id> sourceAccountIds = new set<id>();
        set<id> employeeIds = new set<id>();
        set<string> roleSet = new set<string>();
        Set<String> sourceAccountUserRoleSet = new Set<String>();
        
        String queryString = 'SELECT id,Source_Account__c,Relation_Name__c,Active__c,Salesforce_User__c,SAP_Employee_Id__c,Sales_Area__c FROM Partner_Role__c';
        queryString	+= ' WHERE Id Not IN: updatedPartnerRoleIds and Source_Account__c IN: sourceAccountOfUpdatedPartnerRoles AND Active__c = true ';
        queryString += !sourceAccountUserSet.isEmpty() ? ' AND Salesforce_User__c != null' : '';
        
        //--> partnerRoleIdsDeactivate == updated ids
        //get the partner role records which are not in the updated id set for accounts and deactivate those partner roles
        for(Partner_Role__c each : Database.query(queryString)){
            if(sourceAccountUserSet.isEmpty() || (!sourceAccountUserSet.isEmpty() && sourceAccountUserSet.contains(each.Source_Account__c+'-'+each.SAP_Employee_Id__c+'-'+each.Sales_Area__c))){
                each.Active__c = false;
                partnerRoleListToUpdate.add(each);
            }
        }
        //system.debug('-----partnerRoleListToUpdate-'+partnerRoleListToUpdate);
        
        if(!partnerRoleListToUpdate.isEmpty()){   
            RecursionHandler.inFutureContext = true;
            Database.SaveResult[] srList = Database.update(partnerRoleListToUpdate, false);            
            for(Integer i=0;i<srList.size();i++){
                if(srList[i].isSuccess()){
                	sourceAccountIds.add(partnerRoleListToUpdate[i].Source_Account__c);	
                    employeeIds.add(partnerRoleListToUpdate[i].Salesforce_User__c);                    
                    roleSet.add(partnerRoleListToUpdate[i].Relation_Name__c == Constants.ACCOUNT_TEAM_ROLE_SALES_ASSISTANT?Constants.ACCOUNT_TEAM_ROLE_CMO: partnerRoleListToUpdate[i].Relation_Name__c == Constants.ACCOUNT_TEAM_ROLE_PERSON_RESPONSIBLE?Constants.ACCOUNT_TEAM_ROLE_OFO:partnerRoleListToUpdate[i].Relation_Name__c );
                    sourceAccountUserRoleSet.add(partnerRoleListToUpdate[i].Source_Account__c+'-'+partnerRoleListToUpdate[i].Salesforce_User__c+'-'+(partnerRoleListToUpdate[i].Relation_Name__c == Constants.ACCOUNT_TEAM_ROLE_SALES_ASSISTANT?Constants.ACCOUNT_TEAM_ROLE_CMO: partnerRoleListToUpdate[i].Relation_Name__c == Constants.ACCOUNT_TEAM_ROLE_PERSON_RESPONSIBLE?Constants.ACCOUNT_TEAM_ROLE_OFO:partnerRoleListToUpdate[i].Relation_Name__c));
                }
                if(!srList[i].isSuccess()){  
                    for(Database.Error err : srList[i].getErrors()) {
                        DebugLog__c errs = logError('Partner_Role__c','',string.valueof(partnerRoleListToUpdate[i]),'Apex Class','CreateAccountTeamMember','deactivatePartnerRole','Error',err.getStatusCode()+': '+err.getMessage(),'INTERNAL ERROR','When deactivating partner role','');
                        errorLogs.add(errs);
                    }
                }    
            }
           
        }
        
        //call method to remove the parnter roles from account teams when active flag is set to false
        if(!sourceAccountIds.isEmpty() && !employeeIds.isEmpty() && !roleSet.isEmpty() && !sourceAccountUserRoleSet.isEmpty()){
        	removeMember(sourceAccountIds,roleSet,employeeIds,sourceAccountUserRoleSet);    
        }
        
        //insert error logs
        if(!errorLogs.isEmpty())
            insert errorLogs;
        
    }
    
    // method to remove account team member from partner role    
    public static void removeMember(set<id> sourceAccountIds , set<string> roleSet , set<id> employeeIdsToRemove, Set<String> sourceAccountUserRoleSet){
        
        //variable declaration
        //set<id> userIdSet = new set<id>();
        list<Account_Team__c> teamMemberListToDelete = new list<Account_Team__c>();
        
        try{
            
            // query account team member record to delete
            //teamMemberListToDelete = [SELECT id,Team_Role__c,Source_Account__c FROM Account_Team__c WHERE Team_Member__c IN : employeeIdsToRemove and Team_Role__c IN : roleSet and Source_Account__c IN : sourceAccountIds];
            for(Account_Team__c act : [SELECT id,Team_Role__c,Source_Account__c, Team_Member__c FROM Account_Team__c WHERE Team_Member__c IN : employeeIdsToRemove and Team_Role__c IN : roleSet and Source_Account__c IN : sourceAccountIds]){
                if(sourceAccountUserRoleSet.contains(act.Source_Account__c+'-'+act.Team_Member__c+'-'+act.Team_Role__c)){
                    teamMemberListToDelete.add(act);
                }
            }
            // delete team member list
            if(teamMemberListToDelete.size()>0)
                delete teamMemberListToDelete; 
        }// try block ends
        catch(Exception excp){
			String  errorMessage = ' Line Number '+excp.getLineNumber() + ' Error message'+excp.getMessage()+' Stack Trace:'+excp.getStackTraceString();            
            // log error in Debug log object   
            logError('Partner_Role__c','',string.valueof(teamMemberListToDelete),'Apex Class','CreateAccountTeamMember','removeMember','Error',errorMessage,'INTERNAL ERROR','When removing member from account teams',excp.getStackTraceString());
        }
        
    
    }
    
   
    
    
    //this method logs error 
    public static DebugLog__c logError(String Objectname,string objectNumber,string record,string processType,string processName,string opertationName,string severity,string errorMessage,string status,string comment,string stackTrace){
        Integer maxLength = DebugLog__c.Message__c.getDescribe().getLength();
        DebugLog__c errorLog = new DebugLog__c(); 
        errorLog.Object__c = Objectname;
        errorLog.Object_Number__c =objectNumber;
        errorLog.Record__c = record;
        errorLog.Errored_Process_Type__c = processType;
        errorLog.Errored_Process_Name__c = processName;      
        errorLog.Operation_Name__c = opertationName; 
        errorLog.Severity__c = severity;
        //errorLog.Message__c = errorMessage;
        if (errorMessage != null && errorMessage.length() > maxLength) {
    	errorLog.Message__c = errorMessage.substring(0, maxLength);  // Truncate the message
		} else {
    	errorLog.Message__c = errorMessage;
		}
        errorLog.TypeName__c = status;
        errorLog.Comments__c = comment;
        errorLog.StackTraceString__c  = stackTrace;        
        return errorLog;
    }
    
    /*
     * Written by	:	Mahendra
     * @description	:	to get the primary SM/CMO/OFO from the existing account team member records
     * This method helps to mark the primary flag as false, when a new Account team member is being added from the
     * partner role for same business segment and same role
     * @param	sourceAccountIdsSet	DESCRIPTION:	accepts set of accountids
     * @return	Set<String>	DESCRIPTION:	it returns the unique set containing source account, business segment and team role
	*/
    public static Set<String> getPrimarySMCMOOFOFromExistingAccTeams(Set<Id> sourceAccountIdsSet){
        List<String> roleSet = new List<String>{Constants.ACCOUNT_TEAM_ROLE_SALES_MANAGER,Constants.ACCOUNT_TEAM_ROLE_CMO,Constants.ACCOUNT_TEAM_ROLE_OFO};
            Set<String> primaryRolesSet = new Set<String>();
        for(Account_Team__c accTeam : [SELECT Id, Business_Segment__c, Primary__c, Source_Account__c, Team_Role__c
                                       FROM Account_Team__c WHERE Source_Account__c IN: sourceAccountIdsSet AND
                                       Primary__c = true AND Team_Role__c IN: roleSet])
        {
            primaryRolesSet.add(accTeam.Source_Account__c+'-'+accTeam.Business_Segment__c+'-'+accTeam.Team_Role__c);
        }
        return primaryRolesSet;
    }
    
}