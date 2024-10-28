/**
* @UserStory:   143693-Optimize the Current Approval Process in LSD SCAF object + 146698 + 146330
* @Author   :   LSD SCAF Expedition 2030 Dev Team
* @Date     :   21 May 2024
* @Desc     :   Class for Lightning Web Component 'ScafApprovalPath' to display the Approvers from the LSD-SCAF Record 
                approver fields before submission of SCAF for approval. After approval submission, it should display 
                actual approvers from the Approval instances. 
* */
public without sharing class LegalSalesApprovalPathHandlerOptimized {
    /*
        * Method Name               :   getApprovalPathData
        * Description               :   To get the Actual approver names (at each approver role) from the approved scaf record,
                                        so that we can display correct approvers in the Approval scaf path
        * @ PARAMS recId            :   Current SCAF record id
    */
    @AuraEnabled
    public static String getApprovalPathData(String recId) {
        List<String> scafFields = getFieldsToQuery();
        String query = buildScafQuery(scafFields, recId);
        SCAF__c scafRec = (SCAF__c) Database.query(query);
        System.debug(LoggingLevel.INFO,'scafRec --> '+scafRec);
        List<ProcessInstance> processInstanceList = getProcessInstance(recId);                                            
        List<String> approversFromScafRecord = getApproversFromScafRecord(scafRec);
        system.debug(LoggingLevel.INFO,'approversFromScafRecord'+approversFromScafRecord);
        List<String> approversFromApprovalHistory = new List<String>();
        List<String> nameCSSList = new List<String>();
        
        if (!processInstanceList.isEmpty()) {
            approversFromApprovalHistory = getActualApproversFromApprovalHistory(getProcessInstanceSteps(processInstanceList[0]));
        }
        System.debug(LoggingLevel.INFO,'approversFromApprovalHistory--' + approversFromApprovalHistory);
        //146330 - Added condition to check if the record is rejected and Approval level Required or either of Business Group/ Leading Segment/ FC Legal Entity is changed.
        if(scafRec.RejectedAndUpdatedScaf__c==false){
            processApprovalPath(processInstanceList, approversFromScafRecord, approversFromApprovalHistory, (Integer)scafRec.Approval_Levels_Required__c, nameCSSList);
        }else{
            nameCSSList.addall(approversFromScafRecord); 
        }
    
    System.debug(LoggingLevel.INFO,'nameCSSList --> ' + nameCSSList);
    List<chevronData> lstRet = buildChevronDataList(nameCSSList);
    System.debug(LoggingLevel.INFO,'lstRet--'+JSON.serialize(lstRet));
    return JSON.serialize(lstRet);
    }
    /*
        * Method Name   : buildScafQuery
        * Description   : To build query for SCAF Object
        * @ PARAMS 
        1. scafFields   : List of fields to query from SCAF object
        2. recId        : Current SCAF record id
    */
    private static String buildScafQuery(List<String> scafFields, String recId) {
        String query = 'SELECT Id,';
        for (String eachScafField : scafFields) {
            query += eachScafField + ',';
        }
        query = query.substringBeforeLast(',');
        return query + ',' + Constants.LEGAL_SALES_SCAF_APPROVAL_FIELD_API_NAMES + ', SCAF_Approval_Status__c, is_scaf_already_approved__c, Legal__r.Name, Finance_Director__r.Name, Managing_Director__r.Name, Business_Group_Finance_Director__r.Name, Business_Group_President__r.Name, Company_Secretary__r.Name FROM SCAF__c WHERE Id =:recId';
    }
     /*
        * Method Name                           : getFieldsToQuery
        * Description                           : To get fields to query from SCAF object
    */
    private static List<String> getFieldsToQuery() {
        String legalCustomfields1 = 'Aggregate_Liability_Cap_Amount_EUR__c,Business_Group__c,Leading_Business_Segment__c,';
        String legalCustomfields2 = 'FC_Legal_Entity__c,Indemnity__c,Initial_Term_of_LSD_In_Months__c,Liability_Cap_Per_Year_EUR__c,';
        String legalCustomfields3 = 'Penalties_or_Other_Financial_Exposure__c,';
        String legalCustomfields4 = 'Standard_Governing_Law__c,Standard_Liability__c,Standard_Order_Process__c,Standard_Termination__c,';
        String legalCustomfields5 = 'Standard_Warranties__c,Termination_Notice_Period_In_Months__c,Total_Net_Sales_Value__c,RejectedAndUpdatedScaf__c,';
        String legalCustomfields6 = 'Legal__c,Finance_Director__c,Managing_Director__c,Business_Group_Finance_Director__c,Business_Group_President__c,Company_Secretary__c,Approval_Levels_Required__c,Owner__r.Name';
        return (legalCustomfields1 + legalCustomfields2 + legalCustomfields3 + legalCustomfields4 + legalCustomfields5 + legalCustomfields6).split(',');
    }
    /*
        * Method Name   : getApproversFromScafRecord
        * Description   : To get approvers from SCAF object matching with LSD Approval Matrix
        * @ PARAMS 
        1. recId        : Current SCAF record id
    */
    private static List<String> getApproversFromScafRecord(SCAF__c scafRec) {
        List<String> approversFromScafRecord = new List<String>();
        Integer scafApprovalLevelsRequired = Integer.valueOf(scafRec.Approval_Levels_Required__c);
        System.debug(LoggingLevel.INFO,'scafApprovalLevelsRequired-->'+scafApprovalLevelsRequired);
        if  (scafApprovalLevelsRequired==1 ) {
            approversFromScafRecord.add((scafRec.Legal__c != null ? scafRec.Legal__r.Name : 'Not Available') + Constants.LEGAL_SALES_STRING_SPLIT_CHAR + Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_YET_TO_APPROVE);
        }
        if (scafApprovalLevelsRequired==3 ) {
            approversFromScafRecord.add((scafRec.Legal__c != null ? scafRec.Legal__r.Name : 'Not Available') + Constants.LEGAL_SALES_STRING_SPLIT_CHAR + Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_YET_TO_APPROVE);
            approversFromScafRecord.add((scafRec.Finance_Director__c != null ? scafRec.Finance_Director__r.Name : 'Not Available') + Constants.LEGAL_SALES_STRING_SPLIT_CHAR + Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_YET_TO_APPROVE);
            approversFromScafRecord.add((scafRec.Managing_Director__c != null ? scafRec.Managing_Director__r.Name : 'Not Available') + Constants.LEGAL_SALES_STRING_SPLIT_CHAR + Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_YET_TO_APPROVE);
        }   
        if ( scafApprovalLevelsRequired==5 ) {
            approversFromScafRecord.add((scafRec.Legal__c != null ? scafRec.Legal__r.Name : 'Not Available') + Constants.LEGAL_SALES_STRING_SPLIT_CHAR + Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_YET_TO_APPROVE);
            approversFromScafRecord.add((scafRec.Finance_Director__c != null ? scafRec.Finance_Director__r.Name : 'Not Available') + Constants.LEGAL_SALES_STRING_SPLIT_CHAR + Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_YET_TO_APPROVE);
            approversFromScafRecord.add((scafRec.Managing_Director__c != null ? scafRec.Managing_Director__r.Name : 'Not Available') + Constants.LEGAL_SALES_STRING_SPLIT_CHAR + Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_YET_TO_APPROVE);
            approversFromScafRecord.add((scafRec.Business_Group_Finance_Director__c != null ? scafRec.Business_Group_Finance_Director__r.Name : 'Not Available') + Constants.LEGAL_SALES_STRING_SPLIT_CHAR + Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_YET_TO_APPROVE);
            approversFromScafRecord.add((scafRec.Business_Group_President__c != null ? scafRec.Business_Group_President__r.Name : 'Not Available') + Constants.LEGAL_SALES_STRING_SPLIT_CHAR + Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_YET_TO_APPROVE);    
        }   
        if (scafApprovalLevelsRequired==6 ) {
            approversFromScafRecord.add((scafRec.Legal__c != null ? scafRec.Legal__r.Name : 'Not Available') + Constants.LEGAL_SALES_STRING_SPLIT_CHAR + Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_YET_TO_APPROVE);
            approversFromScafRecord.add((scafRec.Finance_Director__c != null ? scafRec.Finance_Director__r.Name : 'Not Available') + Constants.LEGAL_SALES_STRING_SPLIT_CHAR + Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_YET_TO_APPROVE);
            approversFromScafRecord.add((scafRec.Managing_Director__c != null ? scafRec.Managing_Director__r.Name : 'Not Available') + Constants.LEGAL_SALES_STRING_SPLIT_CHAR + Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_YET_TO_APPROVE);
            approversFromScafRecord.add((scafRec.Business_Group_Finance_Director__c != null ? scafRec.Business_Group_Finance_Director__r.Name : 'Not Available') + Constants.LEGAL_SALES_STRING_SPLIT_CHAR + Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_YET_TO_APPROVE);
            approversFromScafRecord.add((scafRec.Business_Group_President__c != null ? scafRec.Business_Group_President__r.Name : 'Not Available') + Constants.LEGAL_SALES_STRING_SPLIT_CHAR + Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_YET_TO_APPROVE);
            approversFromScafRecord.add((scafRec.Company_Secretary__c != null ? scafRec.Company_Secretary__r.Name : 'Not Available') + Constants.LEGAL_SALES_STRING_SPLIT_CHAR + Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_YET_TO_APPROVE );     
        }
        return approversFromScafRecord;
    }
    /*
        * Method Name                           : processApprovalPath
        * Description                           : To process approval records
        * @ PARAMS 
        1. processInstanceList                  : List of processInstance from appoval history
        2. approversFromScafRecord              : List of Approvers from SCAF record matching with LSD Approval Matrix.
        3. approversFromApprovalHistory         : List of actual approvers from appoval history
        4. scafApprovalLevelsRequired           : Field value of Approval_Levels_Required__c
        5. nameCSSList                          : List of all actual approvers with its status.
    */
    private static void processApprovalPath(List<ProcessInstance> processInstanceList, List<String> approversFromScafRecord, List<String> approversFromApprovalHistory, Integer scafApprovalLevelsRequired, List<String> nameCSSList) {
        if (!approversFromApprovalHistory.isEmpty() && processInstanceList[0].Status != Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_RECALLED) {
            nameCSSList.addAll(approversFromApprovalHistory);
            processApproversWithHistory(approversFromScafRecord, approversFromApprovalHistory, scafApprovalLevelsRequired, nameCSSList, processInstanceList);
        } else {
            processApproversWithoutHistory(approversFromScafRecord, processInstanceList, nameCSSList);
        }
    }
     /*
        * Method Name                           : processApproversWithHistory
        * Description                           : To process approvers without Approval History
        * @ PARAMS 
        1. approversFromScafRecord              : List of Approvers from SCAF record matching with LSD Approval Matrix.
        2. approversFromApprovalHistory         : List of actual approvers from appoval history
        3. scafApprovalLevelsRequired           : Field value of Approval_Levels_Required__c
        4. nameCSSList                          : List of all actual approvers with its status.
        5. processInstanceList                  : List of processInstance from appoval history
    */
    private static void processApproversWithHistory(List<String> approversFromScafRecord, List<String> approversFromApprovalHistory, Integer scafApprovalLevelsRequired, List<String> nameCSSList, List<ProcessInstance> processInstanceList) {
        Integer sizeOfApproversFromApprovalHistory = approversFromApprovalHistory.Size();
        String lastActualApproverStatus = approversFromApprovalHistory.get(sizeOfApproversFromApprovalHistory-1);
        String status =  lastActualApproverStatus.substringAfter(Constants.LEGAL_SALES_STRING_SPLIT_CHAR);
        List<ProcessInstanceWorkitem> pendingApproverList = getProcessInstanceWorkItem(processInstanceList[0]);
        List<String> approversFromScafRecordClone = approversFromScafRecord.clone();
        
        if (status == Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_APPROVED && !pendingApproverList.isEmpty()) {
            handleApprovedApprovals(approversFromScafRecordClone, pendingApproverList,nameCSSList);
        } else {
            handleRejectedReassignedApproval(approversFromScafRecordClone,scafApprovalLevelsRequired,nameCSSList,sizeOfApproversFromApprovalHistory);
        }
    }
     /*
        * Method Name                           : handleApprovedApprovals
        * Description                           : To process approved Approvals
        * @ PARAMS 
        1. approversFromScafRecordClone         : Cloned list of Approvers from SCAF record matching with LSD Approval Matrix.
        2. pendingApproverList                  : List of ProcessInstanceWorkitem from appoval history
        3. nameCSSList                          : List of all actual approvers with its status
    */
    private static void handleApprovedApprovals(List<String> approversFromScafRecordClone, List<ProcessInstanceWorkitem> pendingApproverList,List<String> nameCSSList) {
        Integer nameCSSListSize = nameCSSList.Size();
        String pendingApproverName = pendingApproverList[0].OriginalActor.Name;
        for(integer i=0;i<nameCSSListSize;i++){
            approversFromScafRecordClone.remove(0);  
        }
        approversFromScafRecordClone.set(0,pendingApproverName + Constants.LEGAL_SALES_STRING_SPLIT_CHAR + Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_PENDING);
        nameCSSList.addall(approversFromScafRecordClone);
    }
    /*
        * Method Name                           : handleRejectedReassignedApproval
        * Description                           : To process Rejected / Reassigned Approvals
        * @ PARAMS 
        1. approversFromScafRecordClone         : Cloned list of Approvers from SCAF record matching with LSD Approval Matrix.
        2. scafApprovalLevelsRequired           : Field value of Approval_Levels_Required__c
        3. nameCSSList                          : List of all actual approvers with its status.
        4. sizeOfApproversFromApprovalHistory   : Size of ApproversFromApprovalHistory
    */
    private static void handleRejectedReassignedApproval(List<String> approversFromScafRecordClone,Integer scafApprovalLevelsRequired,List<String> nameCSSList,Integer sizeOfApproversFromApprovalHistory) {
        if(scafApprovalLevelsRequired !=1){
            for(integer i=0;i<sizeOfApproversFromApprovalHistory;i++){
                approversFromScafRecordClone.remove(0);    
            } 
        }else{
            for(integer i=0;i<sizeOfApproversFromApprovalHistory-1;i++){
                approversFromScafRecordClone.remove(0);   
            }
        }
        nameCSSList.addall(approversFromScafRecordClone);
    }
    /*
        * Method Name               : processApproversWithoutHistory
        * Description               : To process Approvers Without History i.e for first and last approver
        * @ PARAMS 
        1. approversFromScafRecord  : Approvers from SCAF record matching with LSD Approval Matrix.
        2. processInstanceList      : List of ProcessInstance from appoval history
        3. nameCSSList              : List of all approvers with its status.
    */
    private static void processApproversWithoutHistory(List<String> approversFromScafRecord, List<ProcessInstance> processInstanceList, List<String> nameCSSList) {
        List<String> approversFromScafRecordClone = approversFromScafRecord.clone();
        if (!processInstanceList.isEmpty() && processInstanceList[0].Status != Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_RECALLED){
            String approverNamePending = approversFromScafRecordClone[0].substringbefore(Constants.LEGAL_SALES_STRING_SPLIT_CHAR);
            approversFromScafRecordClone.set(0,approverNamePending + Constants.LEGAL_SALES_STRING_SPLIT_CHAR + Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_PENDING);
            nameCSSList.addall(approversFromScafRecordClone); 
        }else{
            nameCSSList.addall(approversFromScafRecord);
        }    
    }
    /*
        * Method Name   : buildChevronDataList
        * Description   : To build a list with approver name and css class to send to LWC
        * @ PARAMS 
        1. nameCSSList  : List of all approvers with its status.
    */
    private static List<chevronData> buildChevronDataList(List<String> nameCSSList) {
        Decimal maxVal = 100;
        Decimal widthPerItem = maxVal;
        if(!nameCSSList.isEmpty()){
            widthPerItem = maxVal.divide(nameCSSList.size(),2,System.RoundingMode.DOWN);
        }
        List<chevronData> lstRet = new List<chevronData>();        
        for( String eachNameCSS : nameCSSList)
        {
            chevronData obj = new chevronData();
            if(eachNameCSS.contains(Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_YET_TO_APPROVE)){
                obj.cssClass = '';
            }else{
                obj.cssClass = eachNameCSS.substringAfter(Constants.LEGAL_SALES_STRING_SPLIT_CHAR).trim();
            }
            obj.val = eachNameCSS.substringBefore(Constants.LEGAL_SALES_STRING_SPLIT_CHAR).trim();
            obj.width = widthPerItem+'%';        
            lstRet.add(obj);
        } 
        return lstRet;
    }
     /*
        * Method Name   : getProcessInstance
        * Description   : To get ProcessInstance for the current SCAF record from the approval history
        * @ PARAMS 
        1. recId        : Current SCAF record id
    */
    private static List<ProcessInstance> getProcessInstance(String recId){
        List<ProcessInstance> processInstanceList = [SELECT Id, Status, CreatedDate, CompletedDate, TargetObjectId, TargetObject.Type, TargetObject.Name
                                                     FROM ProcessInstance
                                                     WHERE TargetObjectId =: recId
                                                     AND TargetObject.Type = 'SCAF__c'
                                                     ORDER BY createdDate DESC];
        System.debug(LoggingLevel.INFO,'processInstanceList --> '+processInstanceList);
        return processInstanceList;
    }
    /*
        * Method Name                   : getProcessInstanceSteps
        * Description                   : To get ProcessInstanceStep for processInstance from the approval history
        * @ PARAMS 
        1. currentProcessInstance       : Current processInstance from the approval history
    */
    private static List<ProcessInstanceStep> getProcessInstanceSteps(ProcessInstance currentProcessInstance){
        List<ProcessInstanceStep> pISteps = [SELECT ActorId,Comments,CreatedById,CreatedDate,ElapsedTimeInDays,Id, 
                                             ElapsedTimeInHours,ElapsedTimeInMinutes,OriginalActorId,OriginalActor.Name,ProcessInstanceId,
                                             StepNodeId,StepStatus,SystemModstamp,Actor.Name 
                                             FROM ProcessInstanceStep
                                             WHERE ProcessInstanceId =:currentProcessInstance.Id order by createddate desc];
        return pISteps;
    }
    /*
        * Method Name                   : getProcessInstanceWorkItem
        * Description                   : To get ProcessInstanceWorkitem for processInstance from the approval history
        * @ PARAMS 
        1. currentProcessInstance       : Current processInstance from the approval history
    */
    private static List<ProcessInstanceWorkitem> getProcessInstanceWorkItem(ProcessInstance currentProcessInstance){
        List<ProcessInstanceWorkitem> pIworkItem = [Select id,ActorId,OriginalActorId,ElapsedTimeInHours,
                                                    ProcessInstanceId,ProcessInstance.TargetObjectId,OriginalActor.Name
                                                    FROM ProcessInstanceWorkitem
                                                    WHERE ProcessInstanceId =:currentProcessInstance.Id];
        return pIworkItem;
    }
    /*
        * Method Name                   : getActualApproversFromApprovalHistory
        * @Description                  : To get the Actual approver names (at each approver role) from the approved scaf record,
                                          so that we can display correct approvers in the Approval scaf path even if the Approval matrix changes in future
        * @ PARAMS 
        1. processInstanceStepList      : List of all the processInstanceStep from the approval history
    */
    private static List<String> getActualApproversFromApprovalHistory(List<ProcessInstanceStep> processInstanceStepList){
        List<String> actualApproversList = new List<String>();
        String stepStatus;
        if(processInstanceStepList != null){
            for(Integer i= processInstanceStepList.size()-1; i >= 0; i--){
                if(processInstanceStepList[i].StepStatus == Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_RECALLED || processInstanceStepList[i].StepStatus == Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_Started){
                    continue;
                }
                stepStatus = processInstanceStepList[i].StepStatus == Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_REASSIGNED ? Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_PENDING : processInstanceStepList[i].StepStatus;
                
                if(processInstanceStepList.size() > i+1 &&
                   processInstanceStepList[i+1].StepStatus == Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_REASSIGNED &&
                   processInstanceStepList[i].StepStatus == Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_APPROVED 
                   && processInstanceStepList[i].OriginalActor.Name == processInstanceStepList[i+1].OriginalActor.Name
                ){
                    actualApproversList.set(
                        actualApproversList.indexOf(processInstanceStepList[i+1].Actor.Name + Constants.LEGAL_SALES_STRING_SPLIT_CHAR + Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_PENDING),
                        processInstanceStepList[i].Actor.Name + Constants.LEGAL_SALES_STRING_SPLIT_CHAR + Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_APPROVED
                    );
                    continue;
                }else if(processInstanceStepList.size() > i+1 &&
                        processInstanceStepList[i+1].StepStatus == Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_REASSIGNED &&
                        processInstanceStepList[i].StepStatus == Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_REJECTED 
                        && processInstanceStepList[i].OriginalActor.Name == processInstanceStepList[i+1].OriginalActor.Name
                ){
                    actualApproversList.set(
                        actualApproversList.indexOf(processInstanceStepList[i+1].Actor.Name + Constants.LEGAL_SALES_STRING_SPLIT_CHAR + Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_PENDING),
                        processInstanceStepList[i].Actor.Name + Constants.LEGAL_SALES_STRING_SPLIT_CHAR + Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_REJECTED
                    );
                    continue;
                //146698 - Added condition to handle multiple reassignments    
                }else if(processInstanceStepList.size() > i+1 &&
                         processInstanceStepList[i+1].StepStatus == Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_REASSIGNED &&
                         processInstanceStepList[i].StepStatus == Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_REASSIGNED 
                         && processInstanceStepList[i].OriginalActor.Name == processInstanceStepList[i+1].OriginalActor.Name){
                            actualApproversList.set(
                                actualApproversList.indexOf(processInstanceStepList[i+1].Actor.Name + Constants.LEGAL_SALES_STRING_SPLIT_CHAR + Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_PENDING),
                                processInstanceStepList[i].Actor.Name + Constants.LEGAL_SALES_STRING_SPLIT_CHAR + Constants.LEGAL_SALES_PROCESS_INSTANCE_STATUS_PENDING);         
                             continue;
                        }
                actualApproversList.add(processInstanceStepList[i].Actor.Name + Constants.LEGAL_SALES_STRING_SPLIT_CHAR + stepStatus);
            }
            
        }
        return actualApproversList;
    }
    /*
        * Method Name                   : chevronData
        * @Description                  : chevronData wrapper class
    */   
    public class chevronData{
        public String val{get;set;}
        public String cssClass{get;set;}
        public String width {get;set;}
    }
}