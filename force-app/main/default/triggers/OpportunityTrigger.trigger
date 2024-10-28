trigger OpportunityTrigger on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
   
   OpportunityTriggerHandler OppTrig = new OpportunityTriggerHandler();
   OppTrig.process();
}