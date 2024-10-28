trigger UserTrigger on User (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    UserTriggerHandler UserTrig = new UserTriggerHandler();
    UserTrig.process();
    
    AccountTeamMember_UserTriggerHandler trig = new AccountTeamMember_UserTriggerHandler();
    trig.process();
}