trigger OrderItemTrigger on OrderItem (before insert,after insert,after update) {

        if(trigger.isBefore && trigger.isInsert)
            OrderItemTriggerHandler.beforeInsertHandler(trigger.new); 
    
    	if(trigger.isAfter && trigger.isInsert)
            OrderItemTriggerHandler.afterInsertHandler(trigger.new);
    
       if(trigger.isAfter && trigger.isUpdate)
            OrderItemTriggerHandler.afterUpdateHandler(trigger.new,trigger.oldMap);
    
}