public class ActivateLeadInterestHelper {
    public static void activateLeadInterest(List<Id> leadInterestIds, String userEmail) {
        Map<Id, String> failedLeadDetails = new Map<Id, String>();
        
        List<Child_Lead__c> leadsToUpdate = [SELECT Id, Active__c FROM Child_Lead__c WHERE Id IN :leadInterestIds];
        
        for (Child_Lead__c cl : leadsToUpdate) {
            cl.Active__c = true;
            cl.Lead_Status__c = 'New';
            cl.Unqualified_Reason__c = 'sadfsdf'; 
        }
        
        List<Database.SaveResult> updateResults = Database.update(leadsToUpdate, false);
        
        for (Integer i = 0; i < updateResults.size(); i++) {
             system.debug('inside loop');
            Database.SaveResult result = updateResults[i];
             if (result.isSuccess()) {
                   system.debug('inside success');
             }
            if (!result.isSuccess()) {
                system.debug('inside failure');
                failedLeadDetails.put(leadsToUpdate[i].Id, result.getErrors()[0].getMessage());
            }
        }
        
        if (!failedLeadDetails.isEmpty()) {
            String emailBody = 'LeadInterest update failed. Failed LeadInterest IDs and Error Messages:\n\n';
            for (Id leadId : failedLeadDetails.keySet()) {
                emailBody += 'Lead ID: ' + leadId + ' - Error: ' + failedLeadDetails.get(leadId) + '\n';
            }
            sendEmailNotification(emailBody, userEmail);
        }
    }
    
    public static void sendEmailNotification(String message, String emailAddress) {
        String toAddress = emailAddress;
        system.debug('inside email');
        system.debug('toAddress'+toAddress);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[]{toAddress});
        email.setSubject('LeadInterest Update Failure Notification');
        email.setPlainTextBody(message);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    }
}