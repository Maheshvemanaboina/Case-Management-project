trigger InvoiceLineItemTrigger on Invoice_Line_Item__c (after insert) {
         
    if(trigger.isInsert && trigger.isAfter)
         InvoiceLineItemTriggerHandler.afterInsertHandler(trigger.new);        
    
}