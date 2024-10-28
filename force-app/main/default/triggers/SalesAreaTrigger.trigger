/***************************************************
 * 11-Dec-2020: AS: Commented cause the logic is no longer required.
 ***************************************************/

trigger SalesAreaTrigger on Sales_Area__c (after insert,after update,after delete) {
    
    /*if(trigger.isInsert && trigger.isAfter)
        SalesAreaTriggerHandler.afterInsertHandler(trigger.new);
    
    if(trigger.isUpdate && trigger.isAfter)
        SalesAreaTriggerHandler.afterUpdateHanlder(trigger.new, trigger.oldMap);
        
    if(trigger.isDelete && trigger.isAfter)
        SalesAreaTriggerHandler.afterDeleteHandler(trigger.old);
*/
    SalesAreaTriggerHandler trig = new SalesAreaTriggerHandler();
    trig.process();
}