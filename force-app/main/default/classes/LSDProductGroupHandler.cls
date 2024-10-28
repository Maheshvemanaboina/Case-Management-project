/**************************************************************************************************************************
* Class Name   : LSDProductGroupHandler
* Created Date : August 10, 2020
* Author       : Sheshadri Pattar Srinivas
* Description  : Class to add tag product/LSD Product(Product Mirror) when a LSD Product Group Record is created or Updated
***************************************************************************************************************************/
public without sharing class LSDProductGroupHandler {
    
    public static void addLookupOnLSDProductGroupBeforeInsert(List<LSD_Product__c> newList){
        set<Id> productIdSet = new set<Id>();
        set<Id> lsdProductIdSet = new set<Id>();
        for(LSD_Product__c lsdProGroup : newList){
            if(lsdProGroup.Product_Group__c != null){
                productIdSet.add(lsdProGroup.Product_Group__c);
            }
            if(lsdProGroup.LSD_Product__c != null){
                lsdProductIdSet.add(lsdProGroup.LSD_Product__c);
            }
        }
        Map<Id,LSD_Products_New__c> lsdProductMap = new Map<Id,LSD_Products_New__c>([SELECT Id,Parent_Product__c FROM LSD_Products_New__c WHERE Id IN: lsdProductIdSet OR Parent_Product__c  IN : productIdSet]);
        Map<Id,Id> productLSDProductMap = new Map<Id,Id>();
        for(LSD_Products_New__c lsdPro : lsdProductMap.values()){
            if(lsdPro.Parent_Product__c != null){
                productLSDProductMap.put(lsdPro.Parent_Product__c,lsdPro.Id);
            }
        }
        for(LSD_Product__c lsdProGroup : newList){
            if(lsdProGroup.Product_Group__c != null && productLSDProductMap.containskey(lsdProGroup.Product_Group__c) && lsdProGroup.LSD_Product__c == null){
                lsdProGroup.LSD_Product__c = productLSDProductMap.get(lsdProGroup.Product_Group__c);
            }
            if(lsdProGroup.Product_Group__c == null && lsdProGroup.LSD_Product__c != null && lsdProductMap.containskey(lsdProGroup.LSD_Product__c) && lsdProductMap.get(lsdProGroup.LSD_Product__c).Parent_Product__c != null){
                lsdProGroup.Product_Group__c = lsdProductMap.get(lsdProGroup.LSD_Product__c).Parent_Product__c;
            }
        }
    }
    
    public static void addLookupOnLSDProductGroupBeforeUpdate(Map<Id,LSD_Product__c> oldMap , Map<Id,LSD_Product__c> newMap){
        set<Id> productIdSet = new set<Id>();
        set<Id> lsdProductIdSet = new set<Id>();
        for(LSD_Product__c lsdProGroup : newMap.values()){
            if(lsdProGroup.Product_Group__c != null && lsdProGroup.Product_Group__c != oldMap.get(lsdProGroup.Id).Product_Group__c){
                productIdSet.add(lsdProGroup.Product_Group__c);
            }
            if(lsdProGroup.LSD_Product__c != null && lsdProGroup.LSD_Product__c != oldMap.get(lsdProGroup.Id).LSD_Product__c){
                lsdProductIdSet.add(lsdProGroup.LSD_Product__c);
            }
        }
        system.debug('productIdSet '+productIdSet);
        system.debug('lsdProductIdSet '+lsdProductIdSet);
        Map<Id,LSD_Products_New__c> lsdProductMap = new Map<Id,LSD_Products_New__c>([SELECT Id,Parent_Product__c FROM LSD_Products_New__c WHERE Id IN: lsdProductIdSet OR Parent_Product__c  IN : productIdSet]);
        Map<Id,Id> productLSDProductMap = new Map<Id,Id>();
        for(LSD_Products_New__c lsdPro : lsdProductMap.values()){
            if(lsdPro.Parent_Product__c != null){
                productLSDProductMap.put(lsdPro.Parent_Product__c,lsdPro.Id);
            }
        }
        for(LSD_Product__c lsdProGroup : newMap.values()){
            if(lsdProGroup.Product_Group__c != null && productLSDProductMap.containskey(lsdProGroup.Product_Group__c)){
                lsdProGroup.LSD_Product__c = productLSDProductMap.get(lsdProGroup.Product_Group__c);
            }
            if(lsdProGroup.LSD_Product__c != null && lsdProductMap.containskey(lsdProGroup.LSD_Product__c) && lsdProductMap.get(lsdProGroup.LSD_Product__c).Parent_Product__c != null){
                lsdProGroup.Product_Group__c = lsdProductMap.get(lsdProGroup.LSD_Product__c).Parent_Product__c;
            }
        }
    }
}