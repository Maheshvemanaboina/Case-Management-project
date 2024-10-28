/*
* @Author : Shiva Karna 
* @Date : 20-July 2021
* @Desc : QuotelineItem trigger
* @Jira : SCPQ-1055
*/
trigger QuoteLineItemTrigger on SBQQ__QuoteLine__c (after insert, after update, before insert, before update, before delete){

    QuoteLineItemTriggerHandler handler = new QuoteLineItemTriggerHandler();    
    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
           //called triggerhandler beforeinsert method
            handler.OnBeforeInsert(trigger.New);
        } else {
            //called triggerhandler afterinsert method
            handler.OnAfterInsert(trigger.New);
        }
    } else if (Trigger.isUpdate) {
        if (Trigger.isBefore) {
        //called triggerhandler beforeupdate method
         handler.OnBeforeUpdate(trigger.New ,trigger.Old,Trigger.NewMap,Trigger.OldMap);
        } else {
        //called triggerhandler afterupdate method
         handler.OnAfterUpdate(trigger.New ,trigger.Old,Trigger.NewMap,Trigger.OldMap);
        }
    } else if (Trigger.isDelete) {
        if (Trigger.isBefore) {
            //called triggerhandler beforedelete method
            handler.OnBeforeDelete(trigger.Old);
        } else {
            // nothing
        }
    }
 }