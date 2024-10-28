/**       
@Name           - ChildLeadRoutingHelper
@Author         - Praneeth Krishna | Email - Praneeth.krishna@frieslandcampina.com
@Version        - 1.0
@CreatedDate    - 28-02-2023
@UsedBy         - Apex Class - ChildLeadRouting

UserId              | Author-Email                          | Date       | Comment
====================|=====================================  |============|==============
0054H000007nyPTQAY  | Praneeth.krishna@frieslandcampina.com | 28-02-2023 | Created class
0054H000007nyPTQAY  | Praneeth.krishna@frieslandcampina.com | 13-04-2023 | Updated class
--------------------|-------------------------------------  |------------|--------------

* @description Assigns childlead owner based on business segment and region -helper class
*/

public without sharing class ChildLeadRoutingHelper {

/**     
* @description  Fetch metadata records used for lead routing process
* @return       regionQueuesMap 
*/ 

    public static Map<String,String> getQueueMetadata(){   
        Map<String,String> regionQueuesMap = new Map<String,String>();     
        List<Lead_Queues_Metadata__mdt> queuesList = [SELECT Business_Segment_Region__c,Queue__c FROM Lead_Queues_Metadata__mdt];        
        for(Lead_Queues_Metadata__mdt record : queuesList){
            regionQueuesMap.put(record.Business_Segment_Region__c.trim(),record.Queue__c.trim());
        }	
        return regionQueuesMap;
    }


/**     
* @description  get user record from account teams based on account,business segment match
* @param        NAME:accid DESCRIPTION: Accepts Account id
* @param        NAME:businessSegment DESCRIPTION: Accepts Account Business Segment
* @return       AccountTeamMember 
*/ 

    public static List<Account_Team__c> getUserFromAccountTeams(Id accid, string businessSegment){
        return [SELECT Id,Team_Member__c,Team_Member__r.IsActive from Account_Team__c where Team_Role__c = 'Sales Manager' and Primary__c=true
                and Source_Account__c =:accid and Business_Segment__c =:businessSegment and Team_Member__r.IsActive = true and Team_Member__r.name not in ('API User','SAP PO User')];
    }
    

/**     
* @description   Get queue id based on the queuename framed
* @param        NAME:queueName DESCRIPTION: Accepts Queue Name 
* @return       Id 
*/ 
    public static Id getQueueId(string queueName){
        return [SELECT Id, Name, DeveloperName,Type FROM Group WHERE Type = 'Queue' AND DeveloperName = :queueName].id;
    }


/**     
* @description  check if user is active and not of api user/sap po user
* @param        NAME:leadRec DESCRIPTION: Accepts child Lead record of sObject type
* @param        NAME:acc DESCRIPTION: Accepts account record
* @param        NAME:regionQueuesMap DESCRIPTION: Accepts map of the region based queues
*/ 
    public static void checkAccountOnwerStatus(Child_Lead__c leadRec, Account acc, String regionFilter ){
        Map<String,String>  regionQueuesMap = getQueueMetadata();        
        if(acc.Owner.isActive && acc.Owner.Name != 'SAP PO User' && acc.Owner.Name != 'API User' && leadRec.Business_Segment__c == acc.Owner.Business_Segment__c){
            leadRec.OwnerId = acc.OwnerId;
        }else{
            if(regionQueuesMap.containsKey(regionFilter+','+'Misrouted')){
              leadRec.OwnerId =  getQueueId(regionQueuesMap.get(regionFilter+','+'Misrouted'));
            } 
        }        
        if(acc.RecordType.DeveloperName == 'BGI_Customer_Location'){
            leadRec.Customer_Segment__c = acc.Sales_Area__c != null ? acc.Sales_Area__c : '';
            leadRec.Parent_Account__c = acc.ParentId;
        }
        if(acc.RecordType.DeveloperName == 'BGI_End_Customer'){    
            if( acc.Distributor_Location__c != null && acc.Distributor_Location__r.Active__c){
                leadRec.Distributor_Account_Name__c = acc.Distributor_Location__c;  
                leadRec.Distributor_Parent_Account__c = acc.Distributor__c != null ? acc.Distributor__c : null;
            }           
        }
    }           

/**     
* @description  check whether child lead company matches with account of record type customer location and assign owner
* @param        NAME:leadRec DESCRIPTION: Accepts child Lead record of sObject type
* @param        NAME:companyCustomerLocationMap DESCRIPTION: Accepts map of lead company & account records of record type customer location
* @param        NAME:regionQueuesMap DESCRIPTION: Accepts map of the region based queues
*/ 
    public static void handleCompanyCustomerLocation(Child_Lead__c leadRec,Map<String,List<Account>> companyCustomerLocationMap,String regionFilter) {
        Map<String,String>  regionQueuesMap = getQueueMetadata();
        Boolean checkRegion =  regionQueuesMap.containsKey(regionFilter+','+'Misrouted');
        Account[] matchedAccounts = companyCustomerLocationMap.get(leadRec.Company__c);
        if (matchedAccounts.size() > 1 && checkRegion) {
            leadRec.OwnerId = getQueueId(regionQueuesMap.get(regionFilter + ',' + 'Misrouted'));
        } else {
            Account matchedAccount = matchedAccounts[0];
            List<Account_Team__c> atm =  getUserFromAccountTeams(matchedAccount.id, leadRec.Business_Segment__c);    
            if (atm.size() == 1) {
                leadRec.OwnerId = atm[0].Team_Member__c;
            } else if (matchedAccount.Owner.isActive && matchedAccount.Owner.Name !='SAP PO User' 
                        && matchedAccount.Owner.Name !='API User' && leadRec.Business_Segment__c == matchedAccount.Owner.Business_Segment__c) {
                leadRec.OwnerId = matchedAccount.OwnerId;
            } else if (checkRegion) {
                leadRec.OwnerId = getQueueId(regionQueuesMap.get(regionFilter + ',' + 'Misrouted'));
            }
    
            leadRec.Customer_Segment__c = matchedAccount.Sales_Area__c != null ? matchedAccount.Sales_Area__c : '';
            leadRec.Parent_Account__c = matchedAccount.ParentId;
        }
    }

    /**     
* @description  check whether child lead company matches with account of record type prospect and assign owner
* @param        NAME:leadRec DESCRIPTION: Accepts child Lead record of sObject type
* @param        NAME:companyProspectMap DESCRIPTION: Accepts map of lead company & account records of prospect record type
* @param        NAME:regionQueuesMap DESCRIPTION: Accepts map of the region based queues
*/ 
public static void handleCompanyProspect(Child_Lead__c leadRec, Map<String,List<Account>> companyProspectMap, String regionFilter) {
    Map<String,String>  regionQueuesMap = getQueueMetadata();
    Account acc = companyProspectMap.get(leadRec.Company__c)[0];
    if(companyProspectMap.get(leadRec.Company__c).size() == 1 && acc.Owner.isActive && acc.Owner.Name !='SAP PO User'
         && acc.Owner.Name !='API User' && leadRec.Business_Segment__c == acc.Owner.Business_Segment__c){
        leadRec.OwnerId = acc.OwnerId;
    }else if(regionQueuesMap.containsKey(regionFilter+','+'Misrouted')){
        leadRec.OwnerId = getQueueId(regionQueuesMap.get(regionFilter+','+'Misrouted'));
    }    
}


/**     
* @description  check whether child lead company matches with account of record type end customer and assign owner
* @param        NAME:leadRec DESCRIPTION: Accepts child Lead record of sObject type
* @param        NAME:companyEndCustomerMap DESCRIPTION: Accepts map of lead company & account records of end customer record type
* @param        NAME:regionQueuesMap DESCRIPTION: Accepts map of the region based queues
*/ 
    public static void handleCompanyEndCustomer(Child_Lead__c leadRec, Map<String,List<Account>> companyEndCustomerMap,String regionFilter) {
        Id partnerLeadRTId = Schema.SObjectType.Child_Lead__c.getRecordTypeInfosByDeveloperName().get('Partner_Child_Lead').getRecordTypeId();
        Map<String,String>  regionQueuesMap = getQueueMetadata();
        Boolean checkRegion =  regionQueuesMap.containsKey(regionFilter+','+'Misrouted');
        if(companyEndCustomerMap.get(leadRec.Company__c).size() > 1 && checkRegion){
            leadRec.OwnerId = getQueueId(regionQueuesMap.get(regionFilter+','+'Misrouted'));
            leadRec.RecordTypeId = partnerLeadRTId;                 
        }else{
            Account matchedAccount = companyEndCustomerMap.get(leadRec.Company__c)[0];
            if( matchedAccount.Distributor_Location__c != null && matchedAccount.Distributor_Location__r.Active__c){               
                leadRec.Distributor_Account_Name__c =  matchedAccount.Distributor_Location__c;
                leadRec.Distributor_Parent_Account__c = matchedAccount.Distributor__c != null ? matchedAccount.Distributor__c : null;
            }           
            if((matchedAccount.Owner.Name=='SAP PO User' || matchedAccount.Owner.Name=='API User' ) && checkRegion ){
                leadRec.OwnerId = getQueueId(regionQueuesMap.get(regionFilter+','+'Misrouted'));                
            }else if(matchedAccount.Owner.isActive && leadRec.Business_Segment__c == matchedAccount.Owner.Business_Segment__c){
                leadRec.OwnerId = matchedAccount.OwnerId;                
            } else if (checkRegion){
                leadRec.OwnerId = getQueueId(regionQueuesMap.get(regionFilter+','+'Misrouted'));
            }                        
            leadRec.RecordTypeId = partnerLeadRTId;            
        }    
    }
    
    



/**     
* @description  Update and commit lead onwer change to database
* @param        NAME:updateLeads DESCRIPTION: Accepts list of child lead records
*/ 
    public static void leadsUpdate(List<Child_Lead__c> updateLeads){
        Database.SaveResult[] srList = database.update(updateLeads,false);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {       
                        DebugLogUtility.DebugLogWrapper logWrapObj = new DebugLogUtility.DebugLogWrapper('Child Lead','Child_Lead__c','Apex Class','ChildLeadRoutingHelper','leadsUpdate-AssignOwner','Error');
            			DebugLog__c logRecord = DebugLogUtility.logError( Id.valueOf(sr.getId()),err.getMessage(),''+err.getStatusCode(), logWrapObj);
           				insert logRecord;
                    }                     
                }
            }
    }
}