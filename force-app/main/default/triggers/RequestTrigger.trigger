trigger RequestTrigger on accessnow__ACNW_Request__c (after update) {
    Boolean isCreated = false;
    if (Trigger.isUpdate && Trigger.isAfter) {
        List<accessnow__ACNW_Request__c> completedRequests = new List<accessnow__ACNW_Request__c>();
        Boolean shouldRunJob = Boolean.valueOf(Label.Start_Batch_Queueble_class);
        // Loop through the new and old records to check for status change to 'Completed'
        for (accessnow__ACNW_Request__c newReq : Trigger.new) {
            accessnow__ACNW_Request__c oldReq = Trigger.oldMap.get(newReq.Id);
            // Check if the status changed to 'Completed'
            if (oldReq.accessnow__Status__c == 'In Progress' && newReq.accessnow__Status__c == 'Completed' && !isCreated) {
                completedRequests.add(newReq);
            }
        }
        // Call the handler method only if there are requests with status 'Completed'
        if (!completedRequests.isEmpty() && shouldRunJob) {
			// Schedule the job
            System.enqueueJob(new AdminRequestCreationQueueable(completedRequests));
            isCreated = true;
        }
    }
}