/*******************************************************************************************
* User Story       AMS-42
* Created Date     31-May-2024
* Created By       Manichandra
* @description     This controller is invoked from the schedule class to modify the request record.
*******************************************************************************************/

public class AccessnowFutureDate Implements Schedulable {

    public void execute(SchedulableContext sc){
        CronTrigger cronTrigger = [SELECT Id, CronJobDetail.Name FROM CronTrigger 
                                   WHERE Id = :sc.getTriggerId() LIMIT 1];
        String jobName = cronTrigger.CronJobDetail.Name;
        String[] arrayNames = jobName.split(' ');
        List<accessnow__ACNW_Request__c> allReq = new List<accessnow__ACNW_Request__c>();
        accessnow__ACNW_Request__c reqObj = new accessnow__ACNW_Request__c(Id = arrayNames[1],accessnow__Original_Profile_Id__c = UserInfo.getProfileId() );
        allReq.add(reqObj);
        if(!allReq.isEmpty()) {
            UPDATE allReq;
        } 
        
    }  
}