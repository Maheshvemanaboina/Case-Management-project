/***************************************************************************************************
* Class Name   : BatchToAddSelfLookUpOnLSDProduct
* Created Date : August 6, 2020
* Author       : Sheshadri Pattar Srinivas
* Description  : Class to create Populate the self Lookup fields on LSD Product Records
****************************************************************************************************/
global without sharing class BatchToAddSelfLookUpOnLSDProduct implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query='SELECT Id,Parent_Product__c,FCI_matching_product__c,Product_Group__c FROM LSD_Products_New__c WHERE Parent_Product__c!=null';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<SObject> records){
        List<LSD_Products_New__c> lsdProductList = (List<LSD_Products_New__c>)records;
        set<Id> productIdset = new set<Id>();
        for(LSD_Products_New__c lsdPro : lsdProductList){
            productIdset.add(lsdPro.Parent_Product__c);
        }
        Map<Id,Product2> productMap = new Map<Id,Product2>([SELECT Id,FCI_matching_product__c,Product_Group_Lookup__c FROM Product2 WHERE Id IN : productIdset]);
        set<Id> matchingProductIdSet = new set<Id>();
        set<Id> productGroupIdSet = new set<Id>();
        for(Product2 pro : productMap.values()){
            if(pro.FCI_matching_product__c != null){
                matchingProductIdSet.add(pro.FCI_matching_product__c);
            }
            if(pro.Product_Group_Lookup__c != null){
                productGroupIdSet.add(pro.Product_Group_Lookup__c);
            }
        }
        List<LSD_Products_New__c> lsdProductListForMatchingProduct = [SELECT Id,Parent_Product__c FROM LSD_Products_New__c WHERE Parent_Product__c IN : matchingProductIdSet];
        List<LSD_Products_New__c> lsdProductListForProductGroup = [SELECT Id,Parent_Product__c FROM LSD_Products_New__c WHERE Parent_Product__c IN : productGroupIdSet];
        Map<Id,Id> matchingProductMap = new Map<Id,Id>();
        Map<Id,Id> productGroupMap = new Map<Id,Id>();
        for(LSD_Products_New__c lsdPro : lsdProductListForMatchingProduct){
            matchingProductMap.put(lsdPro.Parent_Product__c,lsdPro.Id);
        }
        for(LSD_Products_New__c lsdPro : lsdProductListForProductGroup){
            productGroupMap.put(lsdPro.Parent_Product__c,lsdPro.Id);
        }
        for(LSD_Products_New__c lsdPro : lsdProductList){
            if(productMap.containskey(lsdPro.Parent_Product__c) && productMap.get(lsdPro.Parent_Product__c).FCI_matching_product__c!=null && matchingProductMap.containskey(productMap.get(lsdPro.Parent_Product__c).FCI_matching_product__c)){
                lsdPro.FCI_matching_product__c = matchingProductMap.get(productMap.get(lsdPro.Parent_Product__c).FCI_matching_product__c);
            }
        }
        for(LSD_Products_New__c lsdPro : lsdProductList){
            if(productMap.containskey(lsdPro.Parent_Product__c) && productMap.get(lsdPro.Parent_Product__c).Product_Group_Lookup__c!=null && productGroupMap.containskey(productMap.get(lsdPro.Parent_Product__c).Product_Group_Lookup__c)){
                lsdPro.Product_Group__c = productGroupMap.get(productMap.get(lsdPro.Parent_Product__c).Product_Group_Lookup__c);
            }
        }
        if(lsdProductList.size()>0){
            update lsdProductList;
        }
    }    
    global void finish(Database.BatchableContext bc){
        system.debug('finish');
    }    
    
}