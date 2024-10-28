/*       
@Name                  BatchToCopyInfoFromH5ToH1
@Author                Shoba Thummala + shoba.thummala@frieslandcampina.com
@Version               1
@CreatedDate           January 15, 2021
@UsedBy                
@Description           Class to gather some information from H5 accounts [Type field and 
                       Some Fields] and copy then in the respective H1 accounts
@Changes
UserId           | Author-Email                         | Date                | Comment
================ |======================================|=====================|=========
*/

global without sharing class BatchToCopyInfoFromH5ToH1 implements Database.Batchable<sObject>,Schedulable {
     //Method to execute the batch class
    global void execute(SchedulableContext sc) {
        BatchToCopyInfoFromH5ToH1 copyInfoBatch = new BatchToCopyInfoFromH5ToH1(); 
        database.executebatch(copyInfoBatch);
    }
   //Start method in the batch class
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //Query all the commercial customer accounts that are active 
        String query = 'SELECT Id, Business_Segment__c, Sub_Segment__c, Application__c, Sales_Region__c, Type'+
        ' FROM Account WHERE Recordtype.DeveloperName = \'BGI_Commercial_Customer\' AND Active__c = TRUE ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> records){
        //Declare the variables
        Map<Id,Account> mapAllH1Accounts = new Map<Id,Account>((List<Account>) records);
        Map<Id,Set<String>> mapBusinessSegment  = new Map<Id,Set<String>>();
        Map<Id,Set<String>> mapSubSegment       = new Map<Id,Set<String>>();
        Map<Id,Set<String>> mapApplication      = new Map<Id,Set<String>>();
        Map<Id,Set<String>> mapSalesRegion      = new Map<Id,Set<String>>();
        Map<Id,Set<String>> mapType             = new Map<Id,Set<String>>();
        Map<Id,Set<String>> mapApplicationGroup = new Map<Id,Set<String>>();
        Map<Id,Set<String>> mapChannel          = new Map<Id,Set<String>>();
        Map<Id,Set<String>> mapSalesUnit        = new Map<Id,Set<String>>();
        Map<Id,Set<String>> mapCustdrive        = new Map<Id,Set<String>>();
         //Query the assosiated H5 accounts 
        for(Account actualH5 : [
            SELECT Id, Business_Segment__c, Sub_Segment__c, Application__c, Sales_Region__c, ParentId,Type,Application_Group__c,Channel__c,Sales_Unit__c, Customer_Drive__c 
            FROM Account 
            WHERE Recordtype.DeveloperName = 'BGI_Customer_Location'
            AND Partner_Role__c includes ('Sold-to')
            AND Active__c = TRUE
            AND ParentId IN :mapAllH1Accounts.keySet()
            ORDER BY ParentId
        ]){
            //call fieldToMap method 
            if(actualH5.Business_Segment__c != null) fieldToMap(mapBusinessSegment,actualH5.ParentId,actualH5.Business_Segment__c);
            if(actualH5.Sub_Segment__c != null) fieldToMap(mapSubSegment,actualH5.ParentId,actualH5.Sub_Segment__c);
            if(actualH5.Application__c != null) fieldToMap(mapApplication,actualH5.ParentId,actualH5.Application__c);
            if(actualH5.Sales_Region__c != null) fieldToMap(mapSalesRegion,actualH5.ParentId,actualH5.Sales_Region__c);
            if(actualH5.type != null) fieldToMap(mapType,actualH5.ParentId,actualH5.Type);
            if(actualH5.Application_Group__c != null) fieldToMap(mapApplicationGroup,actualH5.ParentId,actualH5.Application_Group__c);
            if(actualH5.Channel__c != null) fieldToMap(mapChannel,actualH5.ParentId,actualH5.Channel__c);
            if(actualH5.Sales_Unit__c != null) fieldToMap(mapSalesUnit,actualH5.ParentId,actualH5.Sales_Unit__c);
            if(actualH5.Customer_Drive__c != null) fieldToMap(mapCustdrive,actualH5.ParentId,actualH5.Customer_Drive__c);

            }    
            
        
         system.debug('mapType'+mapType.values());
         
        List<Account> listH1Update = new List<Account>();
        //Loop through the H1 Accounts 
        for(Account actualH1 : mapAllH1Accounts.values()){
            Account h1NewInstance = new Account(Id = actualH1.Id);
            //Add all the H5 Customer Accounts to H1 business segment 
            h1NewInstance.Business_Segment__c = mapBusinessSegment.containsKey(actualH1.Id) ? 
            String.join(new List<String>(mapBusinessSegment.get(actualH1.Id)),';') : null;
            //Add all the H5 Customer Accounts to H1  sub segment 
            h1NewInstance.Sub_Segment__c = mapSubSegment.containsKey(actualH1.Id) ? 
            String.join(new List<String>(mapSubSegment.get(actualH1.Id)),';') : null;
            //Add all the H5 Customer Accounts to H1 to  application 
            h1NewInstance.Application__c = mapApplication.containsKey(actualH1.Id) ? 
            String.join(new List<String>(mapApplication.get(actualH1.Id)),';') : null;
            //Add all the H5 Customer Accounts to H1  to salesRegion 
            h1NewInstance.Sales_Region__c = mapSalesRegion.containsKey(actualH1.Id) ? 
            String.join(new List<String>(mapSalesRegion.get(actualH1.Id)),';') : null;
            
            //Add all the H5 Customer Accounts to H1  to Application Group 
            h1NewInstance.Application_Group__c = mapApplicationGroup.containsKey(actualH1.Id) ? 
            String.join(new List<String>(mapApplicationGroup.get(actualH1.Id)),';') : null;
            
            //Add all the H5 Customer Accounts to H1  to Channel 
            h1NewInstance.Channel__c = mapChannel.containsKey(actualH1.Id) ? 
            String.join(new List<String>(mapChannel.get(actualH1.Id)),';') : null;
            
            //Add all the H5 Customer Accounts to H1  to SalesUnit 
            h1NewInstance.Sales_Unit__c = mapSalesUnit.containsKey(actualH1.Id) ? 
            String.join(new List<String>(mapSalesUnit.get(actualH1.Id)),';') : null;
            
            //Add all the H5 Customer Accounts to H1  to Customer Drive 
            h1NewInstance.Customer_Drive__c = mapCustdrive.containsKey(actualH1.Id) ? 
            String.join(new List<String>(mapCustdrive.get(actualH1.Id)),';') : null;
         
             
            //Check the H5 accounts Type , if all the H5 account type is 'Distributor' update the H1 account type as 'distributor'
            //If all the H5 account type is 'Direct Customer' update the H1 account type as 'Direct Customer'
            //For all the other scenarios of type update the the H1 account type as 'Distributor & Direct Customer'
            if(mapType.containsKey(actualH1.Id)){
                system.debug('MapType.get(actualH1.Id).size()'+MapType.get(actualH1.Id).size());
                if(MapType.get(actualH1.Id).size()==1){
                       for(String S:MapType.get(actualH1.Id)){
                        if(S=='Distributor'){
                        h1NewInstance.Type='Distributor';
                        }
                         else if(S=='Direct Customer'){
                             h1NewInstance.Type= 'Direct Customer';
                        }
                       else{
                       h1NewInstance.Type='Distributor & Direct Customer';  
                    }
                  }
                }
               else{
                    h1NewInstance.Type='Distributor & Direct Customer';
                }
              }
            else{
               h1NewInstance.Type=null; 
            }
            
            listH1Update.add(h1NewInstance);
        }
        
        if(listH1Update.size() > 0)
            //update listH1Update;
            //Database.update(listH1Update, false); 
            update listH1Update;
          }    

    global void finish(Database.BatchableContext bc){
    }    
    
    //Method to add id as accountid and values as fieldvalues to map 
    private void fieldToMap(Map<Id,Set<String>> mapParentField, String parent, String fieldValue){
        Set<String> fieldValueSet = new Set<String>(fieldValue.split(';'));
        if(!mapParentField.containsKey(parent)){
            Set<String> auxSet = new Set<String>();
            mapParentField.put(parent,auxSet);
        }
        mapParentField.get(parent).addAll(fieldValueSet);
    }
}