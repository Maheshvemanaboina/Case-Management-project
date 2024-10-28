trigger LSDProductsTrigger on LSD_Products_New__c (before insert,before update,after insert,after update,after delete) {
  // Calling the handler methods after insert and update will cause reccursion due to process builders.
    if(trigger.isBefore && trigger.isInsert){
        LSDProductHandler.addSelfLookupOnLSDProducts(trigger.new);
    }
    if(trigger.isBefore && trigger.isUpdate){
        LSDProductHandler.addSelfLookupOnLSDProducts(trigger.new);
    }
}