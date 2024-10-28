/***************************************************************************************************
* Class Name   : LSDProductHandler
* Created Date : August 7, 2020
* Author       : Sheshadri Pattar Srinivas
* Description  : Class to Populate the self Lookup fields on LSD Product Records
****************************************************************************************************/
public without sharing class LSDProductHandler {
    public static void addSelfLookupOnLSDProducts(List<LSD_Products_New__c> newList){
        set<Id> parentProductIdSet = new set<Id>();
        for(LSD_Products_New__c lsdPro : newList){
            if(lsdPro.Parent_Product__c != null){
                parentProductIdSet.add(lsdPro.Parent_Product__c);
            }
        }
        Map<Id,Product2> ProductMap = new Map<Id,Product2>([SELECT Id,FCI_matching_product__c,Product_Group_Lookup__c FROM Product2 WHERE Id IN : parentProductIdSet]);
        set<Id> fciMatchingProductIdSet = new set<Id>();
        set<Id> productGroupIdSet = new set<Id>();
        for(Product2 prod : ProductMap.values()){
            if(prod.FCI_matching_product__c != null){
                fciMatchingProductIdSet.add(prod.FCI_matching_product__c);
            }
            if(prod.Product_Group_Lookup__c != null){
                productGroupIdSet.add(prod.Product_Group_Lookup__c);
            }
        }
        List<LSD_Products_New__c> fciMatchingLSDProductList = [SELECT Id,Parent_Product__c FROM LSD_Products_New__c WHERE Parent_Product__c IN : fciMatchingProductIdSet];
        List<LSD_Products_New__c> productGroupLSDProductList = [SELECT Id,Parent_Product__c FROM LSD_Products_New__c WHERE Parent_Product__c IN : productGroupIdSet];
        
        Map<Id,Id> fciMatchingProductMap = new Map<Id,Id>();
        Map<Id,Id> productGroupMap = new Map<Id,Id>();
        
        for(LSD_Products_New__c lsdPro : fciMatchingLSDProductList){
            fciMatchingProductMap.put(lsdPro.Parent_Product__c,lsdPro.Id);
        }
        for(LSD_Products_New__c lsdPro : productGroupLSDProductList){
            productGroupMap.put(lsdPro.Parent_Product__c,lsdPro.Id);
        }
        
         for(LSD_Products_New__c lsdPro : newList){
            if(lsdPro.Parent_Product__c != null && ProductMap.containskey(lsdPro.Parent_Product__c) && ProductMap.get(lsdPro.Parent_Product__c).FCI_matching_product__c!=null && fciMatchingProductMap.containskey(ProductMap.get(lsdPro.Parent_Product__c).FCI_matching_product__c)){
                lsdPro.FCI_matching_product__c = fciMatchingProductMap.get(ProductMap.get(lsdPro.Parent_Product__c).FCI_matching_product__c);
            }
             if(lsdPro.Parent_Product__c != null && ProductMap.containskey(lsdPro.Parent_Product__c) && ProductMap.get(lsdPro.Parent_Product__c).Product_Group_Lookup__c!=null && productGroupMap.containskey(ProductMap.get(lsdPro.Parent_Product__c).Product_Group_Lookup__c)){
                 lsdPro.Product_Group__c = productGroupMap.get(ProductMap.get(lsdPro.Parent_Product__c).Product_Group_Lookup__c);
             }
        }
        
    }
}