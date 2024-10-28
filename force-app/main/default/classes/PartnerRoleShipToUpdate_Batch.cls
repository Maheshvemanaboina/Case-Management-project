global without sharing class PartnerRoleShipToUpdate_Batch implements Database.Batchable<SObject>, Schedulable {

    // Cron expression to run at 4 45 AM every day //
    public static final String CRON_EXP = '0 45 4 ? * * *';

    //Execute for Schedulable class
    global void execute (SchedulableContext sc) {

        PartnerRoleShipToUpdate_Batch cls = new PartnerRoleShipToUpdate_Batch ();
        database.executebatch(cls, 100);
    }

    global Database.QueryLocator start(Database.BatchableContext bc){

        return Database.getQueryLocator([
            SELECT 
                Id, Sales_Area__c, Is_Recalculation_Required__c, Source_Account_Number__c, Target_Account_Number__c, Target_Account_Sales_Area__c, External_Key__c  
            FROM 
                Partner_Role__c 
            WHERE 
                Sales_Area__c != null 
            AND Source_Account__c != null 
            AND Target_Account__c != null 
            AND Is_Recalculation_Required__c = true]);
    }

    //Execute for Batch class
    global void execute(Database.BatchableContext bc, List<SObject> partnerRoleList){
        
        updateShipToforSoldTo(partnerRoleList);
    }

    global void finish(Database.BatchableContext bc){

        //Utilities.sendEmailOnBatchFinish(' KPI Creation for Partner Role ', bc);
    }


    global static void updateShipToforSoldTo(List<Partner_Role__c> partnerRoles){

        Set<Id> salesAreaIds = new Set<Id>();
        List<Partner_Role__c> partnerRolesToUpdate = new List<Partner_Role__c>();

        for(Partner_Role__c eachPartnerRole : partnerRoles){

            salesAreaIds.add(eachPartnerRole.Sales_Area__c);
        }
        
        Map<Id,Sales_Area__c> salesAreasMap = new Map<Id,Sales_Area__c>([SELECT Id, External_Key__c, Sales_Organization__c, DISTR_CHAN__c, DIVISION__c FROM Sales_Area__c WHERE Id IN: salesAreaIds]);

        for(Partner_Role__c eachPartRole : partnerRoles){

            if(eachPartRole.Is_Recalculation_Required__c){

                if(eachPartRole.Source_Account_Number__c == eachPartRole.Target_Account_Number__c){

                    eachPartRole.Target_Account_Sales_Area__c = eachPartRole.Sales_Area__c;
                }else {
                    
                    eachPartRole.Target_Account_Sales_Area__r = new Sales_Area__c( External_Key__c = getTargetSalesAreaExtKey(eachPartRole.Target_Account_Number__c, salesAreasMap.get(eachPartRole.Sales_Area__c)));
                }

                eachPartRole.Is_Recalculation_Required__c = false;
                partnerRolesToUpdate.add(eachPartRole);
            }
        }

        if(!partnerRolesToUpdate.isEmpty()){

            Schema.SObjectField extKey = Partner_Role__c.Fields.External_Key__c;
            
            //This code is to stop the future class that is getting called on partnerRole Trigger handler
            RecursionHandler.inFutureContext = true;
            
            List<Database.UpsertResult> upsResults = Database.upsert(partnerRolesToUpdate, extKey, false);
            //upsert partnerRolesToUpdate External_Key__c;

            List<Partner_Role__c> failedPartnerRoles = new List<Partner_Role__c>();
            for(Integer i = 0 ; i < upsResults.size() ; i++){

                if(!upsResults[i].isSuccess()){
                    failedPartnerRoles.add(new Partner_Role__c(
                        Id                              = partnerRolesToUpdate[i].Id,
                        Is_Recalculation_Required__c    = false
                    ));
                }
            }

            if(!failedPartnerRoles.isEmpty()){

                update failedPartnerRoles;
            }
        }
    }

    global static String getTargetSalesAreaExtKey(String targetAccontNo, Sales_Area__c sourceAccSalesArea){

        return targetAccontNo + '-' + sourceAccSalesArea.Sales_Organization__c + '-' + sourceAccSalesArea.DISTR_CHAN__c + '-' + sourceAccSalesArea.DIVISION__c;
    }
}