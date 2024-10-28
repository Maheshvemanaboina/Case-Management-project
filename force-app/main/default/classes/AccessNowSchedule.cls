/*******************************************************************************************
* User Story       AMS-42
* Created Date     31-May-2024
* Created By       Manichandra
* @description     This controller is calling from ScreenFlow. We are performing this to submit scheduler based Requested time.
*******************************************************************************************/

global class AccessNowSchedule {

    @InvocableMethod(label='Access now request schedule' description='This method submit the request for schedule class' category='Request__c')
    public static void approveAccess(List<requestWrapper> reqestWrapper){
        
        
    	accessnow__ACNW_Request__c accRequest = [ SELECT Id, Name, accessnow__Manually_Revoked__c, accessnow__Status__c, accessnow__Requested_Start_Time__c, accessnow__Requested_End_Time__c 
                                                    FROM accessnow__ACNW_Request__c 
                                                    WHERE Id = :reqestWrapper[0].requestId 
                                                    LIMIT 1
                                                ];
        String scheduleName = accRequest.Name+' '+accRequest.Id;
        DateTime startDate = accRequest.accessnow__Requested_Start_Time__c;
        String cronDate = '' + startDate.second() + ' ' + startDate.minute() + ' ' + startDate.hour() + ' ' + startDate.day() + ' ' + startDate.month() + ' ? ' + startDate.year();
        String jobID = System.schedule(scheduleName , cronDate, new AccessnowFutureDate());

    }   
    
    
      public class requestWrapper {
        @InvocableVariable	
        public String requestId;
    }
}