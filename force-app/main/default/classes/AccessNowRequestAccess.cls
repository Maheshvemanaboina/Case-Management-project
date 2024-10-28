/*******************************************************************************************
* User Story       AMS-42
* Created Date     26-Apr-2024
* Created By       Manichandra
* @description     This controller is calling from ScreenFlow. We are performing this to submit the approval request.
*******************************************************************************************/

global class AccessNowRequestAccess {
    
    //Add Description and this is created for the user story AMS-42
    @InvocableMethod(label='Access now request access' description='This method submit the request for approval process' category='Request__c')
    public static void approveAccess(List<requestWrapper> reqestWrapper){
        List<Id> requestIds = new List<Id>();
        try{
            for(requestWrapper processRequest : reqestWrapper) {
                Approval.ProcessSubmitRequest requestObj = new Approval.ProcessSubmitRequest();
                requestObj.setComments('Submitting request for approval.');
                requestObj.setObjectId(processRequest.requestId);
                requestObj.setSubmitterId(UserInfo.getUserId()); 
                System.debug(processRequest.requestId);
                // Submit the approval request for the account
                Approval.ProcessResult result = Approval.process(requestObj);
            }
        }
        catch(Exception ex) {
            System.debug(ex.getMessage());
        }
        
    }
    
    public class requestWrapper {
        @InvocableVariable	
        public String requestId;
    }
}