trigger AccountTeamTrigger on Account_Team__c (before update,after update,before insert,after insert,before delete,after delete,after undelete) {
    AccountTeamMemberTriggerHandler atm = new AccountTeamMemberTriggerHandler();
    atm.process();
}