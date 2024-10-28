global class RequestAccess {

    
    //Add Description and this is created for the user story AMS-42
    @InvocableMethod(label='Request Access' description='This method does not return anything.' category='Request__c')
    public static void approveAccess(List<requestWrapper> req){
        List<Id> requestIds = new List<Id>();
        try{
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval.');
                req1.setObjectId(req[0].requestId);
                req1.setSubmitterId(UserInfo.getUserId()); 
                
                // Submit the approval request for the account
                Approval.ProcessResult result = Approval.process(req1);
            }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    
   public class requestWrapper {
        @InvocableVariable	
        public String requestId;
    }
}