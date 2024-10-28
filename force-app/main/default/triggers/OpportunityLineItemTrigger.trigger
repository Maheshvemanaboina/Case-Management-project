trigger OpportunityLineItemTrigger on OpportunityLineItem (after insert, after delete) {

     if(trigger.isAfter && trigger.isInsert){
        OpportunityLineItemTriggerHandler.updateNPDProjectOnOpportunity(trigger.new);
        OpportunityLineItemTriggerHandler.updateCampaignOnOpportunity(trigger.new);
    }
     if(trigger.isAfter && trigger.isDelete){
         OpportunityLineItemTriggerHandler.updateCampaignOnProductDelete(trigger.old);
     }
}