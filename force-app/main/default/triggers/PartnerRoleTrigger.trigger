trigger PartnerRoleTrigger on Partner_Role__c (after insert,after update) {
    
    //check user has custom permission - enabled only for SAP PO User   
    if(Test.isRunningTest() || FeatureManagement.checkPermission('PartnerRole_Trigger_Access')){
        PartnerRoleTriggerHandler trig = new PartnerRoleTriggerHandler();
        trig.process();
    }    
}