/**       
@Name           - BulkUploadChildLeads
@Author         - Mahendra Kumar | Email - mahendra.kumar@frieslandcampina.com
@Version        - 1.0
@CreatedDate    - 22-03-2023
@UsedBy         - Trigger - ChildLeadTriggerHandler

UserId              | Author-Email                        | Date       | Comment
====================|=====================================|============|==============
0058E000009TanLQAS  | mahendra.kumar@frieslandcampina.com | 22-03-2023 | Created class
--------------------|-------------------------------------|------------|--------------

* @description Child Leads bulk upload process
*/
public without sharing class BulkUploadChildLeads {
        
    static Id partnerChildLeadRecordTypeId = Schema.SObjectType.Child_Lead__c.getRecordTypeInfosByDeveloperName().get('Partner_Child_Lead').getRecordTypeId();
    static Map<String, CampaignMember> emailCampaignMemberMap = new Map<String, CampaignMember>();
    static Map<String, List<Lead>> emailMasterLeadsMap = new Map<String, List<Lead>>();
    static Map<String, List<Contact>> emailContactsMap = new Map<String, List<Contact>>();
    static Map<String, Child_Lead__c> emailChildLeadMap = new Map<String, Child_Lead__c>();
    public static List<String> leadInterestToActivate= new List<String>();
    
/**     
* @description Check the Duplicate Child Leads if the Child Lead's ByPass Trigger flag is not enabled
* @param newChildLeadsList - Accepts list of the child lead records that are being inserted
*/
    public static void duplicateCheck(List<Child_Lead__c> newChildLeadsList){
        
        Set<String> emailSet = new Set<String>();
        Set<String> campaignIdSet = new Set<String>();
        Map<String, Child_Lead__c> emailCampaignMap = new Map<String, Child_Lead__c>();
        Set<String> childLeadsWithoutEmailSet = new Set<String>();
        List<Child_Lead__c> childLeadsListWithOutEmail = new List<Child_Lead__c>();
        
        for(Child_Lead__c childLead : newChildLeadsList){
            if(childLead.Email__c != null && childLead.Campaign_Name__c != null && !childLead.ByPass_Trigger__c){
                childLead.Lead_Status__c = String.isNotBlank(childLead.Lead_Status__c) ? childLead.Lead_Status__c : 'New';
                childLead.RecordTypeId = childLead.RecordTypeId == partnerChildLeadRecordTypeId ? partnerChildLeadRecordTypeId : BulkUploadChildLeadsHelper.getChildLeadRecordTypeId(childLead);
                emailSet.add(childLead.Email__c);
                campaignIdSet.add(childLead.Campaign_Name__c);
            }
        }
        
        if(!emailSet.isEmpty() && !campaignIdSet.isEmpty()){
            emailChildLeadMap = searchForDuplicateChildLeads(emailSet, campaignIdSet);
            emailCampaignMemberMap = searchForCampaignMembers(emailSet, campaignIdSet);
            emailMasterLeadsMap = searchMasterLeads(emailSet);
            emailContactsMap = searchContacts(emailSet);
            BulkUploadChildLeadsHelper.buildCampaignMap(campaignIdSet);
        }
                
        childLeadValidation(newChildLeadsList);
        
    }
    
/**     
* @description Add Parent Lead or Contact to the Campaign
* @param newChildLeadsList - Accepts list of child lead emails of the new child lead records
*/
    public static void addLeadOrContactToTheCampaign(List<Child_Lead__c> newChildLeadsList){
        
        Set<String> emailSet = new Set<String>();
        List<Child_Lead__c> childLeads = new List<Child_Lead__c>();
        
        for(Child_Lead__c childLead : newChildLeadsList){
            if(childLead.Email__c != null && !childLead.ByPass_Trigger__c){
                emailSet.add(childLead.Email__c);
                childLeads.add(childLead);
            }
        }

        BulkUploadChildLeadsHelper.setCampaignMembersAndMasterLeadsToCreate(emailMasterLeadsMap, emailContactsMap, childLeads, emailCampaignMemberMap);
        if(!leadInterestToActivate.isEmpty()){
            ActivateLeadInterest activateLead = new ActivateLeadInterest(leadInterestToActivate,UserInfo.getUserEmail());
			ID batchprocessid = Database.executeBatch(activateLead);
        }
    }
    
/**     
* @description  Search for the duplicates in the existing child lead records based on the email and campaign of the new child leads
* @param emailSet - Accepts set of the emails of the new child lead records
* @param campaignIdSet - Accepts set of the campaign ids of the new child lead records
* @return Map<String, Child_Lead__c> - Map of child lead records (email and campaign as key)
*/
    private static Map<String, Child_Lead__c> searchForDuplicateChildLeads(Set<String> emailSet, Set<String> campaignIdSet){
        
        Map<String, Child_Lead__c> emailCampaignMap = new Map<String, Child_Lead__c>();
        for(Child_Lead__c childLead : [SELECT Id, Name, Email__c, Campaign_Name__c, Lead_Status__c,Active__c FROM Child_Lead__c
                                       WHERE Lead_Status__c != 'Qualified' AND Email__c IN: emailSet AND Campaign_Name__c IN: campaignIdSet]){
            emailCampaignMap.put(childLead.Email__c+'-'+childLead.Campaign_Name__c, childLead);
        }
        return emailCampaignMap;
    }
    
/**     
* @description Search for the duplicates in the existing campaign member records based on the email and campaign of the new campaign members
* @param emailSet - Accepts set of the emails of the new campaign member records
* @param campaignIdSet - Accepts set of the campaign ids of the new campaign member records
* @return Map<String, CampaignMember> - Map of Campaign Member records (email and campaign as key)
*/
    private static Map<String, CampaignMember> searchForCampaignMembers(Set<String> emailSet, Set<String> campaignIdSet){
        
        Map<String, CampaignMember> emailCampaignMemberMap = new Map<String, CampaignMember>();
        for(CampaignMember campMem : [SELECT Id, Name, Email, CampaignId, Campaign.Name FROM CampaignMember
                                       WHERE Email IN: emailSet AND CampaignId IN: campaignIdSet]){
            emailCampaignMemberMap.put(campMem.Email+'-'+campMem.CampaignId, campMem);
        }
        return emailCampaignMemberMap;
    }
    
/**     
* @description Throw the error if the duplicate child lead is found (or) multiple leads (or) multiple contacts (or) both lead and contact found with the same email
* @param newChildLeadsList - Accepts set of the emails of the new child lead records
*/
    private static void childLeadValidation(List<Child_Lead__c> newChildLeadsList){
        
        String tempKey;
        for(Child_Lead__c childLead : newChildLeadsList){
            tempKey = childLead.Email__c+'-'+childLead.Campaign_Name__c;
            if(String.isBlank(childLead.Company__c)){
                childLead.addError('Please fill the Company.');
            }else if(emailChildLeadMap.containsKey(tempKey)){
                if(emailChildLeadMap.get(tempKey).Active__c == false){
                    childLead.addError('Unable to create a new lead interest. Duplicate lead interest already exist with the same email provided for the campaign. \nDetails- Name : '+emailChildLeadMap.get(tempKey).Name+', Id : '+emailChildLeadMap.get(tempKey).Id+'. \nExisting inactive lead interest record will be activated instead of creating new record');
                    leadInterestToActivate.add(emailChildLeadMap.get(tempKey).Id);
                }else{
                    childLead.addError('Duplicate Lead Interest Found - Name : '+emailChildLeadMap.get(tempKey).Name+', Status : '+emailChildLeadMap.get(tempKey).Lead_Status__c+', Id : '+emailChildLeadMap.get(tempKey).Id);
                }
                
            }else{
                BulkUploadChildLeadsHelper.validateChildLead(childLead, emailMasterLeadsMap, emailContactsMap);
            }
        }
    }
    
/**     
* @description Search for Master Lead Record by filtering with the Child Lead Email
* @param emailSet - Set of Child Lead records' Emails
* @return Map<String, List<Lead>> - Map of list of lead records (email as key)
*/
    private static Map<String, List<Lead>> searchMasterLeads(Set<String> emailSet){
        
        Map<String, List<Lead>> emailWithLeadIdMap = new Map<String, List<Lead>>();
        
        for(Lead leadRecord : [SELECT Id, FirstName, LastName, Email, Company FROM Lead WHERE RecordType.DeveloperName = 'Master_Lead'  AND Email IN: emailSet AND IsConverted = false]){
            if(!emailWithLeadIdMap.containsKey(leadRecord.Email)){
                emailWithLeadIdMap.put(leadRecord.Email, new List<Lead>{leadRecord});
            }else{
                emailWithLeadIdMap.get(leadRecord.Email).add(leadRecord);
            }
        }
        return emailWithLeadIdMap;
    }
    
/**     
* @description Search for Contact Record by filtering with the Child Lead Email
* @param emailSet - Set of Child Lead records' Emails
* @return Map<String, List<Contact>> - Map of list of contact records (email as key)
*/
    private static Map<String, List<Contact>> searchContacts(Set<String> emailSet){
        
        Map<String, List<Contact>> emailWithContactIdMap = new Map<String, List<Contact>>();
        
        for(Contact contactRecord : [SELECT Id, FirstName, LastName, Email, Account.Name, AccountId FROM Contact WHERE RecordType.DeveloperName = 'BGI_Contact'  AND Email IN: emailSet]){
            if(!emailWithContactIdMap.containsKey(contactRecord.Email)){
                emailWithContactIdMap.put(contactRecord.Email, new List<Contact>{contactRecord});
            }else{
                emailWithContactIdMap.get(contactRecord.Email).add(contactRecord);
            }
        }
        return emailWithContactIdMap;
    }
    
    
}