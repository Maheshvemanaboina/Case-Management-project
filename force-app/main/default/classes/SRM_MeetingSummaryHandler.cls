public without sharing class SRM_MeetingSummaryHandler {
    public static void updateAccountToShareWith(List<Meeting_Notes__c> newNotes, Map<id, Meeting_Notes__c> oldMap){
        set<Id> supplierIds = new set<Id>();
        Map<Id, Supplier_Hub__c> relatedSuppliers = new Map<Id, Supplier_Hub__c>();
        for(Meeting_Notes__c obj: newNotes){
            if(obj.Supplier_Hub_Number__c != NULL){
                supplierIds.add(obj.Supplier_Hub_Number__c);
            }
        }
        if(supplierIds != null){
            relatedSuppliers= getRelatedSuppliers(supplierIds);
        }
        if(! relatedSuppliers.isEmpty()){
            for(Meeting_Notes__c obj: newNotes){
                if(relatedSuppliers.get(obj.Supplier_Hub_Number__c) != NULL && obj.Type__c == 'External'){
                    obj.Account_to_share_with__c = relatedSuppliers.get(obj.Supplier_Hub_Number__c).Supplier_Account__c;
                }
                if(trigger.isBefore && trigger.isUpdate){
                    if(oldMap.get(obj.Id).Type__c != obj.Type__c && obj.Type__c == 'Internal'){
                        obj.Account_to_share_with__c = null;
                    }
                }
            }
        }
    }
    private static Map<Id, Supplier_Hub__c> getRelatedSuppliers(set<Id> supplierIds){
        return new Map<Id, Supplier_Hub__c>([SELECT Id, Supplier_Account__c FROM Supplier_Hub__c WHERE Id IN: supplierIds]);
    }
}