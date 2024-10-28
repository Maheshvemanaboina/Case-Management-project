/**
* Author   :   suyogya jain
* Date     :   17 march 2022
* Desc     :   batch class to update lead as inactive if no actions has been taken on those lead with in 6 months.
* */

public class inactiveLeadDeletionBatch implements
Database.Batchable<sObject>, Database.Stateful {
    public Database.QueryLocator start(database.BatchableContext bc){
       string query = 'select id,LastModifiedDate,Last_Activity_Date__c,name,active__c from lead WHERE active__c=TRUE AND isConverted = false' ;
       return Database.getQueryLocator(query);
    }
    public void execute(database.BatchableContext bc,list<lead> scope){
        list<lead> ldlist = new list<lead>();
        string pardotSystemUser = System.Label.Pardot_User_ID;  
        for(lead ld :scope){                   
            if(ld.Last_Activity_Date__c != null){  
                Integer lastActivityDateCount = Date.valueOf(ld.Last_Activity_Date__c).daysBetween((system.today()));
                if(lastActivityDateCount > 180){
                    ld.active__c = false;
                    ld.ownerId = pardotSystemUser;
                    ldlist.add(ld); 
                }
            }else if(ld.Last_Activity_Date__c == null ){
                Integer lastmodifiedDateCount = Date.valueOf(ld.LastModifiedDate).daysBetween((system.today()));
                if(lastmodifiedDateCount > 180){
                    ld.active__c = false;
                    ld.ownerId = pardotSystemUser;
                    ldlist.add(ld); 
                }
            }            
        }
        if(ldlist.size()>0){
           ID jobID = System.enqueueJob(new UpdateLeadQueue(ldlist));
        }
    }

    public void finish(database.BatchableContext bc){

    }
}