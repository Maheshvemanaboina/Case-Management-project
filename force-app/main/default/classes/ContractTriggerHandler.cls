/******************************
* Written By : Rekha
* Purpose : To add owner,recordtype,contract term whenever an contract is getting created from SAP * 
* Updated By: Carlo Volpi on 02/02/2020
* Purpose : Adjusted to use TriggerHandler pattern *
* ****************************/
public without sharing class ContractTriggerHandler  extends TriggerHandler {

    public override void processBeforeInsert(){
        
        list<contract> newList = (list<contract>) trigger.new;
        set<string> sapEmployeeNumberSet = new set<string>();       
        map<string,id> userIdMap = new map<string,id>();

        for(Contract obj : newList){

        

            if(obj.Contract_Owner__c!=NULL)
                sapEmployeeNumberSet.add(obj.Contract_Owner__c);   
            
            if(obj.Sales_Assistant_User__c!=NULL)
                sapEmployeeNumberSet.add(obj.Sales_Assistant_User__c);
        }

        Id BGIContractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('BGI_Contract').getRecordTypeId();

        if(sapEmployeeNumberSet.size()>0){
            for(user uObj : [SELECT id,SAP_Employee_Id__c FROM user WHERE SAP_Employee_Id__c IN : sapEmployeeNumberSet]){
                userIdMap.put(uObj.SAP_Employee_Id__c,uObj.id);    
            }
        }

        for(Contract obj : newList){
            if(obj.Contract_Owner__c!=NULL && !userIdMap.isEmpty() && userIdMap.containskey(obj.Contract_Owner__c) && userIdMap.get(obj.Contract_Owner__c)!=NULL){
                obj.OwnerId = userIdMap.get(obj.Contract_Owner__c);    
            }
            
            if(obj.Sales_Assistant_User__c!=NULL && !userIdMap.isEmpty() && userIdMap.containskey(obj.Sales_Assistant_User__c) && userIdMap.get(obj.Sales_Assistant_User__c)!=NULL){
                obj.Sales_Assistant__c = userIdMap.get(obj.Sales_Assistant_User__c);    
            }
            
            if(obj.EndDate!=NULL && obj.StartDate!=NULL){
                obj.ContractTerm = obj.StartDate.monthsBetween(obj.EndDate);
            }
            
            if(obj.StartDate.month() == obj.EndDate.month()){
            obj.ContractTerm = 1;
            }
            obj.RecordTypeId = BGIContractRecordTypeId;
        }
    }

    public override void processBeforeUpdate(){

        list<contract> newList = (list<contract>) trigger.new;
        map<id,contract> oldMap = (map<id,contract>) trigger.oldMap;
        set<string> sapEmployeeNumberSet = new set<string>();
        map<string,id> userIdMap = new map<string,id>();

        for(Contract obj : newList){
            if(obj.Contract_Owner__c!=oldMap.get(obj.id).Contract_Owner__c && obj.Contract_Owner__c!=NULL)
                sapEmployeeNumberSet.add(obj.Contract_Owner__c); 
            
            if(obj.Sales_Assistant_User__c!=oldMap.get(obj.id).Sales_Assistant_User__c && obj.Sales_Assistant_User__c!=NULL)
                sapEmployeeNumberSet.add(obj.Sales_Assistant_User__c); 
            
            if(obj.StartDate!=oldMap.get(obj.id).StartDate || obj.EndDate!=oldMap.get(obj.id).EndDate)
                obj.ContractTerm = obj.StartDate.monthsBetween(obj.EndDate);
                
            if(obj.StartDate.month() == obj.EndDate.month()){
            obj.ContractTerm = 1;
            }
        }       

        if(sapEmployeeNumberSet.size()>0){
            for(user uObj : [SELECT id,SAP_Employee_Id__c FROM user WHERE SAP_Employee_Id__c IN : sapEmployeeNumberSet]){
                userIdMap.put(uObj.SAP_Employee_Id__c,uObj.id);    
            }
        }

        for(Contract obj : newList){
            if(obj.Contract_Owner__c!=NULL && !userIdMap.isEmpty() && userIdMap.containskey(obj.Contract_Owner__c) && userIdMap.get(obj.Contract_Owner__c)!=NULL){
                obj.OwnerId = userIdMap.get(obj.Contract_Owner__c);    
            }
            
            if(obj.Sales_Assistant_User__c!=NULL && !userIdMap.isEmpty() && userIdMap.containskey(obj.Sales_Assistant_User__c) && userIdMap.get(obj.Sales_Assistant_User__c)!=NULL){
                obj.Sales_Assistant__c = userIdMap.get(obj.Sales_Assistant_User__c);    
            }
        }  
    }
}