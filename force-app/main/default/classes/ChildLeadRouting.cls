/**       
@Name           - ChildLeadRouting
@Author         - Praneeth Krishna | Email - Praneeth.krishna@frieslandcampina.com
@Version        - 1.0
@CreatedDate    - 28-02-2023
@UsedBy         - Trigger - ChildLeadTriggerHandler

UserId              | Author-Email                          | Date       | Comment
====================|=====================================  |============|==============
0054H000007nyPTQAY  | Praneeth.krishna@frieslandcampina.com | 28-02-2023 | Created class
0054H000007nyPTQAY  | Praneeth.krishna@frieslandcampina.com | 13-04-2023 | Updated class
--------------------|-------------------------------------  |------------|--------------

* @description child Lead routing process based on business segment and region 
*/

public without sharing class ChildLeadRouting {
    public static List<Account> allAccountList;
    public static List<Account> commercialCustomerList;
    public static List<Account> customerLocationList;
    public static List<Account> endCustomerList;
    public static List<Account> prospectCustomerList;
    public static Map<String,List<Account>> companycommercialCustomerMap;
    public static Map<String,List<Account>> companyCustomerLocationMap;
    public static Map<String,List<Account>> companyEndCustomerMap;
    public static Map<String,List<Account>> companyProspectMap;
    public static Map<String,String> regionQueuesMap;
    public static List<Child_Lead__c> updateLeads;
    public static Id partnerLeadRTId = Schema.SObjectType.Child_Lead__c.getRecordTypeInfosByDeveloperName().get('Partner_Child_Lead').getRecordTypeId();
    public static List<string> fciBusinessSegmentList = new List<string> { 'Adult Nutrition','Early Life Nutrition & Cell Nutrition' };

/**     
* @description  Fetch child lead records related to contact/Lead where business segment is not blank and record type not equal to partner child lead
* @param        NAME:leads DESCRIPTION: Accepts map of the id,child leads of child lead Object
*/     
    public static void assignLeadOwner(Map<ID,Child_Lead__c> leads){
        List<Child_Lead__c> leadRecords = new List<Child_Lead__c>();
        List<Child_Lead__c> contactRelatedleadRecords = new List<Child_Lead__c>();
        List<String>  userIds =new List<String> ();
        List<String> stepUpNutritionCampaigns = new List<String>();
        updateLeads = new List<Child_Lead__c>();    
        userIds = System.Label.PardotUserId.trim().split(',');
        stepUpNutritionCampaigns = System.Label.Step_Up_Nutrition_Campaigns?.trim().split(',');

        List<Child_Lead__c> newLeads = [SELECT Id, Company__c, recordTypeID, Business_Segment__c, Related_Master_Lead__c, Related_Contact__c, Related_Contact__r.AccountId, Region__c, OwnerId FROM Child_Lead__c WHERE Id IN :leads.keySet() AND Company__c != null AND recordTypeID != :partnerLeadRTId AND Business_Segment__c != '' AND OwnerId IN :userIds AND Campaign_Name__c NOT IN :stepUpNutritionCampaigns];
        
        for(Child_Lead__c currentRecord : newLeads){
            if(currentRecord.Related_Master_Lead__c != null && currentRecord.Related_Contact__c == null) {
                leadRecords.add(currentRecord);
            } else if(currentRecord.Related_Master_Lead__c == null && currentRecord.Related_Contact__c != null) {
                contactRelatedleadRecords.add(currentRecord);
            }
        }
        regionQueuesMap = ChildLeadRoutingHelper.getQueueMetadata();
        if(leadRecords.size() > 0){           
            for(Child_Lead__c cl : leadRecords){
                getAccountList('%'+cl.Company__c+'%');
                getMatchedAccountList(cl.Company__c);                
                updateLeadOwner(cl);
            }         
        }
        if(contactRelatedleadRecords.size() > 0){
            for(Child_Lead__c cl : contactRelatedleadRecords){
                updateContactLeadOwner(cl);
            }
        }     
        if( updateLeads.size() > 0){
            ChildLeadRoutingHelper.leadsUpdate(updateLeads);
        }
    }


/**     
* @description  update owner for childlead related to lead
* @param        NAME:leadRec DESCRIPTION: Accepts child lead sObject
*/   
     public static void updateLeadOwner(Child_Lead__c leadRec) {
        String businessSegment = fciBusinessSegmentList.contains(leadRec.Business_Segment__c) ? leadRec.Business_Segment__c : 'Industry';
        String regionFilter = leadRec.Region__c == null ? businessSegment : businessSegment+','+leadRec.region__c;    
        if (companyCustomerLocationMap.containsKey(leadRec.Company__c)) {
            ChildLeadRoutingHelper.handleCompanyCustomerLocation(leadRec, companyCustomerLocationMap, regionFilter);
        }else if (companyProspectMap.containsKey(leadRec.Company__c)) {
            ChildLeadRoutingHelper.handleCompanyProspect(leadRec, companyProspectMap,regionFilter);
        }else if (companyEndCustomerMap.containsKey(leadRec.Company__c) && companyEndCustomerMap.get(leadRec.Company__c).size() > 0) {
            ChildLeadRoutingHelper.handleCompanyEndCustomer(leadRec,companyEndCustomerMap, regionFilter);
        }else {
            if(regionQueuesMap.containsKey(regionFilter)){
                leadRec.OwnerId = ChildLeadRoutingHelper.getQueueId(regionQueuesMap.get(regionFilter));
            }
        }    
        updateLeads.add(leadRec);
    }    

/**     
* @description  update owner of the  child lead related to contact
* @param        NAME:leadRec DESCRIPTION: Accepts child lead sObject
*/  
    public static void updateContactLeadOwner(Child_Lead__c leadRec){
        Account acc = [select Id,RecordType.DeveloperName,Owner.Name,Owner.isActive,Owner.Business_Segment__c,
                        Distributor__c,Distributor_Location__c,Distributor_Location__r.Active__c,Sales_Area__c,ParentId from account where id =:leadRec.Related_Contact__r.AccountId];
        String businessSegment = fciBusinessSegmentList.contains(leadRec.Business_Segment__c) ? leadRec.Business_Segment__c : 'Industry';
        String regionFilter = leadRec.Region__c == null ? businessSegment : businessSegment+','+leadRec.region__c;        
        if(acc.RecordType.DeveloperName == 'BGI_Customer_Location'){
            List<Account_Team__c> accTeam = ChildLeadRoutingHelper.getUserFromAccountTeams(acc.id,leadRec.Business_Segment__c);
            if(accTeam.size() == 1 ){
                leadRec.OwnerId = accTeam[0].Team_Member__c;
            }else{
                ChildLeadRoutingHelper.checkAccountOnwerStatus(leadRec,acc,regionFilter);
            }
            updateLeads.add(leadRec);
        }if(acc.RecordType.DeveloperName == 'BGI_Prospect' || acc.RecordType.DeveloperName == 'BGI_Commercial_Customer'){
            ChildLeadRoutingHelper.checkAccountOnwerStatus(leadRec,acc,regionFilter);
            updateLeads.add(leadRec);
        }if(acc.RecordType.DeveloperName == 'BGI_End_Customer'){
            ChildLeadRoutingHelper.checkAccountOnwerStatus(leadRec,acc,regionFilter);
            leadRec.RecordTypeId = partnerLeadRTId;            
            updateLeads.add(leadRec);
        }       
    }
    

/**     
* @description  Get active account list and seggregate records based on record type
* @param        NAME:companyName DESCRIPTION: Accepts lead company name
*/      

    public static void getAccountList(String companyName){
        allAccountList = new  List<Account>();
        commercialCustomerList =  new List<Account>();
        customerLocationList = new List<Account>();
        endCustomerList = new List<Account>();
        prospectCustomerList = new List<Account>();

        allAccountList = [SELECT ID,Phone,Name,Customer_Segmentation__c,Active__c,Partner_Role__c,OwnerId,ParentId,Owner.Name,Distributor__c,
                                         Distributor_Location__c,Distributor_Location__r.Active__c,RecordTypeId,RecordType.DeveloperName,Owner.Business_Segment__c,
                                         Sales_Area__c,Owner.IsActive FROM Account WHERE (RecordType.DeveloperName='BGI_End_Customer' OR RecordType.DeveloperName='BGI_Customer_Location' OR
                                        RecordType.DeveloperName='BGI_Prospect') AND Active__c=true AND Name LIKE : companyName];      

        for(Account acc : allAccountList){
            if(acc.RecordType.DeveloperName == 'BGI_Customer_Location'){
                customerLocationList.add(acc);
            }
            if(acc.RecordType.DeveloperName == 'BGI_End_Customer'){
                endCustomerList.add(acc);
            }
            if(acc.RecordType.DeveloperName == 'BGI_Prospect'){
                prospectCustomerList.add(acc);
            }
        }                 
    }


/**     
* @description  get map of lead company and related account list
* @param        NAME:leadCompany DESCRIPTION: Accepts lead company name
*/        
    public static void getMatchedAccountList (String leadCompany){
        companyCustomerLocationMap = new Map<String,List<Account>>();
        companyEndCustomerMap = new Map<String,List<Account>>();
        companyProspectMap = new Map<String,List<Account>>();   

        createAccountMapBasedOnRT(leadCompany,companyCustomerLocationMap,customerLocationList);
        createAccountMapBasedOnRT(leadCompany,companyEndCustomerMap,endCustomerList);
        createAccountMapBasedOnRT(leadCompany,companyProspectMap,prospectCustomerList);      
    }


/**     
* @description  Get account list based on the lead company and create map of company and account record
* @param        NAME:leadCompany DESCRIPTION:Accepts lead company name
* @param        NAME:accountMap DESCRIPTION:Accepts map of company and list of account records 
* @param        NAME:accountlist DESCRIPTION:Accepts list of account records
*/      
    public static void createAccountMapBasedOnRT(String leadCompany, Map<String,List<Account>> accountMap,List<Account> accountlist){
        for(Account acc : accountlist){
            if(acc.Name.containsIgnoreCase(leadCompany)){
                if(accountMap.containskey(leadCompany)){
                    accountMap.get(leadCompany).add(acc);
                }else{
                    accountMap.put(leadCompany,new List<Account>{ acc });
                }
            }
        }
    }
/**     
* @description  Fetch child lead records related to contact/Lead where business segment is not blank and record type not equal to partner child lead
* @param        NAME:newleadsleads DESCRIPTION: Accepts new map of the id,child leads of child lead Object
* @param        NAME:oldleadsleads DESCRIPTION: Accepts old map of the id,child leads of child lead Object
*/ 
    public static void assignLeadOwner(Map<ID,Child_Lead__c> newleads, Map<ID,Child_Lead__c> oldleads){
        updateLeads = new List<Child_Lead__c>(); 
        // Map of sub segmet to map of region to user Id.
        Map<String,Map<String,String>> subSegmentRegionMap = new Map<String,Map<String,String>>();
        // Framing map of subSegmentRegionMap.
		for(Lead_Queues_Metadata__mdt record : [SELECT Business_Segment_Region__c,Queue__c,Region__c FROM Lead_Queues_Metadata__mdt]){
			Map<String,String> tempMap = new Map<String,String>();
			if(subSegmentRegionMap.containsKey(record.Business_Segment_Region__c)){
				for(String region : record.Region__c.trim().split(',')){
					if(!subSegmentRegionMap.get(record.Business_Segment_Region__c).containsKey(region)) {
						tempMap.put(region,record.Queue__c.trim());
						tempMap.putAll(subSegmentRegionMap.get(record.Business_Segment_Region__c));
					}
				}    
			} else {
				for(String region : record.Region__c.trim().split(',')){
					tempMap.put(region,record.Queue__c.trim());
				}
			}
			subSegmentRegionMap.put(record.Business_Segment_Region__c,tempMap);
		}
        // Assign updated Owner to Lead Interest.
        for(Child_Lead__c currentRecord : [SELECT Id , Sub_Segment__c, Region__c, OwnerId  FROM Child_Lead__c WHERE Id IN :newleads.keySet()]){
            /*First condition to check if it is called from insert. 
            Second condition to check if called from update and relevant field is updated.*/
            
            if((oldleads == null || (oldleads != null
                && (currentRecord.Sub_Segment__c != oldleads.get(currentRecord.Id).Sub_Segment__c
                    || currentRecord.Region__c != oldleads.get(currentRecord.Id).Region__c
                )))
				&& (subSegmentRegionMap.containskey(currentRecord.Sub_Segment__c)
					&& subSegmentRegionMap.get(currentRecord.Sub_Segment__c).containskey(currentRecord.Region__c)
				)
            ){
                // Get new Owner Id from map.
                currentRecord.OwnerId = subSegmentRegionMap.get(currentRecord.Sub_Segment__c).get(currentRecord.Region__c);
				// add the current record to list which upates the current record.
                updateLeads.add(currentRecord);
            }
        }
		// If updateLeads is not empty then update the list.
		if( updateLeads.size() > 0){
            ChildLeadRoutingHelper.leadsUpdate(updateLeads);
        }
    }

}