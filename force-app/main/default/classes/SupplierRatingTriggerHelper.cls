public class SupplierRatingTriggerHelper {
    /**
* @description: create history records for the previous field values
* @param oldSupplierRatingMap - old supplier rating records map
* @param newSupplierRatingMap - new supplier rating records map
*/
    public static void createSupplierRatingHistoryRecords(Map<Id, Supplier_Rating__c> oldSupplierRatingMap, Map<Id, Supplier_Rating__c> newSupplierRatingMap) {
        List<Supplier_Rating_History__c> supplierRatingHistoryList = new List<Supplier_Rating_History__c>();
        String getFeedbackUserId = Label.GetFeedback_User_Id;
        Set<Id> supplierRatingHeaderIds = new Set<Id>();        
        if(oldSupplierRatingMap != null && newSupplierRatingMap != null && ! (userinfo.getUserId() == getFeedbackUserId )) { //update call
            for(Supplier_Rating__c oldSupplierRating : oldSupplierRatingMap.values()) {
                Supplier_Rating__c newSupplierRating = newSupplierRatingMap.get(oldSupplierRating.Id);
                Boolean isCommentChanged = oldSupplierRating.Comment__c != newSupplierRating.Comment__c;
                Boolean isRatingChanged = oldSupplierRating.Rating__c != newSupplierRating.Rating__c;
                Boolean isNoChnageInRating = oldSupplierRating.No_Change_On_Rating__c != newSUpplierRating.No_Change_On_Rating__c;
                system.debug('old rating '+ oldSupplierRating.Rating__c);
                
                if(! system.isBatch() && ! (userinfo.getUserId() == getFeedbackUserId) && (isCommentChanged || isRatingChanged ||  isNoChnageInRating) && oldSupplierRating.Rating__c != '0'){
                    supplierRatingHistoryList.add(SupplierRatingHistoryService.createHistoryRecordFromRating(oldSupplierRating, false, true));
                }                    

                if(String.isNotBlank(newSupplierRating.Supplier_Rating_Header__c) && !supplierRatingHeaderIds.contains(newSupplierRating.Supplier_Rating_Header__c) && ! system.isBatch() && ! (userinfo.getUserId() == getFeedbackUserId)) {
                    supplierRatingHeaderIds.add(newSupplierRating.Supplier_Rating_Header__c);
                }                
            }
        } else if(oldSupplierRatingMap != null && newSupplierRatingMap == null ) { //delete call
            for(Supplier_Rating__c oldSupplierRating : oldSupplierRatingMap.values()) {                
                supplierRatingHistoryList.add(SupplierRatingHistoryService.createHistoryRecordFromRating(oldSupplierRating, false, false));                
            }
        }
        
        //create history records for ratings
        if(!supplierRatingHistoryList.isEmpty()) {
            insert supplierRatingHistoryList;
        }
        //recalculate header when ratings changed - set last reated date when each rating was completed on header
        if(!supplierRatingHeaderIds.isEmpty()) {
            // commented per new rating functionality.
            //SupplierRatingHeaderService.recalculateLastRatedDateOnHeader(supplierRatingHeaderIds);
        }
    }
    
    
    public static void markToCreateFollowUpTask(Map<Id, Supplier_Rating__c> newSupplierRatingMap, Map<Id, Supplier_Rating__c> oldSupplierRatingMap){
        //Id getFeedbackUserId = [select id, name from user where name = 'GetFeedback Survey Integration user'].id;
        String getFeedbackUserId = Label.GetFeedback_User_Id;
        List<Task> objTaskList= new List<Task>();
        List<Supplier_Rating_History__c> supplierRatingHistoryList = new List<Supplier_Rating_History__c>();
        if(! system.isBatch()){
            String userId = userinfo.getUserName();
            for(Supplier_Rating__c obj: newSupplierRatingMap.values()){
                Supplier_Rating__c oldRating = oldSupplierRatingMap.get(obj.Id);
                Decimal minutesDifferenceUpdatecall = 0;
                //Marking NA when we slect not applicable.
                if(obj.Not_Applicable__c && obj.Rating__c == oldRating.Rating__c){
                    obj.Rating__c = 'N/A';
                }
                //marking the record asnot applicable if NA is salescted as rating.
              
                if(obj.Rating__c == 'N/A' && ! obj.Not_Applicable__c ){
                    obj.Not_Applicable__c = true;
                }
                system.debug('getFeedBackUserId '+ getFeedbackUserId);
                 system.debug('user id  '+ userinfo.getUserId());
               if((obj.Rating__c == '1' || obj.Rating__c == '2') && obj.Comment__c == null && (userinfo.getUserId() != getFeedbackUserId)){
                    obj.addError('Comments is required for ratings marked as 1 or 2');
                }
                if(obj.Getfeedback_Last_Updated_date__c != NULL){
                     minutesDifferenceUpdatecall = Integer.valueOf((system.now().getTime() -obj.Getfeedback_Last_Updated_date__c.getTime())/(1000*60));
                }
                //Markig rated date and rated by.
                if((obj.Rating__c != oldSupplierRatingMap.get(obj.Id).Rating__c) ||
                   ((obj.No_Change_On_Rating__c != oldSupplierRatingMap.get(obj.Id).No_Change_On_Rating__c) && obj.No_Change_On_Rating__c == true) || obj.Not_Applicable__c){
                    
                    obj.Rated_date__c = system.now();
                    //commenting the new changes to see if rating updates.
                    if(userinfo.getUserId() == getFeedbackUserId){
                        obj.Rated_by__c = obj.GetFeedback_User_Id__c;
                    }else{
                        obj.Rated_by__c = userinfo.getUserId();
                    }
                    //here we are marking no change in rating false so that next cycle people should rate.
                    obj.No_Change_On_Rating__c = false;
                }
                
                //creating tasks for rating 1 and 2. 
                if(obj.Follow_Up_Task_TimeStamp__c != null && (obj.Rating__c == '1' || obj.Rating__c == '2')){
                    Decimal minutesDifference = Integer.valueOf((system.now().getTime() -obj.Follow_Up_Task_TimeStamp__c.getTime())/(1000*60));
                    if(obj.Follow_up_task_created__c && obj.Follow_Up_Task_TimeStamp__c != null && minutesDifference > 2){
                        objTaskList.add(createIndTask(obj));
                        obj.Follow_up_task_created__c = true;
                    	obj.Follow_Up_Task_TimeStamp__c	= system.now();
                        
                    }                    
                }else if((obj.Rating__c == '1' || obj.Rating__c == '2') && ! obj.Follow_up_task_created__c){
                    objTaskList.add(createIndTask(obj));
                    obj.Follow_up_task_created__c = true;
                    obj.Follow_Up_Task_TimeStamp__c	= system.now();
                }
                //here we are creating history records if we change the rating , comment, no change in rating.
                Supplier_Rating__c oldSupplierRating = oldSupplierRatingMap.get(obj.Id);
                if(obj.GetFeedback_RatingHistory_CreateDate__c != null && obj.Create_Supplier_History__c){
                    Decimal minutesDifference = Integer.valueOf((system.now().getTime() -obj.GetFeedback_RatingHistory_CreateDate__c.getTime())/(1000*60));
                    if(obj.GetFeedback_History_Created__c && obj.GetFeedback_RatingHistory_CreateDate__c != null && minutesDifference > 2 && userinfo.getUserId() == getFeedbackUserId ){
                        createHistoryRecordForGetFeedback(oldSupplierRating, obj.GetFeedback_User_Id__c);
                        obj.GetFeedback_History_Created__c = true;
                    	obj.GetFeedback_RatingHistory_CreateDate__c	= system.now();
                    }                    
                }else if(! obj.GetFeedback_History_Created__c && userinfo.getUserId() == getFeedbackUserId){
						createHistoryRecordForGetFeedback(oldSupplierRating, obj.GetFeedback_User_Id__c);
                    	obj.GetFeedback_History_Created__c = true;
                    	obj.GetFeedback_RatingHistory_CreateDate__c	= system.now();
                }
            }
        }
        
        if(! objTaskList.isEmpty()){
            try{
                insert objTaskList;
            }catch(exception e){
                system.debug('following error while creating task'+ e.getMessage());
            }
        }
		if(!supplierRatingHistoryList.isEmpty()) {
            insert supplierRatingHistoryList;
        }        
    }
    private static task createIndTask(Supplier_Rating__c rating){
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Supplier').getRecordTypeId();
        date activitydate = date.today();
        activitydate = activitydate.addDays(180);
        Task objTask = new Task();
        //this field is marked from get feedback to assign the user who has triggered the survey.
        if(rating.Assign_Owner_from_response__c ){
            objTask.OwnerId= rating.GetFeedback_User_Id__c;
        }else{
            objTask.OwnerId=userinfo.getUserId();  
        }        
        objTask.WhatId=rating.Id;
        objTask.Priority= 'High';
        //adding the supplier namd and location, value element as a part of new change.
        objTask.Subject='Follow up on rating - ' + rating.Supplier_Name__c + ' - '+ rating.Location_With_BG__c + ' - '+ rating.Value_Element_Name__c ;
        objTask.RecordTypeId = recordTypeId;
        objTask.ActivityDate= activitydate;
        //objTask.Description= rating.Comment__c;
        objTask.Status= 'Not Started';
        objTask.Rating_Comments__c= rating.Comment__c;
        return objTask;    
    }
    public static void createHistoryRecordForGetFeedback(Supplier_Rating__c sr, Id userId){
        List<Supplier_Rating_History__c> supplierRatingHistoryList = new List<Supplier_Rating_History__c>();        
            Supplier_Rating_History__c supplierRatingHistory = new Supplier_Rating_History__c(
                    Value_Element__c = sr.Value_Element__c,
                    Supplier_Hub__c = sr.Supplier_Hub__c,
                    Rating__c = sr.Rating__c,
                    Comment__c = sr.Comment__c,
                    Rated_By__c = userId,
                    Rated_Date__c = sr.LastModifiedDate,
                    Location__c = sr.Location__c,
                    Business_Group__c= sr.SRM_Business_Group__c,
                    FC_Location__c= sr.FC_Location__c,
                 	Supplier_Rating__c = sr.Id
                );
                supplierRatingHistoryList.add(supplierRatingHistory);
        system.debug('historylist '+ supplierRatingHistoryList);
            try{
                insert supplierRatingHistoryList;
            }catch(exception e){
                system.debug('error '+ e.getMessage());
            }
         
        
    }
    public static void popuateUniqueKey(List<Supplier_Rating__c> newRatings){
        for(Supplier_Rating__c obj: newRatings){
            obj.Unique_Record_Key__c = string.valueOf(obj.Supplier_Hub__c) + string.valueOf(obj.Location__c) + string.valueOf(obj.SRM_Business_Group__c) + string.valueOf(obj.Value_Element__c) ;
        }
    }
}