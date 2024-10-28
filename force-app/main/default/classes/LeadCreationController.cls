/*------------------------------------------------------------  
Author:       Praneeth Krishna
Description:  This is the Controller class used by "childLeadCreation" LWC component

History
01-04-2023     Praneeth Krishna    Created Class
------------------------------------------------------------*/

public without sharing class LeadCreationController {
    @AuraEnabled
    public static List<Child_Lead__c>  checkChildLead(String email, String campaignID){
        List<Child_Lead__c> childLeads = new List<Child_Lead__c>();
        try {          
            childLeads =  [SELECT Id, First_Name__c,Last_Name__c,Company__c, Email__c, Campaign_Name__c,Phone__c,Active__c FROM Child_Lead__c  WHERE  Lead_Status__c != 'Qualified' AND Email__c =: email AND Campaign_Name__c =: campaignId];
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage()+ ' stackTrace: ' +ex.getStackTraceString());
        }
        return childLeads;
    }

    @AuraEnabled
    public static List<Lead>  checkMasterLead(String email){
        List<Lead> leads = new List<Lead>();
        try {
            leads = [SELECT Id, Email,Name,FirstName,LastName,Company FROM Lead WHERE RecordType.DeveloperName = 'Master_Lead'  AND Email =: email AND isConverted = false];         
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage()+ ' stackTrace: ' +ex.getStackTraceString());
        }
        return leads;
    }

    @AuraEnabled
    public static List<Contact>  checkContact(String email){
        List<Contact> contacts = new List<Contact>();
        try {
            contacts = [SELECT Id, Email,Name,FirstName,LastName,Account.name,AccountId FROM Contact WHERE RecordType.DeveloperName = 'BGI_Contact'  AND Email =: email];    
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage()+ ' stackTrace: ' +ex.getStackTraceString());            
        }
        return contacts;
    }    

    @AuraEnabled
    public static List<campaign>  getCampaignInfo(String Id){
        List<Campaign> campaign = new List<Campaign>();
        try {
            campaign = [SELECT Name,Business_Segment__c,Sub_Segment__c FROM Campaign WHERE Id= :Id];    
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage()+ ' stackTrace: ' +ex.getStackTraceString());            
        }
        return campaign;
    }    
   
    @AuraEnabled
    public static boolean afterChildLeadCreationProcess(ChildLeadWrapper childLeadData, String childLeadId) {
        Savepoint sp = Database.setSavepoint();  
        try {         
            Id masterRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Master_Lead').getRecordTypeId();

            Lead lead = new Lead(FirstName = childLeadData.firstName ,LastName = childLeadData.lastName, Email = childLeadData.email, 
            Company = childLeadData.company, phone= childLeadData.phone,RecordTypeId= masterRecordTypeId);
            insert lead;

            CampaignMember campaignMember = new CampaignMember();
            campaignMember.CampaignId = childLeadData.campaignId;
            campaignMember.Status = 'Manual';
            campaignMember.LeadId = lead.Id;
            campaignMember.Do_Not_Create_Child_Lead__c = true;
            insert campaignMember;

            Child_Lead__c childlead = new Child_Lead__c(Id = childLeadId);
            childlead.Related_Master_Lead__c = lead.Id;      
            update childlead;           
                    
        } catch (Exception ex) {
            Database.rollback(sp);
            throw new AuraHandledException(ex.getMessage()+ ' stackTrace: ' +ex.getStackTraceString());                
        }           
        return true;
    }

    @AuraEnabled
    public static boolean linkChildLeadWithLead(String campaignId, String childLeadId, String leadId) {
        Savepoint sp = Database.setSavepoint();  
        try {    
            CampaignMember campaignMember = new CampaignMember();
            campaignMember.CampaignId = campaignId;
            campaignMember.Status = 'Manual';
            campaignMember.LeadId = leadId;
            campaignMember.Do_Not_Create_Child_Lead__c = true;
            insert campaignMember;

            Child_Lead__c childlead = new Child_Lead__c(Id = childLeadId);
            childlead.Related_Master_Lead__c = leadId;  
            childlead.Lead_Status__c = 'New'; 
            update childlead;               
        } catch (Exception ex) {
            Database.rollback(sp);
            throw new AuraHandledException(ex.getMessage()+ ' stackTrace: ' +ex.getStackTraceString());            
        }
        return true;
    }

    @AuraEnabled
    public static boolean linkChildLeadWithContact(String campaignId, String childLeadId, String contactId, String account) {
        Savepoint sp = Database.setSavepoint();  
        try {      
            if(!isCampaignMemberPresent(campaignId,contactId)){
                CampaignMember campaignMember = new CampaignMember();
                campaignMember.CampaignId = campaignId;
                campaignMember.Status = 'Manual';
                campaignMember.ContactId = contactId;
                campaignMember.Do_Not_Create_Child_Lead__c = true;
                insert campaignMember;
            }

            Child_Lead__c childlead = new Child_Lead__c(Id = childLeadId);
            childlead.Related_Contact__c = contactId;
            childlead.Related_Account__c = account;      
            update childlead;           
                    
        } catch (Exception ex) {
            Database.rollback(sp);
            throw new AuraHandledException(ex.getMessage()+ ' stackTrace: ' +ex.getStackTraceString());            
        }
        return true;
    }
    
    @AuraEnabled
    public static boolean isCampaignMemberPresent(String campaignId, String ContactID){
        Boolean memberPresent = false;
        List<CampaignMember> campaignMembers = [SELECT Id FROM CampaignMember WHERE CampaignId = :campaignId AND ContactId =:ContactID];
        memberPresent  = campaignMembers.size() > 0 ? true : false; 
        return memberPresent;
    }

    @AuraEnabled
    public static boolean activateLeadInterestRecord(String childLeadId){   
        try{
            Child_Lead__c childlead = new Child_Lead__c(Id = childLeadId);
            childlead.Active__c = true;  
            childlead.Lead_Status__c = 'New';
            childlead.Unqualified_Reason__c = ''; 
            update childlead;  
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage()+ ' stackTrace: ' +ex.getStackTraceString());            
        }        
        return true;   
    }
    
    @AuraEnabled
    public static void createDebugLogRecord(String childLeadId,String errorMessage,String stackTrace,String operationName){        
        DebugLog__c debuglogs = new DebugLog__c();
        debuglogs.Object__c = 'Child Lead';
        debuglogs.Errored_Process_Type__c = 'Apex Class';
        debuglogs.Errored_Process_Name__c = 'Insert Manual Child Lead';
        debuglogs.Operation_Name__c = operationName;
        debuglogs.TypeName__c = 'Apex Error';
        debuglogs.RecordId__c =childLeadId;                
        debuglogs.Message__c = errorMessage!=null ? errorMessage.left(255):null ;  
        debuglogs.StackTraceString__c  = stackTrace;
        Database.insert(new List<DebugLog__c>{debuglogs}) ;
    }

    
}