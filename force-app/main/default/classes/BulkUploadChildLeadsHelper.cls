/**       
@Name           - BulkUploadChildLeadsHelper
@Author         - Mahendra Kumar | Email - mahendra.kumar@frieslandcampina.com
@Version        - 1.0
@CreatedDate    - 10-04-2023
@UsedBy         - ApexClass - BulkUploadChildLeads

UserId              | Author-Email                        | Date       | Comment
====================|=====================================|============|==============
0058E000009TanLQAS  | mahendra.kumar@frieslandcampina.com | 10-04-2023 | Created class
--------------------|-------------------------------------|------------|--------------

* @description Child Leads bulk upload process
*/
public without sharing class BulkUploadChildLeadsHelper {
    
    static Id masterLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Master_Lead').getRecordTypeId();
    static Id fciChildLeadRecordTypeId = Schema.SObjectType.Child_Lead__c.getRecordTypeInfosByDeveloperName().get('FCI_Child_Lead').getRecordTypeId();
    static Id fcpChildLeadRecordTypeId = Schema.SObjectType.Child_Lead__c.getRecordTypeInfosByDeveloperName().get('FCP_Child_Lead').getRecordTypeId();
    static final Set<String> fciBusinessSegments = new Set<String>{'Adult Nutrition', 'Early Life Nutrition & Cell Nutrition'};
    static final Set<String> fcpBusinessSegments = new Set<String>{'APAC', 'China', 'HoB', 'Industry', 'QSR EU'};
    static Map<Id, Campaign> campaignMap = new Map<Id, Campaign>();
    
    /**     
* @description Instantiate Campaign Member and Lead Records that needs to be created
* @param emailWithLeadIdMap - Map(key = Email, value = List of Master Leads found in the database)
* @param emailWithContactIdMap - Map(key = Email, value = List of Contacts found in the database)
* @param childLeads - Accepts the List of Child Lead records
* @param emailCampaignMemberMap - Accepts Map of String and CampaignMember
*/
    public static void setCampaignMembersAndMasterLeadsToCreate(Map<String, List<Lead>> emailWithLeadIdMap, Map<String, List<Contact>> emailWithContactIdMap, List<Child_Lead__c> childLeads, Map<String, CampaignMember> emailCampaignMemberMap){
        
        List<CampaignMember> campMemberList = new List<CampaignMember>();
        Map<String, Lead> masterLeadsToCreateMap = new Map<String, Lead>();
        Map<String, Id> masterLeadIdMap = new Map<String, Id>();
        Map<String, Id> newMasterLeadsMap = new Map<String, Id>();
        List<Child_Lead__c> childLeadsToBeUpdated = new List<Child_Lead__c>();
        List<Child_Lead__c> updateChildLeadsList = new List<Child_Lead__c>();

        String firstName = '',
            lastName = '',
            campaignName = '';
        
        for(Child_Lead__c childLead : childLeads){
            Child_Lead__c childLeadRecord = new Child_Lead__c();
            
            String leadOrContactId = emailWithLeadIdMap.containsKey(childLead.Email__c) ? String.valueOf(emailWithLeadIdMap.get(childLead.Email__c)[0].Id) :
            (emailWithContactIdMap.containsKey(childLead.Email__c) ? String.valueOf(emailWithContactIdMap.get(childLead.Email__c)[0].Id) : '');
                
                if(!(emailWithLeadIdMap.containsKey(childLead.Email__c) && emailWithContactIdMap.containsKey(childLead.Email__c))){
                    system.debug('$$$$$$$$MAPEMAIL'+emailWithLeadIdMap.get(childLead.Email__c));
                    system.debug('$$$$$$$$MAPFname'+emailWithLeadIdMap.get(childLead.Email__c)[0].FirstName);
                    system.debug('$$$$$$$$MAP.Lname'+emailWithLeadIdMap.get(childLead.Email__c)[0].LastName);
                    firstName =  emailWithLeadIdMap.containsKey(childLead.Email__c) ? emailWithLeadIdMap.get(childLead.Email__c)[0].FirstName : (emailWithContactIdMap.containsKey(childLead.Email__c) ? emailWithContactIdMap.get(childLead.Email__c)[0].FirstName : childLead.First_Name__c);
                    lastName = emailWithLeadIdMap.containsKey(childLead.Email__c) ? emailWithLeadIdMap.get(childLead.Email__c)[0].LastName : (emailWithContactIdMap.containsKey(childLead.Email__c) ? emailWithContactIdMap.get(childLead.Email__c)[0].LastName : childLead.Last_Name__c);
                    campaignName = campaignMap.containsKey(childLead.Campaign_Name__c) ? campaignMap.get(childLead.Campaign_Name__c).Name.trim() : '';
                    childLeadRecord.Id = childLead.Id;
                    system.debug('$$$$$$ LeadInterest FName'+firstName);
                    system.debug('$$$$$$ LeadInterest LName'+lastName);
                    system.debug('$$$$$$ LeadInterest Name'+campaignName);
           
                    childLeadRecord.Name = ('LI - '+ firstName.trim() + ' ' + lastName.trim() + ' - ' + campaignName).left(80);
                    childLeadRecord.Email__c = childLead.Email__c;
                    childLeadRecord.First_Name__c = firstName;
                    childLeadRecord.Last_Name__c = lastName;
                    childLeadRecord.Company__c = emailWithLeadIdMap.containsKey(childLead.Email__c) ? emailWithLeadIdMap.get(childLead.Email__c)[0].Company : (emailWithContactIdMap.containsKey(childLead.Email__c) ? emailWithContactIdMap.get(childLead.Email__c)[0].Account.Name : childLead.Company__c);
                    childLeadRecord.Campaign_Name__c = childLead.Campaign_Name__c;
                    childLeadRecord.Related_Account__c = emailWithContactIdMap.containsKey(childLead.Email__c) ? emailWithContactIdMap.get(childLead.Email__c)[0].AccountId : null;
                }
            
            if(
                (
                    (emailWithLeadIdMap.containsKey(childLead.Email__c) && emailWithLeadIdMap.get(childLead.Email__c).size() == 1) || 
                    (emailWithContactIdMap.containsKey(childLead.Email__c) && emailWithContactIdMap.get(childLead.Email__c).size() == 1)
                ) && 
                !emailCampaignMemberMap.containsKey(childLead.Email__c+'-'+childLead.Campaign_Name__c)
            ){
                CampaignMember campMem = new CampaignMember(
                    LeadId = leadOrContactId.startsWith('00Q') ? Id.valueOf(leadOrContactId) : null,
                    ContactId = leadOrContactId.startsWith('003') ? Id.valueOf(leadOrContactId) : null,
                    CampaignId = childLead.Campaign_Name__c,
                    Status = 'Manual',
                    Do_Not_Create_Child_Lead__c = true
                );
                campMemberList.add(campMem);
                masterLeadIdMap.put(childLead.Email__c, leadOrContactId);
                childLeadsToBeUpdated.add(childLeadRecord);
            }else if(!(emailWithLeadIdMap.containsKey(childLead.Email__c) && emailWithContactIdMap.containsKey(childLead.Email__c))){
                Lead masterLead = new Lead(
                    FirstName = childLead.First_Name__c,
                    LastName = childLead.Last_Name__c,
                    Company = childLead.Company__c,
                    Email = childLead.Email__c,
                    RecordTypeId = masterLeadRecordTypeId,
                    Active__c = true
                );
                
                updateChildLeadsList.add(childLeadRecord);
                masterLeadsToCreateMap.put(childLead.Email__c, masterLead);
            }
        }

        insertCampaignMembers(new Set<CampaignMember>(campMemberList));
        insertMasterLeads(new Set<Lead>(masterLeadsToCreateMap.values()), newMasterLeadsMap);
        updateChildLeadsWithCampaignMembers(childLeadsToBeUpdated, masterLeadIdMap);
        updateChildLeads(updateChildLeadsList, newMasterLeadsMap);
    }
    
    /**     
* @description Add the Master Lead (or) Contact (which was found in the database) to the Campaign
* @param campaignMembersToCreateSet - Accepts the set of Campaign Member records which needs to be created
*/
    private static void insertCampaignMembers(Set<CampaignMember> campaignMembersToCreateSet){
        
        List<CampaignMember> campaignMembersToCreate = new List<CampaignMember>(campaignMembersToCreateSet);
        
        List<Database.SaveResult> campaignMembersResultList = new List<Database.SaveResult>();
        
        if(!campaignMembersToCreate.isEmpty()){
            campaignMembersResultList = Database.insert(campaignMembersToCreate, false);
        }
        
        DebugLogUtility.DebugLogWrapper logWrapObj = new DebugLogUtility.DebugLogWrapper('Campaign Member','CampaignMember','Apex Class','BulkUploadChildLeadsHelper','insertCampaignMembers','Error');
        logErrors(campaignMembersResultList, logWrapObj, 'When inserting Campaign Member Record');
    }
    
    /**     
* @description Create Master Leads which are not found in the database
* @param masterLeadsToCreateSet - Accepts the set of lead records which needs to be created
* @param newMasterLeadsMap - Map (key = Email, value = newly inserted master lead record id)
*/
    private static void insertMasterLeads(Set<Lead> masterLeadsToCreateSet, Map<String, Id> newMasterLeadsMap){
        
        List<DebugLog__c> errorLogs = new List<DebugLog__c>();
        List<Database.SaveResult> masterLeadsResultList = new List<Database.SaveResult>();
        List<Lead> masterLeadsToCreate = new List<Lead>(masterLeadsToCreateSet);
        
        if(!masterLeadsToCreate.isEmpty()){
            masterLeadsResultList = Database.insert(masterLeadsToCreate, false);
        }
        
        for(Integer i=0; i < masterLeadsResultList.size(); i++){
            if(masterLeadsResultList[i].isSuccess()){
                newMasterLeadsMap.put(masterLeadsToCreate[i].Email, masterLeadsResultList[i].getId());
            } else {
                for(Database.Error err : masterLeadsResultList[i].getErrors()) {
                    DebugLogUtility.DebugLogWrapper logWrapObj = new DebugLogUtility.DebugLogWrapper('Lead','Lead__c','Apex Class','BulkUploadChildLeadsHelper','insertMasterLeads','Error');
                    DebugLog__c logRecord = DebugLogUtility.logError(string.valueof(masterLeadsToCreate[i]), err.getStatusCode()+': '+err.getMessage(), 'When inserting Master Lead Record', logWrapObj);
                    errorLogs.add(logRecord);
                }
            }    
        }
        
        if(!errorLogs.isEmpty()){
            insert errorLogs;
        }
    }
    
    /**     
* @description Insert Campaign Members and Associate the Child Lead Records with Related Parent Lead
* @param childLeads - Accepts the list of child lead records which needs to be associated to the Master Lead
* @param newMasterLeadsMap - Map (key = Email, value = newly inserted master lead record id)
*/
    private static void updateChildLeads(List<Child_Lead__c> childLeads, Map<String, Id> newMasterLeadsMap){
        
        List<Child_Lead__c> childLeadsToUpdate = new List<Child_Lead__c>();
        List<CampaignMember> campMemList = new List<CampaignMember>();
        
        for(Child_Lead__c childLead : childLeads){
            
            CampaignMember campMem = new CampaignMember(
                LeadId = newMasterLeadsMap.containsKey(childLead.Email__c) ? newMasterLeadsMap.get(childLead.Email__c) : null,
                CampaignId = childLead.Campaign_Name__c,
                Status = 'Manual',
                Do_Not_Create_Child_Lead__c = true
            );
            campMemList.add(campMem);
            
            Child_Lead__c childLeadRecord = new Child_Lead__c(
                Id = childLead.Id,
                Name = childLead.Name,
                First_Name__c = childLead.First_Name__c,
                Last_Name__c = childLead.Last_Name__c,
                Company__c = childLead.Company__c,
                Related_Master_Lead__c = newMasterLeadsMap.containsKey(childLead.Email__c) ? newMasterLeadsMap.get(childLead.Email__c) : null
            );
            childLeadsToUpdate.add(childLeadRecord);
        }
        
        insertCampaignMembers(new Set<CampaignMember>(campMemList));
        
        List<Database.SaveResult> childLeadsResultList = new List<Database.SaveResult>();
        
        if(!childLeadsToUpdate.isEmpty()){
            childLeadsResultList = Database.update(childLeadsToUpdate, false);
        }
        
        DebugLogUtility.DebugLogWrapper logWrapObj = new DebugLogUtility.DebugLogWrapper('Lead Interest','Child_Lead__c','Apex Class','BulkUploadChildLeadsHelper','updateChildLeads','Error');
        logErrors(childLeadsResultList, logWrapObj, 'When updating Lead Interest Record');
    }
    
    /**     
* @description Associate the Child Lead Records with Related Parent Lead
* @param childLeads - Accepts the list of child lead records which needs to be associated to the Master Lead
* @param masterLeadIdMap - Map (key = Email, value = newly inserted master lead record id)
*/
    private static void updateChildLeadsWithCampaignMembers(List<Child_Lead__c> childLeads, Map<String, Id> masterLeadIdMap){
        
        List<Child_Lead__c> childLeadsToUpdate = new List<Child_Lead__c>();
        
        for(Child_Lead__c childLead : childLeads){
            
            Child_Lead__c childLeadRecord = new Child_Lead__c(
                Id = childLead.Id,
                Name = childLead.Name,
                First_Name__c = childLead.First_Name__c,
                Last_Name__c = childLead.Last_Name__c,
                Company__c = childLead.Company__c,
                Related_Master_Lead__c = masterLeadIdMap.containsKey(childLead.Email__c) && String.valueOf(masterLeadIdMap.get(childLead.Email__c)).startsWith('00Q') ? masterLeadIdMap.get(childLead.Email__c) : null,
                Related_Contact__c = masterLeadIdMap.containsKey(childLead.Email__c) && String.valueOf(masterLeadIdMap.get(childLead.Email__c)).startsWith('003') ? masterLeadIdMap.get(childLead.Email__c) : null,
                Is_Existing_Contact_Lead__c = masterLeadIdMap.containsKey(childLead.Email__c) && String.valueOf(masterLeadIdMap.get(childLead.Email__c)).startsWith('003') ? true : false,
                Related_Account__c = childLead.Related_Account__c
            );
            childLeadsToUpdate.add(childLeadRecord);
        }
                
        List<Database.SaveResult> childLeadsResultList = new List<Database.SaveResult>();
        
        if(!childLeadsToUpdate.isEmpty()){
            childLeadsResultList = Database.update(childLeadsToUpdate, false);
        }
        
        DebugLogUtility.DebugLogWrapper logWrapObj = new DebugLogUtility.DebugLogWrapper('Lead Interest','Child_Lead__c','Apex Class','BulkUploadChildLeadsHelper','updateChildLeadsWithCampaignMembers','Error');
        logErrors(childLeadsResultList, logWrapObj, 'When updating Lead Interest Record');
    }
    
    /**     
* @description Log the errors when inserting or updating the records
* @param srList - Result List of Database.insert (or) Database.update
* @param logWrapObj - ErrorLog Wrapper record
* @param comments - comments about the error
*/
    private static void logErrors(Database.SaveResult[] srList, DebugLogUtility.DebugLogWrapper logWrapObj, string comments){
        List<DebugLog__c> errorLogs = new List<DebugLog__c>();
        
        for(Integer i=0; i < srList.size(); i++){
            if(!srList[i].isSuccess()){
                for(Database.Error err : srList[i].getErrors()) {
                    DebugLog__c logRecord = DebugLogUtility.logError(string.valueof(srList[i]), err.getStatusCode()+': '+err.getMessage(), comments, logWrapObj);
                    errorLogs.add(logRecord);
                }
            }
        }
        
        if(!errorLogs.isEmpty()){
            insert errorLogs;
        }
    }
    
    /**     
* @description Build Campaign Map based on the set of campaign ids passed
* @param campaignIdSet - Accepts the set of campaign ids
*/
    public static void buildCampaignMap(Set<String> campaignIdSet){
        campaignMap = new Map<Id, Campaign>([SELECT Id, Name FROM Campaign WHERE Id IN: campaignIdSet]);
    }
    
    /**     
* @description Returns the Child Lead Record Type Id based on the business segment of the child lead
* @param campaignIdSet - Accepts the Child Lead Record
* @return Id - Child Lead Record Type Id
*/
    public static Id getChildLeadRecordTypeId(Child_Lead__c childLead){
        Id childLeadRecordTypeId = fciBusinessSegments.contains(childLead.Business_Segment__c) ? fciChildLeadRecordTypeId : (fcpBusinessSegments.contains(childLead.Business_Segment__c) ? fcpChildLeadRecordTypeId : childLead.RecordTypeId);
            return childLeadRecordTypeId;
    }
    
    /**     
* @description Build Campaign Map based on the set of campaign ids passed
* @param childLead - Child Lead record that needs to be validated
* @param emailWithLeadIdMap - Accepts the map of email and list of leads(matched with the child lead email) (email as key)
* @param emailWithContactIdMap - Accepts the map of email and list of contacts(matched with the child lead email) (email as key)
*/
    public static void validateChildLead(Child_Lead__c childLead, Map<String, List<Lead>> emailWithLeadIdMap, Map<String, List<Contact>> emailWithContactIdMap){
            if(emailWithLeadIdMap.containsKey(childLead.Email__c) && emailWithContactIdMap.containsKey(childLead.Email__c)){
                childLead.addError('Lead Interest cannot be created. Both the Lead and Contact exists with the same email. Email : '+childLead.Email__c);
            }else if(emailWithLeadIdMap.containsKey(childLead.Email__c) && emailWithLeadIdMap.get(childLead.Email__c).size() > 1){
                childLead.addError('Lead Interest cannot be created. Multiple leads exist with the same email. Email : '+childLead.Email__c);
            }else if(emailWithContactIdMap.containsKey(childLead.Email__c) && emailWithContactIdMap.get(childLead.Email__c).size() > 1){
                childLead.addError('Lead Interest cannot be created. Multiple contacts exist with the same email. Email : '+childLead.Email__c);
            }
    }
}