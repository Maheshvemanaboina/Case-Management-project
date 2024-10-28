/***************************************************************************************************
* Class Name   : BatchToAddLookupOnLSDProductGroup
* Created Date : August 6, 2020
* Author       : Sheshadri Pattar Srinivas
* Description  : Class to tag the LSD Product(Product Mirror) for existing LSD Product Group Records
****************************************************************************************************/
global without sharing class BatchToAddLookupOnLSDProductGroup implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query='SELECT Id,Product_Group__c,LSD_Product__c FROM LSD_Product__c WHERE Product_Group__c != NULL';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<SObject> records){
       List<LSD_Product__c> lsdProductGroupList = (List<LSD_Product__c>)records;
       set<Id> productIdSet = new set<Id>();
        for(LSD_Product__c lsdProductGroup : lsdProductGroupList){
            if(lsdProductGroup.Product_Group__c != null){
                productIdSet.add(lsdProductGroup.Product_Group__c);
            }
        }
        List<LSD_Products_New__c> lsdProductList = [SELECT Id,Parent_Product__c FROM LSD_Products_New__c WHERE Parent_Product__c IN : productIdSet];
        Map<Id,Id> productWithLsdProductsMap = new Map<Id,Id>();
        for(LSD_Products_New__c lsdProd : lsdProductList){
            if(lsdProd.Parent_Product__c != null){
                productWithLsdProductsMap.put(lsdProd.Parent_Product__c , lsdProd.Id);
            }
        }
        for(LSD_Product__c lsdProductGroup : lsdProductGroupList){
            if(lsdProductGroup.Product_Group__c != null && productWithLsdProductsMap.containskey(lsdProductGroup.Product_Group__c)){
                lsdProductGroup.LSD_Product__c = productWithLsdProductsMap.get(lsdProductGroup.Product_Group__c);
            }
        }
        
        if(lsdProductGroupList.size() > 0){
            update lsdProductGroupList;
        }
    }    
    global void finish(Database.BatchableContext bc){
        system.debug('finish');
    }    
    
}