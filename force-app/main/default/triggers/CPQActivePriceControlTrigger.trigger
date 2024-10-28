/*
* @Author : Shiva Karna 
* @Date : 28-July 2021
* @Desc : CPQActivePriceControlTrigger trigger
* @Jira : SCPQ-1055
*/
trigger CPQActivePriceControlTrigger on CPQ_Active_Price_Model__c (before insert,before update) {
 CPQActivePriceControlTriggerHandler handler = new CPQActivePriceControlTriggerHandler();    
    if(Trigger.isInsert){
        if(Trigger.isBefore){
           //called triggerhandler beforeinsert method
            handler.OnBeforeInsert(trigger.New);
        }
    }else if (Trigger.isUpdate){
        if(Trigger.isBefore){
        //called triggerhandler beforeupdate method
         handler.OnBeforeUpdate(trigger.New ,trigger.Old,Trigger.NewMap,Trigger.OldMap);
        }
    }
}