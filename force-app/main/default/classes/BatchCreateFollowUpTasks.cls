public class BatchCreateFollowUpTasks implements Database.Batchable<sObject>{    
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Assign_Owner_from_response__c, GetFeedback_Create_Task__c, GetFeedback_User_Id__c,Create_Supplier_History__c,Default_Task_Owner_Id__c,Comment__c,Value_Element__c,Supplier_Hub__c,Rating__c,LastModifiedById,LastModifiedDate,Location__c,SRM_Business_Group__c,FC_Location__c from Supplier_Rating__c WHERE GetFeedback_Create_Task__c = TRUE';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Supplier_Rating__c> records){
        List<Supplier_Rating__c> updatedRatings = new List<Supplier_Rating__c>();
        List<Task> objTaskList= new List<Task>();
        List<Supplier_Rating__c> updateRecors = new List<Supplier_Rating__c>();
        List<Supplier_Rating_History__c> supplierRatingHistoryList = new List<Supplier_Rating_History__c>();
        for(Supplier_Rating__c obj: records){
            if((obj.Rating__c == '1' || obj.Rating__c == '2')){
                objTaskList.add(createIndTask(obj));
                obj.GetFeedback_Create_Task__c= false;                
                if(obj.Create_Supplier_History__c){
                    supplierRatingHistoryList.add(SupplierRatingHistoryService.createHistoryRecordFromRating(obj, false, true));
                    obj.Create_Supplier_History__c= false;
                }
                updatedRatings.add(obj);
            }
        }
        try{
            insert objTaskList;
        }catch(exception e){
            system.debug('following error while creating task'+ e.getMessage());
            system.debug('######## '+e.getLineNumber());
            system.debug('########## '+ e.getStackTraceString());
        }
        try{
            update updatedRatings;
        }catch(exception e){
            system.debug('following error while updating rating'+ e.getMessage());
        }
        if(!supplierRatingHistoryList.isEmpty()) {
            insert supplierRatingHistoryList;
        }
    }
    public void finish(Database.BatchableContext bc){
        String hour = String.valueOf(Datetime.now().hour());
        //You can add any no of Minute you want to add to schedule it for next
        String min = String.valueOf(Datetime.now().addMinutes(2).minute());
        String ss = String.valueOf(Datetime.now().second());
        
        //parse to a cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        scheduledSrmTaskBatch s = new scheduledSrmTaskBatch();
		System.schedule('Create Follow up task Started At' + system.now(), nextFireTime, s);

    }
    private task createIndTask(Supplier_Rating__c rating){
        date activitydate = date.today();
        activitydate = activitydate.addDays(5);
        Task objTask = new Task();
        if(rating.Assign_Owner_from_response__c ){
            objTask.OwnerId= rating.GetFeedback_User_Id__c;
        }else{
            objTask.OwnerId=rating.Default_Task_Owner_Id__c;  
        }        
        objTask.WhatId=rating.Id;
        objTask.Priority= 'High';
        objTask.Subject='Follow up on rating';
        objTask.RecordTypeId = '01226000001aGUm';
        objTask.ActivityDate= activitydate;
        objTask.Description= rating.Comment__c;
        objTask.Status= 'Not Started';
        return objTask;    
    }
}