public without sharing class AccountRegionUpdateHandler {
    public static void  getCountrySetting(List<Account> acclist){
        
        List<String> newlist = new List<String>();
        Map<List<String>,String> maplist = new Map<List<String>,String>();
        String commercialCustomerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Commercial_Customer').getRecordTypeId();
        String srmAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('SRM_Account').getRecordTypeId();
        
        for(Account_Region_CountryCode_Mapping__mdt  cms :[Select DeveloperName,MasterLabel,CountryCodes_del__c,Region_del_del__c from Account_Region_CountryCode_Mapping__mdt  where Region_del_del__c!=null ]){
            maplist.put(cms.CountryCodes_del__c.split(','),cms.Region_del_del__c);
        }
        
        for(Account acc : acclist){
            if(acc.BillingCountryCode==null|| acc.Sales_Region__c!=null){
                acc.Active__c = true;
            }
            else if(!acc.RecordTypeId.equals(commercialCustomerRecordTypeId) && !acc.RecordTypeId.equals(srmAccountRecordTypeId)){
                
                for(List<String> countrycodes : maplist.Keyset()){
                    if(countrycodes.contains(acc.billingCountryCode)){
                        String region = maplist.get(countrycodes);
                        acc.sales_region__c = region;
                    }
                }
            }
        }
    }
}