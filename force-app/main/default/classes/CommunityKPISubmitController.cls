/* 
Created by : Sibananda Bhuyan

23-11-2020 Sibananda Bhuyan Added hard validation to not allow users to submit KPIs if no records are created.
*/
public with sharing class CommunityKPISubmitController {

    public final static String FISCAL_YEAR_API_NAME = 'Fiscal_Year_FY__c';
    public final static String PERIOD_API_NAME = 'Period__c';
    public static final String PENDING_VALUE = 'Pending';
    public static final String CONFIRMED_BY_SM_API_NAME = 'Confirmed_by_FCI_Sales_Manager__c';
    public static final String BUSINESS_SEGMENT = 'Business_Segment__c';    
    public static final String DISTRIBUTOR_ACCOUNT = 'Distributor_Account_Name__c';
    
    @AuraEnabled
    public static CommunitySubmitWrapper getKPIInformation(String kpiId){
         
        Community_KPI_Setting__mdt kpiMetadata = getCommunityKPIMetadata(getKPIType(kpiId));

        SObject kpiSObject = getParentKPIsObject(kpiId, kpiMetadata.Fields_To_Query_API_Name__c.split(Constants.CSV_PICKLIST_SEPARATOR));

        List<sObject> childObjects = getChildRecordToUpdate(kpiId,kpiMetadata.KPI_Related_Object_Name__c, kpiMetadata.KPI_Parent_Lookup_Name__c);

        User currUser = [SELECT Id, ContactId, Community_User_Role__c, Work_Location__c FROM User WHERE Id =: UserInfo.getUserId()];

        String kpisObjectDistiLoc = String.valueOf(Database.query('SELECT Distributor_Account_Name__c, Distributor_Account_Name__r.Name FROM '
                                                    + String.valueOf(Id.valueOf(kpiId).getSObjectType())
                                                    + ' WHERE Id =: kpiId')[0].getSObject('Distributor_Account_Name__r').get('Name'));

        return new CommunitySubmitWrapper(
            kpiId, 
            kpiSObject, 
            kpiMetadata, 
            currUser.ContactId != null ? true : false, 
            String.valueOf(kpiSObject.get(CONFIRMED_BY_SM_API_NAME)),
            childObjects.isEmpty() ? false : true,
            (kpisObjectDistiLoc != currUser.Work_Location__c && currUser.Community_User_Role__c.equals(Constants.COMMUNITY_USER_ROLE_STANDARD_USER)) ? true : false);
    }

    @AuraEnabled
    public static String handleSaveForSubmission(String kpiId){
        
        Community_KPI_Setting__mdt kpiMetadata = getCommunityKPIMetadata(getKPIType(kpiId));
        
		List<AccountTeamMember> accTeamList = new List<AccountTeamMember>();
        SObject kpiSObject = getParentKPIsObject(kpiId, kpiMetadata.Fields_To_Query_API_Name__c.split(Constants.CSV_PICKLIST_SEPARATOR));
        if(kpiSObject != null){
            
            string KPIParentDistAccVal = string.valueOf(kpiSObject.get(DISTRIBUTOR_ACCOUNT));
            
            if(String.isNotBlank(KPIParentDistAccVal)){
                
                  accTeamList = [SELECT id, Business_Segment__c, UserId,user.name
                               	 FROM AccountTeamMember 
                               	 WHERE Primary__c=:true AND AccountId =: KPIParentDistAccVal AND TeamMemberRole=:'Sales Manager'];
            }
            
            
        }
        
        
        
        List<sObject> childObjects = getChildRecordToUpdate(kpiId,kpiMetadata.KPI_Related_Object_Name__c, kpiMetadata.KPI_Parent_Lookup_Name__c);
        kpiSObject.put(CONFIRMED_BY_SM_API_NAME, PENDING_VALUE);
		String eBody = '';
        string eSubject = '';
            
        EmailTemplate KPIAppTemp = [SELECT id,body,subject FROM EmailTemplate where developername =: 'KPI_Approval_Notification'];
        if(KPIAppTemp != null){
            String Recordlink =  URL.getOrgDomainUrl().toExternalForm()+'/'+string.valueOf(kpiSObject.get('Id'));
            
            eBody = KPIAppTemp.body;
            eBody = eBody.replace('{KPINAME}',string.valueOf(kpiSObject.get('Name')));
            eBody = eBody.replace('{RECLINK}',Recordlink);
            
            eSubject = KPIAppTemp.subject.replace('{KPINAME}',string.valueOf(kpiSObject.get('Name')));
        }
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {};
        for(sObject eachsObj : childObjects){
            
            eachsObj.put(CONFIRMED_BY_SM_API_NAME, PENDING_VALUE);
            for(AccountTeamMember acTeam : accTeamList){
                
                set<string> busSegset = new set<string>();
                if(String.isNOTBLANK(acTeam.Business_Segment__c) ){
                    busSegset.addAll(acTeam.Business_Segment__c.split(' \\| '));
                }
                if(busSegset.contains(String.valueOf(eachsObj.get(BUSINESS_SEGMENT)))){
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setTargetObjectId(acTeam.UserId);
                    string tempStr = ebody;                    
                    tempStr = tempStr.replace('{SMNAME}', acTeam.user.name);
                    tempStr = tempStr.replace('{CurrentUser}', userinfo.getName());
                    message.setPlainTextBody(tempStr);
                    message.setSubject(eSubject);
                    message.setSaveAsActivity(false);                    
                    messages.add(message);
                }
                
            }
            
        }
        
        if(!messages.isEmpty()){
            Messaging.sendEmail(messages);
        }
        
        user currUser = getCurrentUser();
        if(!childObjects.isEmpty()){
            Global_Automation_Setting__c globalAutoSetting = Global_Automation_Setting__c.getInstance(currUser.ProfileId);
            globalAutoSetting.Skip_Validation_Rule__c = false;
            update globalAutoSetting;

            DAOUtilityWithoutShar.updateWithoutAccess(new List<SObject>{kpiSObject});
            DAOUtilityWithoutShar.updateWithoutAccess(childObjects);

            globalAutoSetting.Skip_Validation_Rule__c = true;
            update globalAutoSetting;
        }
        
        return currUser.Contact.Account.Owner.Name;
    }

    private static List<SObject> getChildRecordToUpdate(String parentKpiId, String ObjName, String parentRelationName){

        //return childRecords to update the confirmed by SM Field
        String childQuery = 'SELECT Id, ' + CONFIRMED_BY_SM_API_NAME+','+BUSINESS_SEGMENT;
        childQuery = childQuery + ' FROM ' + ObjName;
        childQuery = childQuery + ' WHERE ' + parentRelationName + ' =: parentKpiId';
        childquery = childQUery + ' AND ' + CONFIRMED_BY_SM_API_NAME + ' != \'Yes\' ';
        return Database.query(childQuery);
    }

    private static sObject getParentKPIsObject(String masterKPIid, List<String> APIfieldValues){  
        
        String parentSObjectName = String.valueOf(Id.valueOf(masterKPIid).getSObjectType());
        
        String query = 'SELECT Id,'+DISTRIBUTOR_ACCOUNT+',';
        boolean addName = true;
        if(!APIfieldValues.isEmpty()){            
            for(String eachfieldName : APIfieldValues){
                query = query + eachfieldName + ',';
                if(eachfieldName == 'Name'){
                    addName = false;
                }
            }
        }
        if(addName){
            query = query + 'Name,';
        }
        query = query.substringBeforeLast(',');
        query = query + ' FROM ' + parentSObjectName;
        query = query + ' WHERE Id =: masterKPIid';
        
        return Database.query(query);
    }

    private static String getKPIType(String kpiId){
        
        String parentSObjectName = String.valueOf(Id.valueOf(kpiId).getSObjectType());
        
        String KPITypeFieldAPIName = getSObjectWithKPITypeMap().get(parentSObjectName);
        
        String query = 'SELECT Id,';
        query = query + KPITypeFieldAPIName;
        query = query + ' FROM ' + parentSObjectName;
        query = query + ' WHERE Id =: kpiId';
        return String.valueOf(Database.query(query)[0].get(KPITypeFieldAPIName));
    }

    private static Map<String,String> getSObjectWithKPITypeMap(){
        
        return new Map<String,String>
        {
            'Commercial_Activity__c' => 'Commercial_Activity_Type__c',
            'Sales_Funnel__c' => 'Sales_Funnel_Type__c',
            'Forecast_Accuracy__c' => 'Forecast_Type__c',
            'FCI_Customer_Support__c' => 'FCI_Customer_Support_Type__c',
            'Business_Strategy__c' => 'Business_Strategy_Type__c'
        };
                    
   }

   private static Community_KPI_Setting__mdt getCommunityKPIMetadata(String KPIType){
        
    return [SELECT KPI_Related_Object_Name__c,KPI_Activity_Type__c,Fields_To_Query_API_Name__c,Header_Values__c,KPI_Parent_Lookup_Name__c
            FROM Community_KPI_Setting__mdt
            WHERE KPI_Activity_Type__c =: KPIType
            AND Submit_Review__c = 'Submit'];
    }

    public class CommunitySubmitWrapper{

        @AuraEnabled public Boolean isPartner{set; get;}
        @AuraEnabled public String KPIType{set; get;}
        @AuraEnabled public String SObjectName{set; get;}
        @AuraEnabled public String FiscalYear{set; get;}
        @AuraEnabled public String Period{set; get;}
        @AuraEnabled public String ConfirmedOrNot{set; get;}
        @AuraEnabled public Boolean disbleYesButton {set; get;}
        @AuraEnabled public Boolean isValidForSubmission {set;get;} //This is to make sure if KPI can be submitted, if no child records then it is false or else true
        @AuraEnabled public Boolean isKPIShared {set;get;} // This is to make sure that a shared KPI cannot be submitted for approval

        public CommunitySubmitWrapper(String kpiId, SObject kpiSObject,Community_KPI_Setting__mdt kpiMetaData, Boolean isPartner, String confirmedBySM, Boolean isValidForSubmission, Boolean isKPIShared){
            this.isPartner              = isPartner;
            this.KPIType                = kpiMetaData.KPI_Activity_Type__c;
            this.SObjectName            = String.valueOf(Id.valueOf(kpiId).getSobjectType().getDescribe().getLabel());
            this.FiscalYear             = String.valueOf(kpiSObject.get(FISCAL_YEAR_API_NAME));
            this.Period                 = String.valueOf(kpiSObject.get(PERIOD_API_NAME));
            this.ConfirmedOrNot         = confirmedBySM;
            this.disbleYesButton        = confirmedBySM == 'Pending' || isKPIShared || !isValidForSubmission ? true : false;
            this.isValidForSubmission   = isValidForSubmission;
            this.isKPIShared            = isKPIShared;
        }
        
    }

    public static User getCurrentUser(){
        return [SELECT Contact.Account.Owner.Name,ProfileId FROM User where Id =: UserInfo.getUserId()];
    }
    
    
}