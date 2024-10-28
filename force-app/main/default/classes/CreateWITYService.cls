/***********************************************************************************************************
* @author       CoreFlex   
* @Last Midified date :06-06-2024            
* @description  this class is created to handle WITY creation, Updation, and Deletion  
*************************************************************************************************************************/
public without sharing class CreateWITYService {
    
    @AuraEnabled
    public static List<VisitReportWrapper> getDataOnInit(){
        List<VisitReportWrapper> wraplist = new List<VisitReportWrapper>();
        List<Visit_Report_Data__mdt> visitMetaList = [SELECT Id,
                                                    Question_Name__c 
                                                    FROM Visit_Report_Data__mdt order by Question_Name__c ASC];
        for(Visit_Report_Data__mdt vrd : visitMetaList){
            wraplist.add(new VisitReportWrapper(false,vrd.Question_Name__c,null,null,vrd.Id,''));
        }
        return wraplist;
    } 
    
    @AuraEnabled
    public static List<VisitReportWrapper> getEditDataOnInit(Id wityId){
        List<VisitReportWrapper> wraplist = new List<VisitReportWrapper>();
        List<WITY_Scoring__c> wityScoringList = [SELECT Id,
                                                    Question_Name__c,Rating_One__c,Rating_Two__c,comments__c
                                                    FROM WITY_Scoring__c 
                                                 WHERE WITY_Key_Buying_Factors__c =: wityId];
        for(WITY_Scoring__c wsl : wityScoringList){
            wraplist.add(new VisitReportWrapper(false,wsl.Question_Name__c,Integer.valueOf(wsl.Rating_One__c),Integer.valueOf(wsl.Rating_Two__c),wsl.Id,wsl.Comments__c));
        }
        return wraplist;
    }
        /**
        * @description         Implementing to get VisitReport Related WITY Data
        * @param   visitReportId  passing visitreport id 
        */
    @AuraEnabled
    public static List<VisitReportWrapper> getVisitReportWityRelatedData(Id visitReportId){
        List<VisitReportWrapper> wraplist = new List<VisitReportWrapper>();
        //B2B144
        String sObjName = visitReportId.getSObjectType().getDescribe().getName();
        List<WITY_Scoring__c> wityScoringList = new List<WITY_Scoring__c>();
        if (sObjName == 'Field_of_Play__c') {
            // Query to get the WITY_Scoring__c records
            wityScoringList = [SELECT Id, Question_Name__c, Rating_One__c, Rating_Two__c, comments__c
                               FROM WITY_Scoring__c 
                               WHERE WITY_Key_Buying_Factors__r.Field_of_Play__c = :visitReportId];
        }else if(sObjName == 'Opportunity'){//B2B173
                // Query to get the StageName from Opportunity
            Opportunity opp = [SELECT StageName FROM Opportunity WHERE Id = :visitReportId LIMIT 1];
            String opportunityStage = opp.StageName;
            wityScoringList = [SELECT Id, Question_Name__c, Rating_One__c, Rating_Two__c, comments__c
                               FROM WITY_Scoring__c 
                               WHERE WITY_Key_Buying_Factors__r.WITY_Opportunity__c = :visitReportId
                               AND Opportuntiy_Stage__c = :opportunityStage];
        }else{
            wityScoringList = [SELECT Id,Question_Name__c,Rating_One__c,Rating_Two__c,comments__c
                                FROM WITY_Scoring__c 
                                WHERE WITY_Key_Buying_Factors__r.Visit_Report__c =: visitReportId];
        }
        //B2B144
        return convertWityScoringToWrapper(wityScoringList);
    }
        /**
         * @description         Implementing to get Account Plan Related WITY Data
        * @param   accRecId  passing accRecId id  
        */
    //B2B144
    @AuraEnabled
public static List<Map<String, Object>> getWityAccPlanWityRelatedData(Id accRecId) {
    String lastVisitReportId = null;
    // validate you can actually query what you intend to retrieve// validate you can actually query what you intend to retrieve
    List<WITY_Scoring__c> wityScorings = [
        SELECT Id, Question_Name__c, Rating_One__c, Rating_Two__c, Comments__c,
        WITY_Key_Buying_Factors__r.Visit_Report__r.Id, WITY_Key_Buying_Factors__r.Visit_Report__r.Name, 
        WITY_Key_Buying_Factors__r.Visit_Report__r.CreatedDate
        FROM WITY_Scoring__c 
        WHERE Field_of_Play__c = :accRecId
    ];

    List<Map<String, Object>> formattedResults = new List<Map<String, Object>>();
    for(WITY_Scoring__c wityScoring : wityScorings) {
        Map<String, Object> formattedResult = new Map<String, Object>();
        formattedResult.put('Id', wityScoring.Id);
        formattedResult.put('Question_Name__c', wityScoring.Question_Name__c);
        formattedResult.put('Rating_One__c', wityScoring.Rating_One__c);
        formattedResult.put('Rating_Two__c', wityScoring.Rating_Two__c);
        formattedResult.put('Comments__c', wityScoring.Comments__c);
        formattedResult.put('Visit_Report_Id', wityScoring.WITY_Key_Buying_Factors__r.Visit_Report__r.Id);
        formattedResult.put('Visit_Report_Name', wityScoring.WITY_Key_Buying_Factors__r.Visit_Report__r.Name);
        formattedResult.put('Created_Date_Formatted', wityScoring.WITY_Key_Buying_Factors__r.Visit_Report__r.CreatedDate != null ? wityScoring.WITY_Key_Buying_Factors__r.Visit_Report__r.CreatedDate.format('dd-MM-yyyy HH:mm') : null);
        Id visitReportId = wityScoring.WITY_Key_Buying_Factors__r.Visit_Report__r.Id;
        if (String.valueOf(lastVisitReportId) != String.valueOf(visitReportId)) {
            formattedResult.put('VisitReportId', visitReportId);
            formattedResult.put('VisitReportId1', visitReportId);
        }
        lastVisitReportId = wityScoring.WITY_Key_Buying_Factors__r.Visit_Report__r.Id; 

        formattedResults.add(formattedResult);
    }
    return formattedResults;
}
    //B2B144

    @AuraEnabled
    public static void saveRecords(String recordList,String vReportId){
        List<VisitReportWrapper> visiList = (List<VisitReportWrapper>)JSON.deserialize(recordList, List<VisitReportWrapper>.Class);
        Visit_Report__c visit = [Select Id from Visit_Report__c where Id =: vReportId];
        List<WITY_Scoring__c> wityList = new List<WITY_Scoring__c>();
        for(VisitReportWrapper vw : visiList){
            if(isInsertionRequired(vw)){
                WITY_Scoring__c wityScr = new WITY_Scoring__c();
                wityScr.Comments__c = vw.comments;
                wityScr.Question_Name__c = vw.quesName;
                wityScr.Rating_One__c = vw.ratingone;
                wityScr.Rating_Two__c = vw.ratingtwo;
                wityList.add(wityScr);
            }
        }
        if(!wityList.isEmpty()){
            Key_Buying_Factors__c ab = new Key_Buying_Factors__c();
            ab.Visit_Report__c = vReportId;
            insert ab;
            for(WITY_Scoring__c wity : wityList){
                wity.WITY_Key_Buying_Factors__c = ab.Id;
            }
            insert wityList;
        }
    }
        /**
         * @description      Implementing to upsertRecords
         * @param   recordList   list of records   
         * @param   vReportId  passing vReportId id  
         * @param   accRecId  passing accRecId id  
         * @param   curOppStage passing curOppStage value
        */
    @AuraEnabled
    public static List<VisitReportWrapper> upsertRecords(String recordList,String vReportId,String accountId, String curOppStage){
        List<VisitReportWrapper> visiList = (List<VisitReportWrapper>)JSON.deserialize(recordList, List<VisitReportWrapper>.Class);
        List<WITY_Scoring__c> wityToInsertList = new List<WITY_Scoring__c>();
        List<WITY_Scoring__c> wityToUpdateList = new List<WITY_Scoring__c>();
        Id recordId = vReportId;//B2144
        for (VisitReportWrapper vw : visiList) {
            WITY_Scoring__c wityScr = new WITY_Scoring__c();
            wityScr.Comments__c = vw.comments;
            wityScr.Question_Name__c = vw.quesName;
            wityScr.Rating_One__c = vw.ratingone;
            wityScr.Rating_Two__c = vw.ratingtwo;
            if(!String.isBlank(accountId) && String.isBlank(vw.recId)){//B2B144
                wityScr.Field_of_Play__c = string.valueOf(accountId);
            }else if(!String.isBlank(curOppStage) && String.isBlank(vw.recId)){//B2B173
                wityScr.Opportuntiy_Stage__c = string.valueOf(curOppStage);
            }
            if (String.isBlank(vw.recId)) {
                wityToInsertList.add(wityScr);
            }
            else {
                wityScr.Id = vw.recId;
                wityToUpdateList.add(wityScr);
            }
        }
        if (!wityToInsertList.isEmpty()) {
            Key_Buying_Factors__c keyBuyingFactorToInsert = new Key_Buying_Factors__c();
            //B2B144
            String sObjName = recordId.getSObjectType().getDescribe().getName();
            if(sObjName == 'Field_of_Play__c'){
                keyBuyingFactorToInsert.Field_of_Play__c = vReportId;
            }else if(sObjName == 'Opportunity'){//B2B173
                keyBuyingFactorToInsert.WITY_Opportunity__c = vReportId;
            }else{
                keyBuyingFactorToInsert.Visit_Report__c = vReportId;
            }//B2B144
            insert keyBuyingFactorToInsert;
            for (WITY_Scoring__c wity : wityToInsertList) {
                wity.WITY_Key_Buying_Factors__c = keyBuyingFactorToInsert.Id;
            }
            insert wityToInsertList;
        }
        if (!wityToUpdateList.isEmpty()) {
            update wityToUpdateList;
        }
        List<VisitReportWrapper> wrapListReturn = new List<VisitReportWrapper>();
        wrapListReturn.addAll(convertWityScoringToWrapper(wityToUpdateList));
        wrapListReturn.addAll(convertWityScoringToWrapper(wityToInsertList));
        return wrapListReturn;
    }
    
    @AuraEnabled
    public static void saveEditRecord(Id wityId,String records){
        System.debug('KeyId --> '+wityId);
        System.debug('records --> '+records);
        List<VisitReportWrapper> visiList = (List<VisitReportWrapper>)JSON.deserialize(records, List<VisitReportWrapper>.Class);
        System.debug('visiList --> '+visiList);
        List<WITY_Scoring__c> wityList = new List<WITY_Scoring__c>();
        List<WITY_Scoring__c> wityupdateList = new List<WITY_Scoring__c>();
        List<VisitReportWrapper> visitRepInsertList = new List<VisitReportWrapper>();
        Set<Id> wityIds = new Set<Id>();
        for(VisitReportWrapper vw : visiList){
            System.debug('vw --> '+vw);
            if(isUpdateRequired(vw)){
                wityIds.add(vw.recId);
                visitRepInsertList.add(vw);
                continue;
            }
            if(isInsertionRequired(vw)){
                WITY_Scoring__c wityScr = new WITY_Scoring__c();
                wityScr.WITY_Key_Buying_Factors__c = wityId;
                wityScr.Comments__c = vw.comments;
                wityScr.Question_Name__c = vw.quesName;
                wityScr.Rating_One__c = vw.ratingone;
                wityScr.Rating_Two__c = vw.ratingtwo;
                wityList.add(wityScr);
            }
        }
        if(!wityIds.isEmpty()){
            Map<Id,WITY_Scoring__c> wityScorMap = getWityScoringRecords(wityIds);
            for(VisitReportWrapper vw : visitRepInsertList){
                WITY_Scoring__c wityRec = wityScorMap.get(vw.recId);
                wityRec.Question_Name__c = vw.quesName;
                wityRec.Rating_One__c = vw.ratingone;
                wityRec.Rating_Two__c = vw.ratingtwo;
                wityRec.Comments__c = vw.comments;
                wityList.add(wityRec);
            }
        }
        if(!wityList.isEmpty()){
            upsert wityList;
        }
    }

    @AuraEnabled
    public static void deleteWityScoringRecord(String wityScoringId) {
        WITY_Scoring__c wityScoringRecord = [SELECT Id, WITY_Key_Buying_Factors__c FROM WITY_Scoring__c WHERE Id =: wityScoringId];
        system.debug('wityScoringRecord: ' + wityScoringRecord);
        if (wityScoringRecord != null) {
            Key_Buying_Factors__c relatedKeyBuyingFactor = [SELECT Id FROM Key_Buying_Factors__c WHERE Id =: wityScoringRecord.WITY_Key_Buying_Factors__c];
            List<WITY_Scoring__c> relatedKeyFactorWityRecords = [SELECT Id, WITY_Key_Buying_Factors__c FROM WITY_Scoring__c WHERE WITY_Key_Buying_Factors__c =: relatedKeyBuyingFactor.Id];
            delete wityScoringRecord;
            if (relatedKeyFactorWityRecords.size() == 1) {
                delete relatedKeyBuyingFactor;
            }
        }
                                                 
    }
    
    @AuraEnabled
    public static void deleteWityScoringRecords(List<String> wityScoringIds) {
        Set<String> keyBuyingFactorIds = new Set<String>();
        Set<String> keyBuyingFactorIdsRemaining = new Set<String>();
        List<Key_Buying_Factors__c> keyBuyingFactorsToDelete = new List<Key_Buying_Factors__c>();
        List<WITY_Scoring__c> wityScoringRecords = [SELECT Id, WITY_Key_Buying_Factors__c FROM WITY_Scoring__c WHERE Id IN :wityScoringIds];
        system.debug('wityScoringRecords: ' + wityScoringRecords);
        if (wityScoringRecords != null && wityScoringRecords.size() > 0) {
            for (WITY_Scoring__c wityScore : wityScoringRecords) {
                keyBuyingFactorIds.add(wityScore.WITY_Key_Buying_Factors__c);
            }
            delete wityScoringRecords;
            // List<Key_Buying_Factors__c> relatedKeyBuyingFactors = [SELECT Id FROM Key_Buying_Factors__c WHERE Id IN :keyBuyingFactorIds];
            // search for the key buying factors still with wity scores - ignore these on delete
            List<WITY_Scoring__c> relatedKeyFactorWityRecords = [SELECT Id, WITY_Key_Buying_Factors__c FROM WITY_Scoring__c WHERE WITY_Key_Buying_Factors__c IN :keyBuyingFactorIds];
            for (WITY_Scoring__c relatedWityScore : relatedKeyFactorWityRecords) {
                keyBuyingFactorIdsRemaining.add(relatedWityScore.WITY_Key_Buying_Factors__c);
            }
            for (String keyBuyingFactorId : keyBuyingFactorIds) {
                if (!keyBuyingFactorIdsRemaining.contains(keyBuyingFactorId)) {
                    Key_Buying_Factors__c toDelete = new Key_Buying_Factors__c();
                    toDelete.Id = keyBuyingFactorId;
                    keyBuyingFactorsToDelete.add(toDelete);
                }
            }
            if (keyBuyingFactorsToDelete.size() > 0) {
                delete keyBuyingFactorsToDelete;
            }
        }
                                                
    }
    
    private static Boolean isInsertionRequired(VisitReportWrapper vReport){
        return vReport != null &&
            (vReport.checkbox == true &&
            (vReport.quesName != '' || vReport.quesName != null) &&
            vReport.ratingone != null &&
            vReport.ratingtwo != null);
    }
    
    private static Boolean isUpdateRequired(VisitReportWrapper vReport){
        return vReport != null &&
            (vReport.checkbox == true &&
            vReport.recId != null);
    }
    
    
    @AuraEnabled
    public static List<WITY_Scoring__c> getWityDetails(String wityId){
        List<WITY_Scoring__c> wityrec = [SELECT Id,Question_Name__c,Rating_One__c,Comments__c,Rating_two__c,WITY_Key_Buying_Factors__r.Name,WITY_Key_Buying_Factors__r.visit_Report__c
                                        FROM WITY_Scoring__c
                                        WHERE WITY_Key_Buying_Factors__c =: wityId ];
        return wityrec;
    }
    
    @AuraEnabled
    public static VisitDataWrapper getVisitDataWrapper(String wityId){
        Key_Buying_Factors__c keybuying = [SELECT Id,Visit_Report__c,visit_report__r.Name,visit_report__r.Visit_Date__c
                                          FROM Key_Buying_Factors__c
                                          WHERE Id =: wityId];
        VisitDataWrapper vWrapper = new VisitDataWrapper(keybuying.visit_report__r.Name,keybuying.visit_report__r.Visit_Date__c,keybuying.Visit_Report__c );
        return vWrapper;
    }
    
    private static Map<Id,WITY_Scoring__c> getWityScoringRecords(Set<Id> wityIds){
        return new Map<Id,WITY_Scoring__c>([SELECT Id,
                Question_Name__c,Rating_One__c,Rating_Two__c,comments__c
                FROM WITY_Scoring__c 
                WHERE Id IN: wityIds]);
    }

    private static List<VisitReportWrapper> convertWityScoringToWrapper(List<WITY_Scoring__c> wityScoringList) {
        List<VisitReportWrapper> wrapList = new List<VisitReportWrapper>();
        for(WITY_Scoring__c wsl : wityScoringList){
            wraplist.add(new VisitReportWrapper(false,wsl.Question_Name__c,Integer.valueOf(wsl.Rating_One__c),Integer.valueOf(wsl.Rating_Two__c),wsl.Id,wsl.Comments__c));
        }
        return wrapList;
    }

    public class VisitDataWrapper{
        @AuraEnabled public String visitName {set;get;}
        @AuraEnabled public Date visitDate {set;get;}
        @AuraEnabled public String visitId {set;get;}

        public VisitDataWrapper(String visName,Date visDate,String visId){
            this.visitName = visName;
            this.visitDate = visDate;
            this.visitId = visId;
        }
        
    }

    public class VisitReportWrapper{
        @AuraEnabled public boolean checkbox { set; get; }
        @AuraEnabled public String quesName { set; get; }
        @AuraEnabled public Integer ratingone { set; get; }
        @AuraEnabled public Integer ratingtwo { set; get; }
        @AuraEnabled public Id recId{set;get;}
        @AuraEnabled public String comments{set;get;}


        public VisitReportWrapper(Boolean chk,String ques,Integer ratone,Integer rattwo,Id recId,String comm){
            this.checkbox = chk;
            this.quesName = ques;
            this.ratingone = ratone;
            this.ratingtwo = rattwo;
            this.recId = recId;
            this.comments = comm;
        }
    }
    /**
        *@ Implementing to get getRecordTypeName
        * @param   recordId  passing recordId 
    */
    //B2B144
    @AuraEnabled
    public static String getRecordTypeName(Id recordId) {
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        String recordTypeName = '';
        if (sObjName == 'Field_of_Play__c') {
            List<Field_of_Play__c> accountPlanRecords = [SELECT RecordType.Name FROM Field_of_Play__c WHERE Id = :recordId LIMIT 1];
            if (!accountPlanRecords.isEmpty()) {
                recordTypeName = accountPlanRecords[0].RecordType.Name;
            }
        } else if (sObjName == 'Opportunity') { //B2B173
            List<Opportunity> opportunityRecords = [SELECT RecordType.Name FROM Opportunity WHERE Id = :recordId LIMIT 1];
            if (!opportunityRecords.isEmpty()) {
                recordTypeName = opportunityRecords[0].RecordType.Name;
            }
        } else if (sObjName == 'Visit_Report__c') {
            List<Visit_Report__c> visitReportRecords = [SELECT RecordType.Name FROM Visit_Report__c WHERE Id = :recordId LIMIT 1];
            if (!visitReportRecords.isEmpty()) {
                recordTypeName = visitReportRecords[0].RecordType.Name;
            }
        }
        return recordTypeName;
    }
    /**
     * @description         Implementing to get Account Plans Related WITY Data
    * @param   searchTerm  passing searchTerm  
    * @param   recordId  passing recordId   
    */
    @AuraEnabled
    public static List<Field_of_Play__c> getAccountPlans(String searchTerm, String recordId) {
        //String searchPattern = '%' + searchTerm + '%';
        Id customerId;
        // validate you can actually query what you intend to retrieve
        Visit_Report__c visitReport = [SELECT Customer_Name__r.Id FROM Visit_Report__c WHERE Id = :recordId LIMIT 1];
        if (visitReport != null && visitReport.Customer_Name__r != null) {
            customerId = visitReport.Customer_Name__r.Id;
        }
        if (customerId != null) {
            String searchPattern = '%' + searchTerm + '%';
            return [SELECT Id, Name, RecordType.Name 
                    FROM Field_of_Play__c 
                    WHERE Name LIKE :searchPattern
                    AND Account__r.Id = :customerId 
                    //AND RecordType.Name = 'FCP Account Plan' 
                    ORDER BY Name];
        } else {
            return new List<Field_of_Play__c>();
        }
        //return [SELECT Id, Name, RecordType.Name FROM Field_of_Play__c WHERE RecordType.Name = 'FCP Account Plan' AND Name LIKE :searchPattern ORDER BY Name];
    }
    //B2B144
    //B2B173
    /**
    * @description         Implementing to get Opportunity Stage
    * @param   recordId  passing recordId   
    */
    @AuraEnabled
    public static String getOpportunityStage(Id recordId) {
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        String oppStageName = '';
        if (sObjName == 'Opportunity') {
            List<Opportunity> opportunityRecords = [SELECT StageName FROM Opportunity WHERE Id = :recordId LIMIT 1];
            if (!opportunityRecords.isEmpty()) {
                oppStageName = opportunityRecords[0].StageName;
                System.debug('oppStageName --> '+oppStageName);
            }
        }
        return oppStageName;
    }

    @AuraEnabled
    public static List<Map<String, Object>> getOppStageWITYData(Id recordId) {
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        Opportunity opp = [SELECT StageName FROM Opportunity WHERE Id = :recordId LIMIT 1];
        String opportunityStage = opp.StageName;
        List<WITY_Scoring__c> wityScorings = [
            SELECT Id, Question_Name__c, Rating_One__c, Rating_Two__c, Comments__c
            FROM WITY_Scoring__c 
            WHERE WITY_Key_Buying_Factors__r.WITY_Opportunity__c = :recordId 
            AND Opportuntiy_Stage__c != :opportunityStage 
        ];
    
        List<Map<String, Object>> formattedResults = new List<Map<String, Object>>();
        for(WITY_Scoring__c wityScoring : wityScorings) {
            Map<String, Object> formattedResult = new Map<String, Object>();
            formattedResult.put('Id', wityScoring.Id);
            formattedResult.put('questionName', wityScoring.Question_Name__c);
            formattedResult.put('ratingOne', wityScoring.Rating_One__c);
            formattedResult.put('ratingTwo', wityScoring.Rating_Two__c);
            formattedResult.put('comments', wityScoring.Comments__c);
            formattedResults.add(formattedResult);
        }
        return formattedResults;
    }
    //B2B173
}