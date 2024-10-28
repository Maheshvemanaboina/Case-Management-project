global class ActivateLeadInterest implements Database.Batchable<sObject>,Database.Stateful {
    public List<String> leadInterestIds;
    public Map<Id, String> failedLIDetails = new Map<Id, String>();
    public String userEmail;
    
    global ActivateLeadInterest(List<String> ids, String email) {
        leadInterestIds = ids;
        userEmail = email;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Active__c FROM Child_Lead__c WHERE Id IN :leadInterestIds';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Child_Lead__c> scope) {
        for (Child_Lead__c cl : scope) {
            cl.Active__c = true;
            cl.Lead_Status__c = 'New';
            cl.Unqualified_Reason__c = ''; 
        }
        Database.SaveResult[] updateResults = Database.update(scope, false);
        for (Integer i = 0; i < updateResults.size(); i++) {
            Database.SaveResult result = updateResults[i];
            if (!result.isSuccess()) {
                failedLIDetails.put(scope[i].Id, result.getErrors()[0].getMessage());
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];    
        String emailBody = 'Lead Interest Batch Job Summary:<br/><br/>';
        emailBody += 'Job Id: ' + job.Id + '<br/>';
        emailBody += 'Status: ' + job.Status + '<br/>';
        emailBody += 'Records Failed: ' + failedLIDetails.size() + '<br/><br/>';
    
        if (!failedLIDetails.isEmpty()) {
            emailBody += 'Failed LeadInterest Details:<br/><br/>';
            emailBody += 'Lead Interest ID | Error <br/>';
            for (Id leadId : failedLIDetails.keySet()) {
                emailBody += leadId + ' | ' + failedLIDetails.get(leadId)+'<br/>';
            }
        }
    
        sendEmailNotification(emailBody, job.Id, userEmail);
	}

    public static void sendEmailNotification(String message, String jobId, String emailAddress) {
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress WHERE DisplayName = 'FC-No Reply' LIMIT 1];
        String toAddress = emailAddress;
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[]{toAddress});
        email.setSubject('LeadInterest Batch Job Summary - Job ID: ' + jobId);
        email.setHtmlBody(message);
        email.setOrgWideEmailAddressId(owea.get(0).Id);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    }

}