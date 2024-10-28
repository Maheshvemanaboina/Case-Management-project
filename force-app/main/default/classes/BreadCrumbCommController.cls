public without sharing class BreadCrumbCommController {
    public BreadCrumbCommController() {

    }

@AuraEnabled
public static string fetchRecId(String caseNum){

//String likeName = (recName.substring(0,2)+'-'+recName.substring(2)).toUpperCase();
//System.debug('likeName:: '+likeName);
String retValue='';
if(caseNum !=NULL){
   retValue = [SELECT Id,caseNumber FROM Case WHERE caseNumber =:caseNum][0].Id;
}
return retValue;
}


@AuraEnabled
public static string fetchGenRecId(String objName , String recName, String loc){
    String retValue='';
    system.debug('loc'+loc);
       if(recName !=NULL && objName !=NULL && loc!=NULL)
      {
        String query1 ='SELECT Id,NAME,Distributor_Location__c FROM ' +objName+' WHERE NAME='+'\''+recName+'\' AND Distributor_Location__c='+'\''+loc+'\'';
          System.debug('query:: '+query1);
      System.debug('queryres:: '+Database.query(query1));
      retValue = (Database.query(query1))[0].Id;
      }
         
  if(recName !=NULL && objName !=NULL && String.isBlank(loc)){
      String query ='SELECT ID,NAME  FROM ' +objName+' WHERE NAME='+'\''+recName+'\'';
      
      System.debug('query:: '+query);
      System.debug('queryres:: '+Database.query(query));
      retValue = (Database.query(query))[0].Id;
  }
     
    
  return retValue; 
}

   /* @AuraEnabled
    public static string fetchBusinessStrategyName(String fieldOfPlayName){
        System.debug('fieldOfPlayName:: '+fieldOfPlayName);
        String likeName = (fieldOfPlayName.substring(0,2)+'-'+fieldOfPlayName.substring(2)).toUpperCase();
        System.debug('likeName:: '+likeName);
        String retValue='';
        if(likeName !=NULL){
           retValue = [SELECT Id,Name,Distributor_Business_Strategy__r.Name FROM Field_of_Play__c WHERE Name =:likeName][0].Distributor_Business_Strategy__r.Name;
        }
        return retValue;
    }
    @AuraEnabled
    public static string fetchDistSalesFunnelName(String dSalesName){
        String nameVal = dSalesName.length() >2 ?dSalesName.substring(0,2).toUpperCase()+dSalesName.substring(2) :'';
        String finNameVal='';
        String retValue='';
        if(nameVal.contains('-') && nameVal.indexOf('-') !=nameVal.length()-1){
            finNameVal = nameVal.substring(0,nameVal.indexOf('-'))+' '+nameVal.substring(nameVal.indexOf('-'),nameVal.indexOf('-')+1) +' '+nameVal.substring(nameVal.indexOf('-')+1);
        }
        System.debug('nameVal Sales funnel:: '+nameVal +'finNameVal sales funnel:: '+finNameVal);
        if(finNameVal !=''){
           retValue = [SELECT Id,Sales_Funnel__r.Name FROM Distributor_Sales_To_End_Customer__c WHERE Name =: finNameVal ][0].Sales_Funnel__r.Name;
        }
        return retValue;
    }
    @AuraEnabled
    public static string getlocStckForcstName(String locStockName){
        String nameVal = locStockName.substring(0,locStockName.indexOf('-')).toUpperCase()+' '+locStockName.substring(locStockName.indexOf('-'),locStockName.indexOf('-')+1) +' '+locStockName.substring(locStockName.indexOf('-')+1);
        String finNameVal = nameVal.replace('-',':');
        System.debug('nameVal:: '+nameVal +'finNameVal:: '+finNameVal);
        String retValue='';
        if(finNameVal !=NULL){
           retValue = [SELECT Id, Forecast__r.Name FROM Local_Stock__c WHERE Name =: finNameVal][0].Forecast__r.Name;
        }
        return retValue;
    }*/
}