public class SRM_RiskDetailTriggerHandler {
	public static void updateAccountToShareWith(List<Risk__c> newRisks, Map<id, Risk__c> oldMap){
        set<Id> supplierIds = new set<Id>();
        Map<Id, Supplier_Hub__c> relatedSuppliers = new Map<Id, Supplier_Hub__c>();
        for(Risk__c obj: newRisks){
            if(obj.Supplier__c != NULL){
                supplierIds.add(obj.Supplier__c);
            }
        }
        if(supplierIds != null){
            relatedSuppliers= getRelatedSuppliers(supplierIds);
        }
        if(! relatedSuppliers.isEmpty()){
            for(Risk__c obj: newRisks){
                if(relatedSuppliers.get(obj.Supplier__c) != NULL && obj.Visibility__c == 'Joined'){
                    obj.Account_to_share_with__c = relatedSuppliers.get(obj.Supplier__c).Supplier_Account__c;
                }
                if(trigger.isBefore && trigger.isUpdate){
                    if(oldMap.get(obj.Id).Visibility__c != obj.Visibility__c && obj.Visibility__c == 'Internal'){
                        obj.Account_to_share_with__c = null;
                    }
                }
            }
        }
    }
    private static Map<Id, Supplier_Hub__c> getRelatedSuppliers(set<Id> supplierIds){
        return new Map<Id, Supplier_Hub__c>([SELECT Id, Supplier_Account__c FROM Supplier_Hub__c WHERE Id IN: supplierIds]);
    }
    public static void updateClosedTimeStamp(List<Risk__c> newRisks, Map<Id,Risk__c > oldMap){
        for(Risk__c obj: newRisks){
            if(obj.Case_status__c == 'Closed' && oldMap.get(obj.id).Case_status__c != obj.Case_status__c){
                obj.Case_closed_by__c = UserInfo.getName();
                obj.Case_closed_timestamp__c = System.now();
            }
        }
    }
    public static void sendEmailsToSupplierTeamMembers(List<Risk__c> newRisks){
       
       
         List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
		Set<Id> supplierIds = new Set<Id>();
        Set<Id> contactOrUserIds  = new Set<Id>();
        List<String> sendTo = new List<String>();
        Map<Id, Supplier_Hub__c> relatedSuppliers = new Map<Id, Supplier_Hub__c>();
        List<Supplier_Team__c> RealtedTeamMembers = new List<Supplier_Team__c> ();
        Id templateId = [SELECT Id, Name FROM   EmailTemplate where name = 'Risk Template V1' limit 1].Id;
        String whatId = '';
        
        for(Risk__c obj: newRisks){
            if(obj.Supplier__c != NULL){
                system.debug('obj.Id'+ obj.Id);
                supplierIds.add(obj.Supplier__c);
                whatId = obj.Id;
            }
        }
         system.debug('whatid '+ whatId );
        if(supplierIds != null){
            RealtedTeamMembers = getRealtedTeamMembers(supplierIds);
            system.debug('relationsihp manager '+ RealtedTeamMembers);
            if(! RealtedTeamMembers.isEmpty()){
                for(Supplier_Team__c objTeam: RealtedTeamMembers){
                    //sendTo.add(objTeam.Email__c);
                    contactOrUserIds.add(objTeam.Contact__c);
                    if(objTeam.Contact__c == null){
                        contactOrUserIds.add(objTeam.User__c);
                    }
                }
            }
        }
        
        system.debug('contactOrUserIds ' + contactOrUserIds);
         system.debug('RealtedTeamMembers ' + RealtedTeamMembers);
        Contact tempContact = new Contact();
        List<Contact> tempContactList = new List<Contact>();
		// sending email.
        for(Supplier_Team__c obj: RealtedTeamMembers){
            if(obj.Contact__c != null){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTargetObjectId(obj.Contact__c);
                message.setSenderDisplayName('Supplier Connect'); 
                message.setUseSignature(false); 
                message.setBccSender(false); 
                message.setSaveAsActivity(false);
                message.setTemplateID(templateId); 
                if(obj.Contact__c != null){
                    message.setWhatId(whatId);
                }
                sendTo.add(string.valueOf(obj.Email__c));
                message.setToAddresses(sendTo);
                message.setTreatTargetObjectAsRecipient(false);
                mails.add(message);
                
            }else{
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, obj.User__c, whatId);
                String emailSubject = email.getSubject();
                String emailTextBody = email.getPlainTextBody();
                
                email.setTargetObjectId(obj.User__c);
                email.setSubject(emailSubject);
                email.setPlainTextBody(emailTextBody);
                email.saveAsActivity = false;
                mails.add(email);

            }
            
            
        }
        for(Messaging.SingleEmailMessage testMail: mails){
            system.debug('testMail '+ testMail);
        }
		Messaging.sendEmail(mails);            
    }
    private static List<Supplier_Team__c> getRealtedTeamMembers(Set<Id> supplierIds ){
        return [select id, Email__c,Contact__c, User__c from Supplier_Team__c where Role__c = 'Relationship Manager' AND Supplier_Hub__c IN :supplierIds];
    }
}