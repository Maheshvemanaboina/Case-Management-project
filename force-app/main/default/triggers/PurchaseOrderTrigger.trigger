trigger PurchaseOrderTrigger on Purchase_Order__c (after update) {

    if(trigger.isUpdate && trigger.isAfter && !RecursionHandler.isAfterPurchaseUpdate)
    {
        RecursionHandler.isAfterPurchaseUpdate = true;
        purchaseOrderHandler.CaseClosureLogic(Trigger.OldMap,Trigger.NewMap);
    }
    
}