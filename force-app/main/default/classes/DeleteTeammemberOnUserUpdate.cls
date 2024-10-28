/**      
* @description          To delete custom account team member when user becomes inactive.
                        Created this queuable class to overcome salesforce exception on AccountTeamMember_UserTriggerHandler.removeAccountTeamMember('cannot call future method from batch class').
*/

public class DeleteTeammemberOnUserUpdate implements Queueable{
    set<id> userIds = new set<id>();
    
    public DeleteTeammemberOnUserUpdate(set<id> userIdSet) {
        this.userIds = userIdSet;
    }
    
    public void execute(QueueableContext queCont) {
        list<Account_Team__c> teamMemberListToDelete = new list<Account_Team__c>(); 
        list<Partner_Role__c> partnerRoleListToUpdate = new list<Partner_Role__c>();        
        try{           
            teamMemberListToDelete = [SELECT id FROM Account_Team__c WHERE Team_Member__c IN : userIds];
            if(teamMemberListToDelete.size()>0){
                delete teamMemberListToDelete;
            }                           
            for(Partner_Role__c each : [SELECT id,Salesforce_User__c FROM Partner_Role__c WHERE Salesforce_User__c IN : userIds]){
                each.Salesforce_User__c = NULL;
                partnerRoleListToUpdate.add(each);
            }           
            if(partnerRoleListToUpdate.size()>0){
                RecursionHandler.inFutureContext = true;
                Database.SaveResult[] srList = Database.update(partnerRoleListToUpdate, false);                 
            }
            
        }
        catch(Exception exe){
            String  errorMessage = ' Line Number '+exe.getLineNumber() + ' Error message'+exe.getMessage()+' Stack Trace:'+exe.getStackTraceString();  
            system.debug(errorMessage);           
        }
        
    }    
}