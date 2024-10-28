/******************************
* Written By : Rekha
* Purpose : To Roll up of Sales Manager(SM), Sales Assistant(SA) and Person Responsible(PR) to Account Teams from Partner Role 
			-when user is created/update with SAP Employee Id
*Changes :
		 Rekha - 19-97-2023 - Dont remove users from account teams when they become inactive. so commented the those  
* ****************************/
public class AccountTeamMember_UserTriggerHandler extends TriggerHandler{
    
    public override void processAfterInsert(){
        
        //variable declaration
     	list<user> newList = (list<user>) trigger.new;
        set<string> sapEmployeeIdSet = new set<string>();
        
        
        //iterate through user and check for sap employee id
        for(user each : newList){
            if(each.SAP_Employee_Id__c!=null){
            	sapEmployeeIdSet.add(each.SAP_Employee_Id_Without_Zeros__c);    
            }    
        }
        
        if(!sapEmployeeIdSet.isEmpty())
            callCreateAccountTeamMemberClass(sapEmployeeIdSet);
        
    }

	public override void processAfterUpdate(){
    	//variable declaration
     	list<user> newList = (list<user>) trigger.new;
        map<id,user> oldMap = (map<id,user>) trigger.oldMap;
        set<string> sapEmployeeIdSet = new set<string>(); 
        set<id> inactiveUserIdSet = new set<id>();
        
        //iterate through user and check for sap employee id
        for(user each : newList){
            if(each.SAP_Employee_Id__c!=oldMap.get(each.id).SAP_Employee_Id__c && each.SAP_Employee_Id__c!=null){
            	sapEmployeeIdSet.add(each.SAP_Employee_Id_Without_Zeros__c);    
            }
            if(each.IsActive!=oldMap.get(each.id).IsActive){
                if(each.IsActive)
                	sapEmployeeIdSet.add(each.SAP_Employee_Id_Without_Zeros__c);
                if(!each.IsActive)
                    inactiveUserIdSet.add(each.id);
            }
          
        }
        
        system.debug('----'+sapEmployeeIdSet+'----'+inactiveUserIdSet);
        
        if(!sapEmployeeIdSet.isEmpty())
            callCreateAccountTeamMemberClass(sapEmployeeIdSet);
        
        
        if(!inactiveUserIdSet.isEmpty() && System.IsBatch() == true){
            System.enqueueJob(new DeleteTeammemberOnUserUpdate(inactiveUserIdSet));
        }
        
        if(!inactiveUserIdSet.isEmpty() && System.IsBatch() == false && System.isFuture() == false){
            removeAccountTeamMember(inactiveUserIdSet);
        }
        
		
            
    }  
    
    public static void callCreateAccountTeamMemberClass(set<string> employeeIdSet){
        
        set<id> partnerRoleIds = new set<id>();
    	
        // query partner role 
        //map<id,Partner_Role__c> partnerRoleMap = new map<id,Partner_Role__c>([SELECT id,SAP_Employee_Id__c,SAP_Employee_Id_Without_Zeros__c,Salesforce_User__c from Partner_Role__c WHERE SAP_Employee_Id__c!=NULL and Salesforce_User__c=NULL]);
        map<id,Partner_Role__c> partnerRoleMap = new map<id,Partner_Role__c>([SELECT id,SAP_Employee_Id__c,SAP_Employee_Id_Without_Zeros__c,Salesforce_User__c from Partner_Role__c WHERE SAP_Employee_Id__c!=NULL and Salesforce_User__c=NULL AND SAP_Employee_Id_Without_Zeros__c IN: employeeIdSet]);         
        
        if(!partnerRoleMap.isEmpty()){
            for(string each : employeeIdSet){
                for(Partner_Role__c obj: partnerRoleMap.values()){
                    if(each == obj.SAP_Employee_Id_Without_Zeros__c){
                    	partnerRoleIds.add(obj.id);    
                    }   
                }
            } 
            
            if(!partnerRoleIds.isEmpty())
             CreateAccountTeamMember.addMember(partnerRoleIds, employeeIdSet);
        }    
        
    }
    
    @future
    public static void removeAccountTeamMember(set<id> userIdSet){
        
        //variable declaration        
        list<Account_Team__c> teamMemberListToDelete = new list<Account_Team__c>(); 
        list<Partner_Role__c> partnerRoleListToUpdate = new list<Partner_Role__c>();
        
        try{
            // query account team member record to delete
            teamMemberListToDelete = [SELECT id FROM Account_Team__c WHERE Team_Member__c IN : userIdSet];
            system.debug('teamMemberListToDelete size'+teamMemberListToDelete.size());
            system.debug('teamMemberListToDelete '+teamMemberListToDelete);
           
            // delete team member list
            if(teamMemberListToDelete.size()>0)
                delete teamMemberListToDelete; 
            
            for(Partner_Role__c each : [SELECT id,Salesforce_User__c FROM Partner_Role__c WHERE Salesforce_User__c IN : userIdSet]){
            	each.Salesforce_User__c = NULL;
                partnerRoleListToUpdate.add(each);
            }
            
            if(partnerRoleListToUpdate.size()>0){
                system.debug('entered partnerRoleListToUpdate');
                RecursionHandler.inFutureContext = true;
                Database.SaveResult[] srList = Database.update(partnerRoleListToUpdate, false);                 
            }
            
        }// try block ends
        catch(Exception excp){
            system.debug('entered catch block');
			String  errorMessage = ' Line Number '+excp.getLineNumber() + ' Error message'+excp.getMessage()+' Stack Trace:'+excp.getStackTraceString();  
            system.debug(errorMessage);
            // log error in Debug log object  
            CreateAccountTeamMember.logError('Account_Team__c','',string.valueof(teamMemberListToDelete),'Apex Class','AccountTeamMember_UserTriggerHandler','removeAccountTeamMember','Error',errorMessage,'INTERNAL ERROR','When removing member from account teams',excp.getStackTraceString());
        }
        
        
    }   
    
   
}