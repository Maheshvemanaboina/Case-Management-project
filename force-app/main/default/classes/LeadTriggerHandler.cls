public with sharing class LeadTriggerHandler extends TriggerHandler {
    
    public override void processAfterUpdate(){
        
        if(!RecursionHandler.isLeadTrigAfterUpdateRecursive){            
            RecursionHandler.isLeadTrigAfterUpdateRecursive = true;
            //LeadSharingUtility.recalculateLeadSharingOnUpdate((List<Lead>)trigger.new);
            //UpdateLeadOwner.populateLeadOwner((List<Lead>)trigger.new);
        }
    }
    
     public override void processAfterInsert(){
         //LeadSharingUtility.recalculateLeadSharingOnInsert((List<Lead>)trigger.new);
     }
    
}