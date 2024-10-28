/*
* @Author : Shiva Karna 
* @Date : 28-July 2021
* @Desc : This handler class was called on CPQActivePriceControlTrigger and it will execute methods based on trigger
          Events.
* @Jira : SCPQ-1055
*/

public without sharing class CPQActivePriceControlTriggerHandler {
  //update sold to and product material id's
  public void updateSoldToAndProductId(List<CPQ_Active_Price_Model__c> activePriceControllst){
      List<string> SAPNumber = new List<string>();
      List<string> ProductNumber = new List<string>();
      List<account> accList = new List<account>();
      List<product2> prodList = new List<product2>();
      for(CPQ_Active_Price_Model__c APC:activePriceControllst){
          if(APC.SAP_Number_Upload__c!=null){
            SAPNumber.add(APC.SAP_Number_Upload__c);
          }
          if(APC.Material_Number_Upload__c!=null){
           ProductNumber.add(APC.Material_Number_Upload__c);
          }
        }
      
      if(SAPNumber.size()>0){
        accList = [Select id,SAP_Number_PE1__c from account where SAP_Number__c in:SAPNumber];
      }
      if(ProductNumber.size()>0){
        prodList = [Select id,Product_Code__c from product2 where Product_Code__c in:ProductNumber];
      }
      Map<string,Account> accMap = new Map<string,account>();
      Map<string,product2> prodMap = new Map<string,product2>();
      for(account acc:accList){
          accMap.put(acc.SAP_Number_PE1__c,acc);
      }
      for(product2 prod:prodList){
          prodMap.put(prod.Product_Code__c,prod);
      }
      for(CPQ_Active_Price_Model__c APC:activePriceControllst){
          if(prodMap.containsKey(APC.Material_Number_Upload__c)){
              //assign product material id based on Product Code
            APC.Material_Numbers__c= prodMap.get(APC.Material_Number_Upload__c).id;
          }
          if(accMap.containsKey(APC.SAP_Number_Upload__c)){
              //assign account id based on SAP Number
            APC.SAP_Numbers__c= accMap.get(APC.SAP_Number_Upload__c).id;
          }
        } 
  }
    public void OnBeforeInsert(List<CPQ_Active_Price_Model__c> activePriceControllst){  
        //update sold to , product material lookup fields
        updateSoldToAndProductId(activePriceControllst);        
    }
    public void OnBeforeUpdate(List<CPQ_Active_Price_Model__c> activePriceControllst, 
                                   List<CPQ_Active_Price_Model__c> oldactivePriceControllst,
                                   Map<ID, CPQ_Active_Price_Model__c> newactivePriceControlMap ,
                                   Map<ID,CPQ_Active_Price_Model__c> oldactivePriceControlMap ){
        //update sold to , product material lookup fields
        updateSoldToAndProductId(activePriceControllst);        
    }
    
}