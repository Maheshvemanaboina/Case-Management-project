public with sharing class CommunityKPIReviewController {
    
    public static final String CONFIRMED_BY_SM_API_NAME = 'Confirmed_by_FCI_Sales_Manager__c';
    public static final String APPROVAL_OR_REJECTION_API_NAME = 'Approval_Rejection_Reason__c';
    public static final String BUSINESS_SEGMENT = 'Business_Segment__c';    
    public static final String DISTRIBUTOR_ACCOUNT = 'Distributor_Account_Name__c';
    public static final String DOT_OPERATOR = '.';
    public static final String BUS_SEG_SEPERATOR = ' | ';
    
    @AuraEnabled
    public static CommunityKPIReviewTableWrapper getTableData(String masterKPIid){
        
        Community_KPI_Setting__mdt kpiMetadata = getCommunityKPIMetadata(getKPIType(masterKPIid));        
        
        return new CommunityKPIReviewTableWrapper(masterKPIid,kpiMetadata);
    }
    
    @AuraEnabled
    public static void updateRecords(String masterKPIid, Map<Id, KpiUpdateWrapper> kpiIdCommentsMap){
        
        Community_KPI_Setting__mdt kpiMetadata = getCommunityKPIMetadata(getKPIType(masterKPIid));
        
        //List<AccountTeamMember> accTeamList = new List<AccountTeamMember>();
        List<Account_Team__c> accTeamList = new List<Account_Team__c>();
        sObject parSObject = getParentKPIsObject(masterKPIid);
        string KPIConfirmedBySM = string.valueOf(parSObject.get(CONFIRMED_BY_SM_API_NAME));
        
        if(parSObject != null){
            string KPIParentDistAccVal = string.valueOf(parSObject.get(DISTRIBUTOR_ACCOUNT));
            
            if(String.isNotBlank(KPIParentDistAccVal)){
                
                  /*accTeamList = [SELECT id, Business_Segment__c, UserId 
                               	 FROM AccountTeamMember 
                               	 WHERE Primary__c=:true AND AccountId =: KPIParentDistAccVal];*/
                accTeamList = [SELECT id, Business_Segment__c, Team_Member__c 
                               	 FROM Account_Team__c 
                               	 WHERE Primary__c=:true AND Source_Account__c =: KPIParentDistAccVal];
            }
        }
        
        List<sObject> sObjList = new List<sObject>();
        String KPIQuery = getKPITypeQuery(kpiMetadata,masterKPIid,new List<String>{BUSINESS_SEGMENT,APPROVAL_OR_REJECTION_API_NAME});//ENH-4586 - Added APPROVAL_OR_REJECTION_API_NAME
        
        for(sObject eachObjRecord : Database.query(KPIQuery)){
            
            if(kpiIdCommentsMap.containsKey(String.valueOf(eachObjRecord.get('Id')))){
                String busSegstr = '';
                boolean throwErr = true;
                if(!accTeamList.isEmpty()){
                    for(Account_Team__c acTeam : accTeamList){
                        if(acTeam.Team_Member__c == Userinfo.getUserId()){
                            set<string> busSegset = new set<string>();
                            if(String.isNOTBLANK(acTeam.Business_Segment__c) ){
                                busSegset.addAll(acTeam.Business_Segment__c.split(' \\| '));
                            }
                            if(busSegset.contains(String.valueOf(eachObjRecord.get(BUSINESS_SEGMENT)))){
                                throwErr = false;
                                    if(eachObjRecord.get(CONFIRMED_BY_SM_API_NAME) != kpiIdCommentsMap.get(String.valueOf(eachObjRecord.get('Id'))).kpiConfirmedBySM){
                                        if(kpiIdCommentsMap.get(String.valueOf(eachObjRecord.get('Id'))).kpiConfirmedBySM){
                                            KPIConfirmedBySM = 'Yes';
                                            eachObjRecord.put(CONFIRMED_BY_SM_API_NAME, 'Yes');
                                        }else{
                                            KPIConfirmedBySM = 'No';
                                            eachObjRecord.put(CONFIRMED_BY_SM_API_NAME, 'No');
                                        }                                      
                                    }
                                //ENH-4586 - update approval/rejection reason field in child kpi record submitted by distributor
                                if(!kpiIdCommentsMap.isEmpty() && kpiIdCommentsMap.containsKey(String.valueOf(eachObjRecord.get('Id')))
                                   && eachObjRecord.get(APPROVAL_OR_REJECTION_API_NAME) != kpiIdCommentsMap.get(String.valueOf(eachObjRecord.get('Id'))))
                                {
                                    eachObjRecord.put(APPROVAL_OR_REJECTION_API_NAME, kpiIdCommentsMap.get(String.valueOf(eachObjRecord.get('Id'))).kpiComments);
                                }
                            }
                            
                            busSegstr = '"'+acTeam.Business_Segment__c+'"';
                        }
                    } 
                } 
                if(throwErr){
                    throw new AuraHandledException(system.label.KPI_Approval_Error+busSegstr);
                }
            }else if(eachObjRecord.get(CONFIRMED_BY_SM_API_NAME) == 'Pending' || eachObjRecord.get(CONFIRMED_BY_SM_API_NAME) == null || eachObjRecord.get(CONFIRMED_BY_SM_API_NAME) == 'No'){ 
                
                if(!accTeamList.isEmpty()){
                    for(Account_Team__c acTeam : accTeamList){
                        if(acTeam.Team_Member__c == Userinfo.getUserId()){
                            set<string> busSegset = new set<string>();
                            if(String.isNOTBLANK(acTeam.Business_Segment__c) ){
                                busSegset.addAll(acTeam.Business_Segment__c.split(' \\| '));
                            }
                            if(busSegset.contains(String.valueOf(eachObjRecord.get(BUSINESS_SEGMENT)))){
                                KPIConfirmedBySM = 'No';
                				eachObjRecord.put(CONFIRMED_BY_SM_API_NAME, 'No');
                            }
                        }
                    } 
                } 
                
                
            }
            sObjList.add(eachObjRecord);
        }
        
        //parSObject.put(APPROVAL_OR_REJECTION_API_NAME,SMComments); ENH-4586 - Commented this as we don't need to update the Approval/Rejection reason filed in parent kpi record
        if(String.isNotBlank(KPIConfirmedBySM)){
            parSObject.put(CONFIRMED_BY_SM_API_NAME,KPIConfirmedBySM);
        }
        Savepoint sp = Database.setSavepoint();
        try{
            
            DAOUtilityWithoutShar.updateWithoutAccess(new list<SObject>{parSObject});
        
            if(!sObjList.isEmpty()){
                DAOUtilityWithoutShar.updateWithoutAccess(sObjList);
            }
        }catch(Exception excp){
            Database.rollback(sp);
           throw new AuraHandledException(excp.getMessage()); 
        }
        
        
    }
    
    public static List<Map<String,String>> getRowValues(String masterKPIid,Community_KPI_Setting__mdt kpiMetadata,List<String> APIfieldValues){
        
        List<Map<String,String>> rowValuesData = new List<Map<String,String>>();
        String KPIQuery = getKPITypeQuery(kpiMetadata,masterKPIid,APIfieldValues); 
        
        for(sObject eachObjRecord : Database.query(KPIQuery)){
            rowValuesData.add(getEachRowData(eachObjRecord,APIfieldValues));
        }
        
        return rowValuesData;
    }
    //Generate  3 strings and traverse to parent to fetch valuev 
    public static Map<String,String> getEachRowData(SObject eachObjRecord,List<String> APIfieldValues){
        
        Map<String,String> fieldValueMap = new Map<String,String>();
        //eachrow.add('SL No.');
        for(String eachfieldName : APIfieldValues){
            if(eachfieldName.contains(DOT_OPERATOR)){

                SObject sObjectVal;
                List<String> lookupFieldRelation = eachfieldName.split('\\.');
                for(Integer i = 0 ; i < lookupFieldRelation.size() - 1 ; i++){
                    sObjectVal = eachObjRecord.getSObject(lookupFieldRelation[i]);
                    if(sObjectVal == null){
                        break;
                    }
                }
                String fieldVal;
                if(sObjectVal != null){
                    fieldVal = String.valueOf(sObjectVal.get(lookupFieldRelation[lookupFieldRelation.size()-1]));
                }
                fieldValueMap.put(eachfieldName,fieldVal != null && fieldVal != '' ? fieldVal : '');
            }else{
                fieldValueMap.put(eachfieldName,String.valueOf(eachObjRecord.get(eachfieldName)) != null ? String.valueOf(eachObjRecord.get(eachfieldName)) : '');
            }
        }
        fieldValueMap.put('Id',String.valueOf(eachObjRecord.get('Id')));
        fieldValueMap.put('confirmed',eachObjRecord.get(CONFIRMED_BY_SM_API_NAME) != 'Yes' ? 'false' : 'true');
        return fieldValueMap;
    }
    
    public class CommunityKPIReviewTableWrapper {
        @AuraEnabled public String CommunityKPIType {get; private set;}
        @AuraEnabled public String SMComments {get; private set;}
        @AuraEnabled public List<String> headerValues { get; private set; }
        @AuraEnabled public List<Map<String,String>> bodyValue { get; private set; }
        @AuraEnabled public List<String> listOfKeys { get; private set; }
        
        public CommunityKPIReviewTableWrapper(String masterKPIid,Community_KPI_Setting__mdt kpiMetadata) {
            this.CommunityKPIType = kpiMetadata.KPI_Activity_Type__c;
            this.headerValues = kpiMetadata.Header_Values__c.split(Constants.CSV_PICKLIST_SEPARATOR);
            this.SMComments = String.valueOf(getParentKPIsObject(masterKPIid).get(APPROVAL_OR_REJECTION_API_NAME));
            this.bodyValue = getRowValues(masterKPIid, kpiMetadata, kpiMetadata.Fields_To_Query_API_Name__c.split(Constants.CSV_PICKLIST_SEPARATOR));
            this.listOfKeys = kpiMetadata.Fields_To_Query_API_Name__c.split(Constants.CSV_PICKLIST_SEPARATOR);
        }
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
    
        
    private static String getKPITypeQuery(Community_KPI_Setting__mdt cActMdt, String masterKPIid,List<String> APIfieldValues){
        
        String query = 'SELECT Id,';
        
        if(!APIfieldValues.isEmpty()){
            for(String eachfieldName : APIfieldValues){
                query = query + eachfieldName + ',';
            }
        }
        
        query = query + CONFIRMED_BY_SM_API_NAME;        
        query = query + ' FROM ' + cActMdt.KPI_Related_Object_Name__c;
        query = query + ' WHERE '+ cActMdt.KPI_Parent_Lookup_Name__c +' =: masterKPIid';
        return query;
    }
    
    private static sObject getParentKPIsObject(String masterKPIid){
        
        String parentSObjectName = String.valueOf(Id.valueOf(masterKPIid).getSObjectType());         
        
        
        String query = 'SELECT Id,';
        query = query + CONFIRMED_BY_SM_API_NAME + ',' +APPROVAL_OR_REJECTION_API_NAME+','+DISTRIBUTOR_ACCOUNT;
        query = query + ' FROM ' + parentSObjectName;
        query = query + ' WHERE Id =: masterKPIid';
        return Database.query(query);
    }
    
    private static String getKPIType(String masterKPIid){
        
        String parentSObjectName = String.valueOf(Id.valueOf(masterKPIid).getSObjectType());
		       
        String KPITypeFieldAPIName = getSObjectWithKPITypeMap().get(parentSObjectName);
        
        String query = 'SELECT Id,';
        query = query + KPITypeFieldAPIName;
        query = query + ' FROM ' + parentSObjectName;
        query = query + ' WHERE Id =: masterKPIid';
        system.debug('parentSObjectName '+ String.valueOf(Database.query(query)[0].get(KPITypeFieldAPIName))); 
        return String.valueOf(Database.query(query)[0].get(KPITypeFieldAPIName));
    }
    
    private static Community_KPI_Setting__mdt getCommunityKPIMetadata(String KPIType){
        
        return [SELECT KPI_Related_Object_Name__c,KPI_Activity_Type__c,Fields_To_Query_API_Name__c,Header_Values__c,KPI_Parent_Lookup_Name__c
                FROM Community_KPI_Setting__mdt
                WHERE KPI_Activity_Type__c =: KPIType
                AND Submit_Review__c = 'Review'];
    }
    
    public class KpiUpdateWrapper{
        @AuraEnabled public String kpiComments {get; set;}
        @AuraEnabled public Boolean kpiConfirmedBySM {get; set;}
    }
}