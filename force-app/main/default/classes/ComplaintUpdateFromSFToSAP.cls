/*
@Author     : Rohit Kumar
@CreatedDate: 03-09-2021
@UsedBy     : Record Triggered Flow (Called by Flow -Complaint SF to SAP Update Process)
@Description: Any update(Specific fields) on Complaint(Notifcation Request) will sych it to SAP.
				Note : Complaint/Notification/Case - All are same.
@History
03-09-2021   Rohit Kumar : Created
*/
public class ComplaintUpdateFromSFToSAP {
        
    /* 
    @Description -Whenever Relevant Case(Notification Request) Field Update happen in SF this medthod sync SF complaint details to SAP
    @param  - oldCaseList : List of old case field value
    @return - void
    */
    @InvocableMethod
    public static void fetchComplaintDetails(List<Case> oldCaseList){
        
        Map<String,Map_SF_SAP_Field_Values__mdt> SF_SAP_FieldMapping = new Map<String,Map_SF_SAP_Field_Values__mdt>();
        List<UpdatedComplaintFieldValues> updatedComplaintList = new List<UpdatedComplaintFieldValues>();
        Map<Id,String> mapSFOwnerIdWithSAPUserName = new Map<Id,String>();
        List<Case> listOfValidatedComplaint = new List<Case>();
        Set<Id> setOfComplaintOwnerInSF = new Set<Id>();
        Map<Id,Case> oldCaseMap = new Map<Id,Case>();
        BGI_Salesforce_Settings__c  customSettings = BGI_Salesforce_Settings__c.getOrgDefaults();
         //User getAPIUserId = [SELECT id FROM User WHERE Profile.Name='BGI Integration' AND Name='API User'];
        
        
        for(Case cs: oldCaseList)
        {
            oldCaseMap.put(cs.id,cs);
        }
        
        for(Case cs:[SELECT id,Type,Sub_Type__c,Priority,Subject,Ownerid,Notification_Origin__c,SAP_Case_Number__c,Department_Responsible__c,
                     RecordType.DeveloperName,Case_Closer_Reason__c,Description,LastModifiedByid,SAP_Case_Status__c,Status
                     FROM Case WHERE id IN:oldCaseMap.keySet()])
        {
            
            if(cs.LastModifiedById  != customSettings.API_User_ID__c /*getAPIUserId.id*/ || 
               (cs.LastModifiedById  == customSettings.API_User_ID__c /*getAPIUserId.id*/ && cs.Department_Responsible__c !=null
                     && oldCaseMap.get(cs.id).Department_Responsible__c ==null)) {    
                
                setOfComplaintOwnerInSF.add(cs.Ownerid);  
                listOfValidatedComplaint.add(cs);
            }    
        }
        if(!setOfComplaintOwnerInSF.isEmpty()){
            mapSFOwnerIdWithSAPUserName = getSAPUserName(setOfComplaintOwnerInSF);
        }
        if(!listOfValidatedComplaint.isEmpty()){
            SF_SAP_FieldMapping = getSAPFieldValuesBasedOnSFFieldValues(listOfValidatedComplaint);
            
            for(Case cs:listOfValidatedComplaint){
                UpdatedComplaintFieldValues requestInstance = new UpdatedComplaintFieldValues();  
                requestInstance = getComplaintUpdatedFieldValues(oldCaseMap.get(cs.id),cs,mapSFOwnerIdWithSAPUserName,SF_SAP_FieldMapping,true);
                if(cs.LastModifiedById == customSettings.API_User_ID__c /*getAPIUserId.id*/ && cs.Department_Responsible__c != null 
                   && oldCaseMap.get(cs.id).Department_Responsible__c == null)
                {
                    requestInstance.notificationInProcess = 'TRUE';
                }
                updatedComplaintList.add(requestInstance);
            }
        }
        
        if(!updatedComplaintList.isEmpty()){
            
            sendUpdatedComplaintToSAP(JSON.serializePretty(updatedComplaintList));
        }
        
    }
    /* 
    @Description - Get equivalent SAP UserName of Case Owner field
    @param  setOfComplaintOwnerInSF : List of Case Owner Id
    @return - Map<Id,String> : Map of user id and SAP User Name
    */
    public static Map<Id,String> getSAPUserName(Set<Id> setOfComplaintOwnerInSF){
        
        Map<Id,String> userIdToSAPUserNameMap = new Map<Id,String>();
        
        for(User owner : [SELECT id,SAP_UserName__c FROM User WHERE id IN:setOfComplaintOwnerInSF]){
            if(owner.SAP_UserName__c != null){
                userIdToSAPUserNameMap.put(owner.id,owner.SAP_UserName__c);
            }
        }
        
        return userIdToSAPUserNameMap;
    }
    /* 
    @Description - Get equivalent SAP Field Values based on SF field Value
    @param  complaintList : List Of Complaint.
    @return - Map<String,Map_SF_SAP_Field_Values__mdt> : Map of SF field value and SAP field Value
    */
    public static Map<String,Map_SF_SAP_Field_Values__mdt> getSAPFieldValuesBasedOnSFFieldValues(List<Case> complaintList){
        
        Map<String,Map_SF_SAP_Field_Values__mdt> SF_SAP_FieldMapping = new Map<String,Map_SF_SAP_Field_Values__mdt>();
        Set<String> complaintSFField1Values = new Set<String>();  
        Set<String> complaintSFField2Values = new Set<String>();
        Set<String> complaintSAPEquivalentSFUniqueFieldMapping = new Set<String>();
        
        for(Case cs:complaintList){
            complaintSFField1Values.add(cs.Type);
            complaintSFField2Values.add(cs.Sub_Type__c);
            complaintSAPEquivalentSFUniqueFieldMapping.add(cs.RecordType.DeveloperName);
            complaintSAPEquivalentSFUniqueFieldMapping.add(cs.Priority);
            complaintSAPEquivalentSFUniqueFieldMapping.add(cs.Case_Closer_Reason__c );
            complaintSAPEquivalentSFUniqueFieldMapping.add(cs.Notification_Origin__c );
        }
        
        if(!complaintSFField1Values.isEmpty() && !complaintSFField2Values.isEmpty()){
            for(Map_SF_SAP_Field_Values__mdt mapData :[SELECT Entity_Name__c,SF_Field_1_Name__r.QualifiedApiName,SF_Field1_Value__c,SAP_Field1_Value__c,
                                                       SF_Field_2_Name__r.QualifiedApiName,SF_Field2_Value__c,SAP_Field2_Value__c FROM Map_SF_SAP_Field_Values__mdt 
                                                       WHERE SF_Field1_Value__c IN:complaintSFField1Values AND SF_Field2_Value__c IN:complaintSFField2Values
                                                       AND Entity_Name__r.QualifiedApiName='Case'])
                
            {
                if(mapData.SF_Field1_Value__c!=null && mapData.SF_Field2_Value__c!=null && mapData.SAP_Field1_Value__c!=null && mapData.SAP_Field2_Value__c!=null ){
                    SF_SAP_FieldMapping.put(mapData.SF_Field_1_Name__r.QualifiedApiName+mapData.SF_Field1_Value__c+mapData.SF_Field_2_Name__r.QualifiedApiName+mapData.SF_Field2_Value__c,mapData);
                } 
                
            }
        }
        if(!complaintSAPEquivalentSFUniqueFieldMapping.isEmpty()){
            for(Map_SF_SAP_Field_Values__mdt mapData :[SELECT Entity_Name__c,SF_Field_1_Name__r.QualifiedApiName,SF_Field1_Value__c,SAP_Field1_Value__c
                                                       FROM Map_SF_SAP_Field_Values__mdt WHERE SF_Field1_Value__c IN:complaintSAPEquivalentSFUniqueFieldMapping
                                                       AND Entity_Name__r.QualifiedApiName='Case'])
                
            {
                if(mapData.SF_Field1_Value__c!=null && mapData.SAP_Field1_Value__c!=null){
                    SF_SAP_FieldMapping.put(mapData.SF_Field_1_Name__r.QualifiedApiName+mapData.SF_Field1_Value__c,mapData);
                }
                
            }
        }  
        
       // system.debug('sap data->'+JSON.serializePretty(SF_SAP_FieldMapping));
        
        return SF_SAP_FieldMapping;
        
    }
     /* 
    @Description - Create Wrapper Class which will only conatins Relevant field for SAP.
    @return - UpdatedComplaintFieldValues(Wrapper Class) :Updated Field of Complaint
    */
    public static UpdatedComplaintFieldValues getComplaintUpdatedFieldValues(Case caseBeforeUpdate, Case caseAfterUpdate,
                                                                   Map<id,String> mapSFOwnerIdWithSAPUserName,
                                                                   Map<String,Map_SF_SAP_Field_Values__mdt> SF_SAP_FieldMapping,boolean isUpdateTriggerAutomated)
    {
        /*Case Field API Names*/
        final String Case_Type_APIName = 'Type';
        final String Case_Sub_Type_APIName = 'Sub_Type__c';
        final String Case_Priority_APIName = 'Priority'; 
        final String Case_Closure_APIName = 'Case_Closer_Reason__c';
        final String Case_Notifcation_Origin_APIName = 'Notification_Origin__c';
        final String Case_RecordTypeId_APIName = 'RecordTypeId';
        
        UpdatedComplaintFieldValues complaintUpdatedValues = new UpdatedComplaintFieldValues();
        
        if(SF_SAP_FieldMapping.containsKey(Case_RecordTypeId_APIName+caseAfterUpdate.RecordType.DeveloperName)){
            complaintUpdatedValues.complaintRecordTypeInSAP = SF_SAP_FieldMapping.get(Case_RecordTypeId_APIName+caseAfterUpdate.RecordType.DeveloperName).SAP_Field1_Value__c;
        }
        if(/*caseAfterUpdate.Sub_Type__c != caseBeforeUpdate.Sub_Type__c 
           &&*/ SF_SAP_FieldMapping.containsKey(Case_Type_APIName+caseAfterUpdate.Type+Case_Sub_Type_APIName+caseAfterUpdate.Sub_Type__c))
        {
            complaintUpdatedValues.complaintSubType = SF_SAP_FieldMapping.get(Case_Type_APIName+caseAfterUpdate.Type+Case_Sub_Type_APIName+caseAfterUpdate.Sub_Type__c).SAP_Field2_Value__c;
        }
        if(/*caseAfterUpdate.Type != caseBeforeUpdate.Type && */
           SF_SAP_FieldMapping.containsKey(Case_Type_APIName+caseAfterUpdate.Type+Case_Sub_Type_APIName+caseAfterUpdate.Sub_Type__c))
        {
            complaintUpdatedValues.complaintType = SF_SAP_FieldMapping.get(Case_Type_APIName+caseAfterUpdate.Type+Case_Sub_Type_APIName+caseAfterUpdate.Sub_Type__c).SAP_Field1_Value__c;
        }
        if(/*caseAfterUpdate.Priority != caseBeforeUpdate.Priority &&*/
           SF_SAP_FieldMapping.containsKey(Case_Priority_APIName+caseAfterUpdate.Priority))
        {
            complaintUpdatedValues.complaintPriority = SF_SAP_FieldMapping.get(Case_Priority_APIName+caseAfterUpdate.Priority).SAP_Field1_Value__c;
        }
       // if(/*caseAfterUpdate.OwnerId != caseBeforeUpdate.OwnerId*/ ){
            complaintUpdatedValues.complaintSapUserName = mapSFOwnerIdWithSAPUserName.get(caseAfterUpdate.OwnerId);
       // }
        //if(caseAfterUpdate.Subject != caseBeforeUpdate.Subject){
            complaintUpdatedValues.complaintSubject = caseAfterUpdate.Subject;
        //}
       // if(caseAfterUpdate.Description != caseBeforeUpdate.Description){
            complaintUpdatedValues.complaintDescription = caseAfterUpdate.Description;
       // }
        if(/*caseAfterUpdate.Case_Closer_Reason__c != caseBeforeUpdate.Case_Closer_Reason__c 
           && */ SF_SAP_FieldMapping.containsKey(Case_Closure_APIName+caseAfterUpdate.Case_Closer_Reason__c)){
            complaintUpdatedValues.complaintCloserReason = SF_SAP_FieldMapping.get(Case_Closure_APIName+caseAfterUpdate.Case_Closer_Reason__c).SAP_Field1_Value__c;
        }       
        if(/*caseAfterUpdate.Notification_Origin__c !=  caseBeforeUpdate.Notification_Origin__c
           &&  */ SF_SAP_FieldMapping.containsKey(Case_Notifcation_Origin_APIName+caseAfterUpdate.Notification_Origin__c)){
            complaintUpdatedValues.notifcationOrigin = SF_SAP_FieldMapping.get(Case_Notifcation_Origin_APIName+caseAfterUpdate.Notification_Origin__c).SAP_Field1_Value__c;
        }
        if(caseAfterUpdate.Status == 'Closed' && caseBeforeUpdate.Status != 'Closed' && isUpdateTriggerAutomated
           && (caseAfterUpdate.SAP_Case_Status__c =='Notification Completed' ||  caseAfterUpdate.SAP_Case_Status__c =='All Tasks Completed' ) )
        {
            complaintUpdatedValues.closeNotification = 'TRUE';
        }
       
        complaintUpdatedValues.complaintNotifcationNumber = caseAfterUpdate.SAP_Case_Number__c;
        complaintUpdatedValues.caseRecordId = caseAfterUpdate.Id;
        Map_SF_SAP_Field_Values__mdt mapData = Map_SF_SAP_Field_Values__mdt.getInstance('Case_Partner_Function');
        if(mapData != null){
            complaintUpdatedValues.complaintPartnerFunctionInSAP = mapData.SAP_Field1_Value__c;
        }
        return complaintUpdatedValues;
        
    }
    /* 
    @Description - Send Complaint Details to SAP.
    @Params - updatedValues(Wrapper Class)    
    @return - Void
    */
    @future(callout = true)
    public static void sendUpdatedComplaintToSAP(String updatedValues){
        
        List<UpdatedComplaintFieldValues> updatedComplaintList = (List<UpdatedComplaintFieldValues>)JSON.deserialize(updatedValues,List<UpdatedComplaintFieldValues>.Class );
        //system.debug('requestParameterList in FUTURE'+JSON.serializePretty(updatedComplaintList) );
        
        if(!updatedComplaintList.isEmpty()){
            Boolean isUpdate = false;
            String setSAPCaseStatus;
        	Complaint_UpdateFromSFToSAP_Callout.SFResponse response = Complaint_UpdateFromSFToSAP_Callout.updateComplaintToSAP(updatedComplaintList[0]);            
            if(response.isSuccess && updatedComplaintList[0].notificationInProcess == 'TRUE'){
                isUpdate = true;
                setSAPCaseStatus='Notification In Process';
            }else if(response.isSuccess && updatedComplaintList[0].closeNotification =='TRUE'){
                isUpdate = true;
                setSAPCaseStatus = 'Notification Completed';   
            }
            if(isUpdate){
                 Case caseRecord = [SELECT id,SAP_Case_Status__c FROM Case WHERE id=:updatedComplaintList[0].caseRecordId];
        		 caseRecord.SAP_Case_Status__c = setSAPCaseStatus;
                 UPDATE caseRecord;
            }
        }    
    }
    
    
    public class UpdatedComplaintFieldValues{
        
        public String complaintRecordTypeInSAP = '';
        public String complaintType ='';
        public String complaintSubType ='';
        public String complaintPriority ='';
        public String complaintSubject ='';
        public String complaintDescription ='';
        public String complaintNotifcationNumber='';
        public String complaintCloserReason='';
        public String notifcationOrigin='';
        public String notificationInProcess;
        public String closeNotification ;
        public String caseRecordId;
        public String complaintSapUserName ='';
        public String complaintPartnerFunctionInSAP = '';
    }
    
}