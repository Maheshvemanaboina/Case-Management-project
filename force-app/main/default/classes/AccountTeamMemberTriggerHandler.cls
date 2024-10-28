public with sharing class AccountTeamMemberTriggerHandler extends TriggerHandler {
    
    public override void processBeforeUpdate(){
       
        if(!RecursionHandler.isAccountTeamMemberAfterUpdateRecursive){
            RecursionHandler.isAccountTeamMemberAfterUpdateRecursive = true;
            AccountTeamMemberValidations.accountTeamPrimaryValidation(false,(List<Account_Team__c>)trigger.new,(Map<id,Account_Team__c>)trigger.oldMap);
            AccountTeamMemberValidations.validateMemberExistanceTwice(false,(List<Account_Team__c>)trigger.new,(Map<id,Account_Team__c>)trigger.oldMap);
            AccountTeamUpdateHandler.checkRoleChange((List<Account_Team__c>)trigger.new,(Map<id,Account_Team__c>)trigger.oldMap);
        }
    }

    public override void processBeforeInsert(){
        AccountTeamMemberValidations.accountTeamPrimaryValidation(true,(List<Account_Team__c>)trigger.new,null);
        AccountTeamMemberValidations.validateMemberExistanceTwice(true,(List<Account_Team__c>)trigger.new,null);
        AccountTeamUpdateHandler.defineAccesslevelToTeamMember((List<Account_Team__c>)trigger.new);
        
    }
    
    public override void processAfterUpdate(){
		//Added by praneeth
        if(!RecursionHandler.isLeadTrigAfterUpdateRecursive){            
            RecursionHandler.isLeadTrigAfterUpdateRecursive = true;
            AccountTeam.updateAccountTeamMember((Map<Id,Account_Team__c>)trigger.oldMap,(Map<Id,Account_Team__c>)trigger.newMap);
        } //end       
        AccountTeamUpdateHandler.updateEndCustomerOwner((List<Account_Team__c>)trigger.new,(Map<id,Account_Team__c>)trigger.oldMap);        
    }

    public override void processBeforeDelete(){        
        AccountTeamMemberValidations.validateDeleteMember((List<Account_Team__c>)trigger.old);
    }
    
    //Added by praneeth
    public override void processAfterInsert(){        
        AccountTeam.addAccountTeamMember((List<Account_Team__c>)trigger.new);
    }
    
    //Added by praneeth
    public override void processAfterDelete(){
        AccountTeam.deleteTeamMember((Map<Id,Account_Team__c>)trigger.oldMap);
        AccountTeamHelper.recalculatePrimarySMOnDeletion((List<Account_Team__c>)trigger.old);
        AccountTeamHelper.recalculateEndCustomerOwner((List<Account_Team__c>)trigger.old);
    }
    
    //Added by praneeth
    public override void processAfterUnDelete(){
       AccountTeam.addAccountTeamMember((List<Account_Team__c>)trigger.new);
    }

}