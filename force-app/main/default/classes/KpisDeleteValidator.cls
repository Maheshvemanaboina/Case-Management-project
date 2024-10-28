public without sharing class KpisDeleteValidator {
  private static final String errMessage = 'You cannot delete KPI records if the KPI is Approved/Pending with FCI Sales Manager';
  
  public static Boolean conditionCheck(String Status,ID ownerId){
      User currentUser = UserUtility.getCurrentUser();
      if(Status == 'Pending' || Status == 'Yes'){
        if( currentUser.Profile.Name == 'System Administrator' ||  currentUser.Id == ownerId){
          return false;
        }else{
          return true;
        }      
      }
      else{
        return false;
      }      
  }

  private static Map<Id,RecordType> fetchRecordTypeIds(set<ID> recordIDs){
    Map<Id,RecordType> recordTypeIds = new Map<Id,RecordType>();
    for(RecordType eachRecType : [SELECT Id,Name,DeveloperName FROM RecordType WHERE ID IN: recordIDs ]){
      recordTypeIds.put(eachRecType.Id,eachRecType);
    }
    return recordTypeIds;
  }
  
  public static void validateForecastAccuracy(List<Forecast_Accuracy__c> kpiRecords) {     
        set<Id> localStockParentIds = new set<Id>();
        Map<Id,Forecast_Accuracy__c> forecastAccuracyMap = new Map<Id,Forecast_Accuracy__c>();
        for( Forecast_Accuracy__c fa : kpiRecords){ 
          localStockParentIds.add(fa.Forecast_Accuracy_Local_Stock__c);
          forecastAccuracyMap.put(fa.RecordTypeId,fa);
        }
        Map<Id,RecordType> faRecordTypeMap = fetchRecordTypeIds(forecastAccuracyMap.keySet());
        Map<Id,Forecast_Accuracy__c> localStockParentRecs = new Map<Id,Forecast_Accuracy__c>([SELECT Id,Name,Confirmed_by_FCI_Sales_Manager__c,OwnerId FROM Forecast_Accuracy__c WHERE Id IN : localStockParentIds]);
        for(Forecast_Accuracy__c rec : forecastAccuracyMap.values()){
          if((faRecordTypeMap.get(rec.RecordTypeId)).DeveloperName == 'Local_Stock'){
            Forecast_Accuracy__c faRecord = localStockParentRecs.get(rec.Forecast_Accuracy_Local_Stock__c);
            if(conditionCheck(rec.Confirmed_by_FCI_Sales_Manager__c,faRecord.OwnerId)){
              rec.addError(errMessage);
            }            
          }
        }     
    }

  public static void validateSalesPerformance(List< Sales_Funnel__c> kpiRecords) {     
    set<Id> salesPerformanceParentIds = new set<Id>();
    Map<Id,Sales_Funnel__c> SalesPerformanceMap = new Map<Id,Sales_Funnel__c>();
    for( Sales_Funnel__c sf : kpiRecords){  
      salesPerformanceParentIds.add(sf.Sales_Funnel_Sales_To_End_Customer__c);
      SalesPerformanceMap.put(sf.RecordTypeId,sf);
    }
    Map<Id,RecordType> saRecordTypeMap =fetchRecordTypeIds(SalesPerformanceMap.keySet());
    Map<Id,Sales_Funnel__c> localStockParentRecs = new Map<Id,Sales_Funnel__c>([SELECT Id,Name,Confirmed_by_FCI_Sales_Manager__c,OwnerId FROM Sales_Funnel__c WHERE Id IN : salesPerformanceParentIds]);
    for(Sales_Funnel__c rec : SalesPerformanceMap.values()){
      if((saRecordTypeMap.get(rec.RecordTypeId)).DeveloperName == 'Distributor_Sales_To_End_Customer'){
         Sales_Funnel__c sfRecord = localStockParentRecs.get(rec.Sales_Funnel_Sales_To_End_Customer__c);
         if(conditionCheck(rec.Confirmed_by_FCI_Sales_Manager__c,sfRecord.OwnerId)){
          rec.addError(errMessage);
        } 
      }
    }     
  }

  public static void validateCustomerSupport(List<FCI_Customer_Support__c> kpiRecords) {     
    set<Id> csParentIds = new set<Id>();
    Map<Id,FCI_Customer_Support__c> customerSupportMap = new Map<Id,FCI_Customer_Support__c>();
    for( FCI_Customer_Support__c cs : kpiRecords){  
      csParentIds.add(cs.FCI_Customer_Support_Order_Process__c);
      customerSupportMap.put(cs.RecordTypeId,cs);
    }
    Map<Id,RecordType> csRecordTypeMap =fetchRecordTypeIds(customerSupportMap.keySet());
    Map<Id,FCI_Customer_Support__c> csStockParentRecs = new Map<Id,FCI_Customer_Support__c>([SELECT Id,Name,Confirmed_by_FCI_Sales_Manager__c,OwnerId FROM FCI_Customer_Support__c WHERE Id IN : csParentIds]);
    for(FCI_Customer_Support__c rec : customerSupportMap.values()){
      if((csRecordTypeMap.get(rec.RecordTypeId)).DeveloperName == 'Order_Process'){
        FCI_Customer_Support__c csRecord = csStockParentRecs.get(rec.FCI_Customer_Support_Order_Process__c);
        system.debug('csRecord  '+csRecord);
        if(conditionCheck(rec.Confirmed_by_FCI_Sales_Manager__c,csRecord.OwnerId)){
          rec.addError(errMessage);
        }            
      }
    }     
  }
  
  public static void validateCommercialActivity(List<Commercial_Activity__c> kpiRecords) {     
    set<Id> caParentIds = new set<Id>();
    Map<Id,Commercial_Activity__c> commercialActivityMap = new Map<Id,Commercial_Activity__c>();
    for( Commercial_Activity__c ca : kpiRecords){   
      caParentIds.add(ca.Commercial_Activity_Promotion_Activity__c);
      caParentIds.add(ca.Commercial_Activity_Customer_Visit__c);
      caParentIds.add(ca.Commercial_Activity_Sample__c);
      commercialActivityMap.put(ca.RecordTypeId,ca);
    }
    Map<Id,RecordType> caRecordTypeMap = fetchRecordTypeIds(commercialActivityMap.keySet());
    Map<Id,Commercial_Activity__c> caParentRecs = new Map<Id,Commercial_Activity__c>([SELECT Id,Name,Confirmed_by_FCI_Sales_Manager__c,OwnerId FROM Commercial_Activity__c WHERE Id IN : caParentIds]);
    for(Commercial_Activity__c rec : commercialActivityMap.values()){
      if((caRecordTypeMap.get(rec.RecordTypeId))?.DeveloperName == 'Promotion_Activity'){
        Commercial_Activity__c caRecord = caParentRecs.get(rec.Commercial_Activity_Promotion_Activity__c);
        if(conditionCheck(rec.Confirmed_by_FCI_Sales_Manager__c,caRecord.OwnerId)){
          rec.addError(errMessage);
        }            
      }
      if((caRecordTypeMap.get(rec.RecordTypeId))?.DeveloperName == 'Customer_Visit'){
        Commercial_Activity__c caRecord = caParentRecs.get(rec.Commercial_Activity_Customer_Visit__c);
        if(conditionCheck(rec.Confirmed_by_FCI_Sales_Manager__c,caRecord.OwnerId)){
          rec.addError(errMessage);
        }            
      }
      if((caRecordTypeMap.get(rec.RecordTypeId))?.DeveloperName == 'Samples'){
        Commercial_Activity__c caRecord = caParentRecs.get(rec.Commercial_Activity_Sample__c);
        if(conditionCheck(rec.Confirmed_by_FCI_Sales_Manager__c,caRecord.OwnerId)){
          rec.addError(errMessage);
        }            
      }
    }     
  }

  public static void validateBusinessStrategy(List<Business_Strategy__c> kpiRecords) {     
    set<Id> bsParentIds = new set<Id>();
    Map<Id,Business_Strategy__c> BusinessStrategyMap = new Map<Id,Business_Strategy__c>();
    for( Business_Strategy__c bs : kpiRecords){ 
      bsParentIds.add(bs.Business_Strategy_Competition__c);
      bsParentIds.add(bs.Business_Strategy_High_Low_Lights__c);
      BusinessStrategyMap.put(bs.RecordTypeId,bs);
    }
    Map<Id,RecordType> bsRecordTypeMap = fetchRecordTypeIds(BusinessStrategyMap.keySet());
    Map<Id,Business_Strategy__c> caParentRecs = new Map<Id,Business_Strategy__c>([SELECT Id,Name,Confirmed_by_FCI_Sales_Manager__c,OwnerId FROM Business_Strategy__c WHERE Id IN : bsParentIds]);
    for(Business_Strategy__c rec : BusinessStrategyMap.values()){
      if((bsRecordTypeMap.get(rec.RecordTypeId))?.DeveloperName == 'Competition'){
        Business_Strategy__c bsRecord = caParentRecs.get(rec.Business_Strategy_Competition__c);
        if(conditionCheck(rec.Confirmed_by_FCI_Sales_Manager__c,bsRecord.OwnerId)){
          rec.addError(errMessage);
        }            
      }
      if((bsRecordTypeMap.get(rec.RecordTypeId))?.DeveloperName == 'High_Low_Lights'){
        Business_Strategy__c bsRecord = caParentRecs.get(rec.Business_Strategy_High_Low_Lights__c);
        if(conditionCheck(rec.Confirmed_by_FCI_Sales_Manager__c,bsRecord.OwnerId)){
          rec.addError(errMessage);
        }            
      }
    }     
  }

}