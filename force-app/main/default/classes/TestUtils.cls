/* *******************************************************************************************************
 * Name               : TestUtils                                                                        *
 * Description        : SRM - Test Data Factory - this factory contains methods for creating either single     *
 *      or multiple records of given object type                                                         *
 *      The records have default field values but can be overwritten by values from template passed      *
 *      from method invocation. You can search methods by object API Name or Label                       *
 *                                                                                                       *
 * Created Date       : 07-Jul-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       07-Jul-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */

@IsTest
public with sharing class TestUtils {

    public static Integer INDEX_CLASS_HELPER = 0;

    /***************************************************************************************
    Description: FACTORY FOR Account - Account
    ****************************************************************************************/
    public static Account newAccount(Account accountTemplate, Boolean isInsert) {
        return newAccounts(accountTemplate, 1, isInsert)[0];
    }

    public static List<Account> newAccounts(Account accountTemplate, Integer count, Boolean isInsert) {
        List<Account> result = new List<Account>();

        if(accountTemplate == NULL) accountTemplate = new Account();

        for (Integer i = 0; i < count; i++) {
            Account acc = accountTemplate.clone(false, true);
            if (accountTemplate.Name == NULL)                   acc.Name = 'Test Account ' + String.valueOf(INDEX_CLASS_HELPER) +  Math.random();
            if (accountTemplate.BillingCountry == NULL)         acc.BillingCountry = 'Germany';
            if (accountTemplate.BillingCity == NULL)            acc.BillingCity = 'Berlin';
            acc.RecordTypeId = ConstUtils.ACCOUNT_RECORD_TYPE;
            result.add(acc);
            INDEX_CLASS_HELPER++;
        }

        if (isInsert) {
            Database.DMLOptions dbDML = new Database.DMLOptions();
            dbDML.DuplicateRuleHeader.allowSave = true;
            dbDML.DuplicateRuleHeader.runAsCurrentUser = true;
            List<Database.SaveResult> srs = Database.insert(result, dbDML);
        }
        return result;
    }

    /***************************************************************************************
    Description: FACTORY FOR Contact - Contact
    ****************************************************************************************/
    public static Contact newContact(Contact contactTemplate, Boolean isInsert) {
        return newContacts(contactTemplate, 1, isInsert)[0];
    }

    public static List<Contact> newContacts(Contact contactTemplate, Integer count, Boolean isInsert) {
        List<Contact> result = new List<Contact>();

        if(contactTemplate == NULL) contactTemplate = new Contact();

        Id accId;
        if (contactTemplate.AccountId == null) {
            accId = newAccount(new Account(), true).Id;
        } else {
            accId = contactTemplate.AccountId;
        }

        for (Integer i = 0; i < count; i++) {
            Contact cnt = contactTemplate.clone(false, true);

            if (contactTemplate.AccountId == null)  cnt.AccountId = accId;
            if (contactTemplate.Email == null)      cnt.Email = 'testEmailtest' + String.valueOf(INDEX_CLASS_HELPER) + Math.random() + '@testcode.com';
            if (contactTemplate.LastName == null)   cnt.LastName = 'TestLastName' + String.valueOf(INDEX_CLASS_HELPER) + Math.random();
            if (contactTemplate.RecordTypeId == NULL)           cnt.RecordTypeId = ConstUtils.CONTACT_RECORD_TYPE;
            result.add(cnt);
            INDEX_CLASS_HELPER++;
        }

        if (isInsert) insert result;
        return result;
    }

    /***************************************************************************************
    Description: FACTORY FOR Task - Task
    ****************************************************************************************/
    public static Task newTask(Task contactTemplate, Boolean isInsert) {
        return newTasks(contactTemplate, 1, isInsert)[0];
    }

    public static List<Task> newTasks(Task taskTemplate, Integer count, Boolean isInsert) {
        List<Task> result = new List<Task>();

        if(taskTemplate == NULL) taskTemplate = new Task();

        Id accId;
        if (taskTemplate.AccountId == null) {
            accId = newAccount(new Account(), true).Id;
        } else {
            accId = taskTemplate.AccountId;
        }

        for (Integer i = 0; i < count; i++) {
            Task cnt = taskTemplate.clone(false, true);

            if (taskTemplate.Subject == null)           cnt.Subject = 'Sample subject' + INDEX_CLASS_HELPER;
            if (taskTemplate.Description == null)       cnt.Description = 'Sample description' + INDEX_CLASS_HELPER;
            if (taskTemplate.ActivityDate == null)      cnt.ActivityDate = Date.today().addDays(INDEX_CLASS_HELPER);
            if (taskTemplate.OwnerId == null)           cnt.OwnerId = UserInfo.getUserId();
            if (taskTemplate.WhatId == null)            cnt.WhatId = accId;
            result.add(cnt);
            INDEX_CLASS_HELPER++;
        }

        if (isInsert) insert result;
        return result;
    }

    /***************************************************************************************
    Description: FACTORY FOR Supplier_Hub__c - Supplier Hub
    ****************************************************************************************/
    public static Supplier_Hub__c newSupplierHub(Supplier_Hub__c supplierHubTemplate, Boolean isInsert) {
        return newSupplierHubs(supplierHubTemplate, 1, isInsert)[0];
    }

    public static List<Supplier_Hub__c> newSupplierHubs(Supplier_Hub__c supplierHubTemplate, Integer count, Boolean isInsert) {
        List<Supplier_Hub__c> result = new List<Supplier_Hub__c>();

        if(supplierHubTemplate == NULL) supplierHubTemplate = new Supplier_Hub__c();

        Id accId;
        if (supplierHubTemplate.Supplier_Account__c == NULL) {
            accId = newAccount(new Account(), true).Id;
        } else {
            accId = supplierHubTemplate.Supplier_Account__c;
        }

        for (Integer i = 0; i < count; i++) {
            Supplier_Hub__c sh = supplierHubTemplate.clone(false, true);
            if (sh.Supplier_Account__c == NULL)     sh.Supplier_Account__c = accId;

            result.add(sh);
        }
System.debug('@@@ ' + result);
        if (isInsert) insert result;
        return result;
    }

    /***************************************************************************************
    Description: FACTORY FOR Assessment__c - Assessment
    ****************************************************************************************/
    public static Assessment__c newAssessment(Assessment__c assessmentTemplate, Boolean isInsert) {
        return newAssessments(assessmentTemplate, 1, isInsert)[0];
    }

    public static List<Assessment__c> newAssessments(Assessment__c assessmentTemplate, Integer count, Boolean isInsert) {
        List<Assessment__c> result = new List<Assessment__c>();

        if(assessmentTemplate == NULL) assessmentTemplate = new Assessment__c();

        for (Integer i = 0; i < count; i++) {
            Assessment__c iAs = assessmentTemplate.clone(false, true);
            if (assessmentTemplate.Assessment_Type__c == NULL)  iAs.Assessment_Type__c = ConstUtils.ASSESSMENT_TYPE_GET_WELL;
            if (assessmentTemplate.Status__c == NULL)           iAs.Status__c = ConstUtils.ASSESSMENT_STATUS_READY;


            result.add(iAs);
        }

        if (isInsert) insert result;
        return result;
    }

    /***************************************************************************************
    Description: FACTORY FOR Assessment__Scoring__c - Assessment Scoring
    ****************************************************************************************/
    public static Assessment_Scoring__c newAssessmentScoring(Assessment_Scoring__c assessmentScoringTemplate, Boolean isInsert) {
        return newAssessmentScorings(assessmentScoringTemplate, 1, isInsert)[0];
    }

    public static List<Assessment_Scoring__c> newAssessmentScorings(Assessment_Scoring__c assessmentScoringTemplate, Integer count, Boolean isInsert) {
        List<Assessment_Scoring__c> result = new List<Assessment_Scoring__c>();

        if(assessmentScoringTemplate == NULL) assessmentScoringTemplate = new Assessment_Scoring__c();

        Id subHubId, asId;
        if (assessmentScoringTemplate.Supplier_Account__c == NULL) {
            subHubId = newSupplierHub(new Supplier_Hub__c(), true).Id;
        } else {
            subHubId = assessmentScoringTemplate.Supplier_Account__c;
        }
        if (assessmentScoringTemplate.Assessment__c == NULL) {
            asId = newAssessment(new Assessment__c(), true).Id;
        } else {
            asId = assessmentScoringTemplate.Assessment__c;
        }

        for (Integer i = 0; i < count; i++) {
            Assessment_Scoring__c ass = assessmentScoringTemplate.clone(false, true);
            if (assessmentScoringTemplate.Supplier_Account__c == NULL)  ass.Supplier_Account__c = subHubId;
            if (assessmentScoringTemplate.Assessment__c == NULL)        ass.Assessment__c = asId;
            if (assessmentScoringTemplate.Assessment_Type__c == NULL)   ass.Assessment_Type__c = 'TestValue';

            result.add(ass);
        }

        if (isInsert) insert result;
        return result;
    }


    /***************************************************************************************
    Description: FACTORY FOR Assessment_Scoring_Item__c - Assessment Scoring Item
    ****************************************************************************************/
    public static Assessment_Scoring_Item__c newAssessmentScoringItem(Assessment_Scoring_Item__c assessmentScoringItemTemplate, Boolean isInsert) {
        return newAssessmentScoringItems(assessmentScoringItemTemplate, 1, isInsert)[0];
    }

    public static List<Assessment_Scoring_Item__c> newAssessmentScoringItems(Assessment_Scoring_Item__c assessmentScoringItemTemplate, Integer count, Boolean isInsert) {
        List<Assessment_Scoring_Item__c> result = new List<Assessment_Scoring_Item__c>();

        if(assessmentScoringItemTemplate == NULL) assessmentScoringItemTemplate = new Assessment_Scoring_Item__c();

        Id asId;
        if (assessmentScoringItemTemplate.Assessment_Scoring__c == NULL) {
            asId = newAssessmentScoring(new Assessment_Scoring__c(), true).Id;
        } else {
            asId = assessmentScoringItemTemplate.Assessment_Scoring__c;
        }

        for (Integer i = 0; i < count; i++) {
            Assessment_Scoring_Item__c asi = assessmentScoringItemTemplate.clone(false, true);
            if (assessmentScoringItemTemplate.Assessment_Scoring__c == NULL)    asi.Assessment_Scoring__c = asId;
            if (assessmentScoringItemTemplate.Detailed_Question__c == NULL)     asi.Detailed_Question__c = 'Is it right or is it wrong?';
            if (assessmentScoringItemTemplate.Score__c == NULL)                 asi.Score__c = '2';
            if (assessmentScoringItemTemplate.Score_1_Used__c == NULL)          asi.Score_1_Used__c = true;
            if (assessmentScoringItemTemplate.Score_Choice_1__c == NULL)        asi.Score_Choice_1__c = 'Yes';
            if (assessmentScoringItemTemplate.Score_2_Used__c == NULL)          asi.Score_2_Used__c = true;
            if (assessmentScoringItemTemplate.Score_Choice_2__c == NULL)        asi.Score_Choice_2__c = 'No';

            result.add(asi);
        }

        if (isInsert) insert result;
        return result;
    }


    /***************************************************************************************
    Description: FACTORY FOR Question__c - Question
    ****************************************************************************************/
    public static Question__c newQuestion(Question__c questionTemplate, Boolean isInsert) {
        return newQuestions(questionTemplate, 1, isInsert)[0];
    }

    public static List<Question__c> newQuestions(Question__c questionTemplate, Integer count, Boolean isInsert) {
        List<Question__c> result = new List<Question__c>();

        if(questionTemplate == NULL) questionTemplate = new Question__c();

        for (Integer i = 0; i < count; i++) {
            Question__c q = questionTemplate.clone(false, true);
            if (questionTemplate.Question_ExternalId__c == NULL)    q.Question_ExternalId__c = 'WAEG' + String.valueOf(INDEX_CLASS_HELPER) + Decimal.valueOf(Math.random()).setScale(4);
            if (questionTemplate.Question_Summary__c == NULL)       q.Question_Summary__c = 'Sample Test Question Summary' + String.valueOf(INDEX_CLASS_HELPER);
            if (questionTemplate.Score_1_Percent__c == NULL)        q.Score_1_Percent__c = 20;
            if (questionTemplate.Score_2_Percent__c == NULL)        q.Score_2_Percent__c = 50;
            if (questionTemplate.Score_3_Percent__c == NULL)        q.Score_3_Percent__c = 60;
            if (questionTemplate.Score_4_Percent__c == NULL)        q.Score_4_Percent__c = 75;
            if (questionTemplate.Score_5_Percent__c == NULL)        q.Score_5_Percent__c = 100;

            INDEX_CLASS_HELPER++;
            result.add(q);
        }

        if (isInsert) insert result;
        return result;
    }


    /***************************************************************************************
   Description: FACTORY FOR Assessment_Question__c - Assessment Question
   ****************************************************************************************/
    public static Assessment_Question__c newAssessmentQuestion(Assessment_Question__c assessmentQuestionTemplate, Boolean isInsert) {
        return newAssessmentQuestions(assessmentQuestionTemplate, 1, isInsert)[0];
    }

    public static List<Assessment_Question__c> newAssessmentQuestions(Assessment_Question__c assessmentQuestionTemplate, Integer count, Boolean isInsert) {
        List<Assessment_Question__c> result = new List<Assessment_Question__c>();

        if(assessmentQuestionTemplate == NULL) assessmentQuestionTemplate = new Assessment_Question__c();

        Id asId, qId;
        if (assessmentQuestionTemplate.Assessment__c == NULL) {
            asId = newAssessment(new Assessment__c(), true).Id;
        } else {
            asId = assessmentQuestionTemplate.Assessment__c;
        }
        if (assessmentQuestionTemplate.Question__c == NULL) {
            qId = newQuestion(new Question__c(), true).Id;
        } else {
            qId = assessmentQuestionTemplate.Question__c;
        }

        for (Integer i = 0; i < count; i++) {
            Assessment_Question__c aq = assessmentQuestionTemplate.clone(false, true);
            if (assessmentQuestionTemplate.Assessment__c == NULL)  aq.Assessment__c = asId;
            if (assessmentQuestionTemplate.Question__c == NULL)  aq.Question__c = qId;
            if (assessmentQuestionTemplate.Sequence__c == NULL)  aq.Sequence__c = i+1;

            result.add(aq);
        }

        if (isInsert) insert result;
        return result;
    }

    /***************************************************************************************
   Description: FACTORY FOR Supplier_Rating__c - Supplier Rating
   ****************************************************************************************/
    public static Supplier_Rating__c newSupplierRating(Supplier_Rating__c supplierRatingTemplate, Boolean isInsert) {
        return newSupplierRatings(supplierRatingTemplate, 1, isInsert)[0];
    }

    public static List<Supplier_Rating__c> newSupplierRatings(Supplier_Rating__c supplierRatingTemplate, Integer count, Boolean isInsert) {
        List<Supplier_Rating__c> result = new List<Supplier_Rating__c>();

        if(supplierRatingTemplate == NULL) supplierRatingTemplate = new Supplier_Rating__c();

        Id shId, veId, srhId, lId;
        if (supplierRatingTemplate.Supplier_Hub__c == NULL) {
            shId = newSupplierHub(null, true).Id;
        } else {
            shId = supplierRatingTemplate.Supplier_Hub__c;
        }
        if (supplierRatingTemplate.Value_Element__c == NULL) {
            veId = newValueElement(null, true).Id;
        } else {
            veId = supplierRatingTemplate.Value_Element__c;
        }
        if (supplierRatingTemplate.Supplier_Rating_Header__c == NULL) {
            srhId = newSupplierRatingHeader(null, true).Id;
        } else {
            srhId = supplierRatingTemplate.Supplier_Rating_Header__c;
        }
        if (supplierRatingTemplate.Location__c == NULL) {
            lId = newLocation(null, true).Id;
        } else {
            lId = supplierRatingTemplate.Location__c;
        }
        supplierRatingTemplate.SRM_Business_Group__c  = 'INGREDIENTS';

        for (Integer i = 0; i < count; i++) {
            Supplier_Rating__c sr = supplierRatingTemplate.clone(false, true);
            if (supplierRatingTemplate.Supplier_Hub__c == NULL)                 sr.Supplier_Hub__c = shId;
            if (supplierRatingTemplate.Rating__c == NULL)                       sr.Rating__c = Math.mod(i,4) == 0 ? '1' : String.valueOf(Math.mod(i,4));
            if (supplierRatingTemplate.Value_Element__c == NULL)                sr.Value_Element__c = veId;
            if (supplierRatingTemplate.Comment__c == NULL)                      sr.Comment__c = 'Random comment ' + Math.random();
            if (supplierRatingTemplate.Supplier_Rating_Header__c == NULL)       sr.Supplier_Rating_Header__c = srhId;
            if (supplierRatingTemplate.Location__c == NULL)                     sr.Location__c = lId;

            result.add(sr);
        }

        if (isInsert) insert result;
        return result;
    }


    /***************************************************************************************
   Description: FACTORY FOR Supplier_Rating_Header__c - Supplier Rating Header
   ****************************************************************************************/
    public static Supplier_Rating_Header__c newSupplierRatingHeader(Supplier_Rating_Header__c supplierRatingHeaderTemplate, Boolean isInsert) {
        return newSupplierRatingHeaders(supplierRatingHeaderTemplate, 1, isInsert)[0];
    }

    public static List<Supplier_Rating_Header__c> newSupplierRatingHeaders(Supplier_Rating_Header__c supplierRatingHeaderTemplate, Integer count, Boolean isInsert) {
        List<Supplier_Rating_Header__c> result = new List<Supplier_Rating_Header__c>();

        if(supplierRatingHeaderTemplate == NULL) supplierRatingHeaderTemplate = new Supplier_Rating_Header__c();

        Id shId;
        if (supplierRatingHeaderTemplate.Supplier_Hub__c == NULL) {
            shId = newSupplierHub(null, true).Id;
        } else {
            shId = supplierRatingHeaderTemplate.Supplier_Hub__c;
        }

        for (Integer i = 0; i < count; i++) {
            Supplier_Rating_Header__c srh = supplierRatingHeaderTemplate.clone(false, true);
            if (supplierRatingHeaderTemplate.Supplier_Hub__c == NULL)                 srh.Supplier_Hub__c = shId;

            result.add(srh);
        }

        if (isInsert) insert result;
        return result;
    }

    /***************************************************************************************
   Description: FACTORY FOR Value_Element__c - Value Element
   ****************************************************************************************/
    public static Value_Element__c newValueElement(Value_Element__c valueElementTemplate, Boolean isInsert) {
        return newValueElements(valueElementTemplate, 1, isInsert)[0];
    }

    public static List<Value_Element__c> newValueElements(Value_Element__c valueElementTemplate, Integer count, Boolean isInsert) {
        List<Value_Element__c> result = new List<Value_Element__c>();

        if(valueElementTemplate == NULL) valueElementTemplate = new Value_Element__c();

        for (Integer i = 0; i < count; i++) {
            Value_Element__c ve = valueElementTemplate.clone(false, true);
            if (valueElementTemplate.Name == NULL)                      ve.Name = 'Random category ' + INDEX_CLASS_HELPER;
            if (valueElementTemplate.Is_Active__c == NULL)              ve.Is_Active__c = true;
            if (valueElementTemplate.Segment__c == NULL)                ve.Segment__c =  (Math.mod(i,3) == 0 ? ConstUtils.SUPPLIER_HUB_SEGMENT_STRATEGIC : (Math.mod(i,3) == 1 ? ConstUtils.SUPPLIER_HUB_SEGMENT_KEY : ConstUtils.SUPPLIER_HUB_SEGMENT_MANAGED));

            INDEX_CLASS_HELPER++;
            result.add(ve);
        }

        if (isInsert) insert result;
        return result;
    }

    /***************************************************************************************
   Description: FACTORY FOR Location__c - Location
   ****************************************************************************************/
    public static Location__c newLocation(Location__c locationTemplate, Boolean isInsert) {
        return newLocations(locationTemplate, 1, isInsert)[0];
    }

    public static List<Location__c> newLocations(Location__c locationTemplate, Integer count, Boolean isInsert) {
        List<Location__c> result = new List<Location__c>();

        if(locationTemplate == NULL) locationTemplate = new Location__c();

        for (Integer i = 0; i < count; i++) {
            Location__c lo = locationTemplate.clone(false, true);
            if (locationTemplate.Name == NULL)                                  lo.Name = 'London' + '_' + INDEX_CLASS_HELPER;
                                      lo.Is_Active__c = true;
            if (locationTemplate.Supplier_Location_ID__c == NULL)               lo.Supplier_Location_ID__c =  'LON_' + INDEX_CLASS_HELPER;

            INDEX_CLASS_HELPER++;
            result.add(lo);
        }
        if (isInsert) insert result;
        return result;
    }


    /***************************************************************************************
   Description: FACTORY FOR Supplier_Location__c - Supplier Location
   ****************************************************************************************/
    public static Supplier_Location__c newSupplierLocation(Supplier_Location__c supplierLocationTemplate, Boolean isInsert) {
        return newSupplierLocations(supplierLocationTemplate, 1, isInsert)[0];
    }

    public static List<Supplier_Location__c> newSupplierLocations(Supplier_Location__c supplierLocationTemplate, Integer count, Boolean isInsert) {
        List<Supplier_Location__c> result = new List<Supplier_Location__c>();

        if(supplierLocationTemplate == NULL) supplierLocationTemplate = new Supplier_Location__c();

        Id shId, lId;
        if (supplierLocationTemplate.Supplier_Hub__c == NULL) {
            shId = newSupplierHub(null, true).Id;
        } else {
            shId = supplierLocationTemplate.Supplier_Hub__c;
        }
        if (supplierLocationTemplate.Location__c == NULL) {
            lId = newLocation(null, true).Id;
        } else {
            lId = supplierLocationTemplate.Location__c;
        }
        if (supplierLocationTemplate.Business_Group__c == NULL) {
            supplierLocationTemplate.Business_Group__c = 'FOOD & BEVERAGE';
        }

        for (Integer i = 0; i < count; i++) {
            Supplier_Location__c sl = supplierLocationTemplate.clone(false, true);
            if (supplierLocationTemplate.Supplier_Hub__c == NULL)           sl.Supplier_Hub__c = shId;
            if (supplierLocationTemplate.Location__c == NULL)               sl.Location__c = lId;

            result.add(sl);
        }

        if (isInsert) insert result;
        return result;
    }

    /***************************************************************************************
   Description: FACTORY FOR Supplier_Team__c - Supplier Team
   ****************************************************************************************/
    public static Supplier_Team__c newSupplierTeam(Supplier_Team__c supplierTeamTemplate, Boolean isInsert) {
        return newSupplierTeams(supplierTeamTemplate, 1, isInsert)[0];
    }

    public static List<Supplier_Team__c> newSupplierTeams(Supplier_Team__c supplierTeamTemplate, Integer count, Boolean isInsert) {
        List<Supplier_Team__c> result = new List<Supplier_Team__c>();

        if(supplierTeamTemplate == NULL) supplierTeamTemplate = new Supplier_Team__c();

        Id shId, uId;
        if (supplierTeamTemplate.Supplier_Hub__c == NULL) {
            shId = newSupplierHub(null, true).Id;
        } else {
            shId = supplierTeamTemplate.Supplier_Hub__c;
        }
        if (supplierTeamTemplate.User__c == NULL) {
            uId = UserInfo.getUserId();
        } else {
            uId = supplierTeamTemplate.User__c;
        }

        for (Integer i = 0; i < count; i++) {
            Supplier_Team__c st = supplierTeamTemplate.clone(false, true);
            if (supplierTeamTemplate.Supplier_Hub__c == NULL)           st.Supplier_Hub__c = shId;
            if (supplierTeamTemplate.User__c == NULL)                   st.User__c = uId;
            if (supplierTeamTemplate.Type__c == NULL)                   st.Type__c = ConstUtils.SUPPLIER_TEAM_TYPE_INTERNAL;

            result.add(st);
        }

        if (isInsert) insert result;
        return result;
    }

    /***************************************************************************************
   Description: FACTORY FOR Supplier_Contract__c - Supplier Contract
   ****************************************************************************************/
    public static Supplier_Contract__c newSupplierContract(Supplier_Contract__c supplierContractTemplate, Boolean isInsert) {
        return newSupplierContracts(supplierContractTemplate, 1, isInsert)[0];
    }

    public static List<Supplier_Contract__c> newSupplierContracts(Supplier_Contract__c supplierContractTemplate, Integer count, Boolean isInsert) {
        List<Supplier_Contract__c> result = new List<Supplier_Contract__c>();

        if(supplierContractTemplate == NULL) supplierContractTemplate = new Supplier_Contract__c();

        Id shId;
        if (supplierContractTemplate.Supplier_Hub__c == NULL) {
            shId = newSupplierHub(null, true).Id;
        } else {
            shId = supplierContractTemplate.Supplier_Hub__c;
        }

        for (Integer i = 0; i < count; i++) {
            Supplier_Contract__c sc = supplierContractTemplate.clone(false, true);
            if (supplierContractTemplate.Supplier_Hub__c == NULL)           sc.Supplier_Hub__c = shId;

            result.add(sc);
        }

        if (isInsert) insert result;
        return result;
    }

    /***************************************************************************************
   Description: FACTORY FOR Supplier_KPI__c - Supplier KPI
   ****************************************************************************************/
    public static Supplier_KPI__c newSupplierKPI(Supplier_KPI__c supplierKpiTemplate, Boolean isInsert) {
        return newSupplierKPIs(supplierKpiTemplate, 1, isInsert)[0];
    }

    public static List<Supplier_KPI__c> newSupplierKPIs(Supplier_KPI__c supplierKpiTemplate, Integer count, Boolean isInsert) {
        List<Supplier_KPI__c> result = new List<Supplier_KPI__c>();

        if(supplierKpiTemplate == NULL) supplierKpiTemplate = new Supplier_KPI__c();

        Id shId;
        if (supplierKpiTemplate.Supplier_Hub__c == NULL) {
            shId = newSupplierHub(null, true).Id;
        } else {
            shId = supplierKpiTemplate.Supplier_Hub__c;
        }

        for (Integer i = 0; i < count; i++) {
            Supplier_KPI__c sk = supplierKpiTemplate.clone(false, true);
            if (supplierKpiTemplate.Supplier_Hub__c == NULL)           sk.Supplier_Hub__c = shId;

            result.add(sk);
        }

        if (isInsert) insert result;
        return result;
    }

    /***************************************************************************************
   Description: FACTORY FOR Joint_Business_Plan__c - Joint Business Plan
   ****************************************************************************************/
    public static Joint_Business_Plan__c newJointBusinessPlan(Joint_Business_Plan__c JointBusinessPlanTemplate, Boolean isInsert) {
        return newJointBusinessPlans(JointBusinessPlanTemplate, 1, isInsert)[0];
    }

    public static List<Joint_Business_Plan__c> newJointBusinessPlans(Joint_Business_Plan__c JointBusinessPlanTemplate, Integer count, Boolean isInsert) {
        List<Joint_Business_Plan__c> result = new List<Joint_Business_Plan__c>();

        if(JointBusinessPlanTemplate == NULL) JointBusinessPlanTemplate = new Joint_Business_Plan__c();

        Id shId;
        if (JointBusinessPlanTemplate.Supplier_Hub__c == NULL) {
            shId = newSupplierHub(null, true).Id;
        } else {
            shId = JointBusinessPlanTemplate.Supplier_Hub__c;
        }

        for (Integer i = 0; i < count; i++) {
            Joint_Business_Plan__c jbp = JointBusinessPlanTemplate.clone(false, true);
            if (JointBusinessPlanTemplate.Supplier_Hub__c == NULL)           jbp.Supplier_Hub__c = shId;
            if (JointBusinessPlanTemplate.Description__c == NULL)            jbp.Description__c = 'Sample value';

            result.add(jbp);
        }

        if (isInsert) insert result;
        return result;
    }

    /***************************************************************************************
    Description: FACTORY FOR Risk__c - Risk Report Record
    ****************************************************************************************/
    public static Risk__c newRisk(Risk__c riskTemplate, Boolean isInsert) {
        return newRisks(riskTemplate, 1, isInsert)[0];
    }

    public static List<Risk__c> newRisks(Risk__c riskTemplate, Integer count, Boolean isInsert) {
        List<Risk__c> result = new List<Risk__c>();

        if(riskTemplate == NULL) riskTemplate = new Risk__c();

        Id shId;
        if (riskTemplate.Supplier__c == NULL) {
            shId = newSupplierHub(null, true).Id;
        } else {
            shId = riskTemplate.Supplier__c;
        }

        for (Integer i = 0; i < count; i++) {
            Risk__c rk = riskTemplate.clone(false, true);
            if (riskTemplate.Supplier__c == NULL)           rk.Supplier__c = shId;

            result.add(rk);
        }

        if (isInsert) insert result;
        return result;
    }

    /***************************************************************************************
    Description: FACTORY FOR Supplier_Project__c - Supplier Project
    ****************************************************************************************/
    public static Supplier_Project__c newSupplierProject(Supplier_Project__c supplierProjectTemplate, Boolean isInsert) {
        return newSupplierProjects(supplierProjectTemplate, 1, isInsert)[0];
    }

    public static List<Supplier_Project__c> newSupplierProjects(Supplier_Project__c supplierProjectTemplate, Integer count, Boolean isInsert) {
        List<Supplier_Project__c> result = new List<Supplier_Project__c>();

        if(supplierProjectTemplate == NULL) supplierProjectTemplate = new Supplier_Project__c();

        Id shId, pcId;
        if (supplierProjectTemplate.Supplier__c == NULL) {
            shId = newSupplierHub(null, true).Id;
        } else {
            shId = supplierProjectTemplate.Supplier__c;
        }
        if (supplierProjectTemplate.Project_Category__c == NULL) {
            pcId = newProjectCategory(null, true).Id;
        } else {
            pcId = supplierProjectTemplate.Project_Category__c;
        }


        for (Integer i = 0; i < count; i++) {
            Supplier_Project__c sp = supplierProjectTemplate.clone(false, true);
            if (supplierProjectTemplate.Supplier__c == NULL)                    sp.Supplier__c = shId;
            if (supplierProjectTemplate.Project_Category__c == NULL)            sp.Project_Category__c = pcId;

            result.add(sp);
        }

        if (isInsert) insert result;
        return result;
    }

    /***************************************************************************************
    Description: FACTORY FOR Project_Category__c - Project Category
    ****************************************************************************************/
    public static Project_Category__c newProjectCategory(Project_Category__c projectCategoryTemplate, Boolean isInsert) {
        return newProjectCategories(projectCategoryTemplate, 1, isInsert)[0];
    }

    public static List<Project_Category__c> newProjectCategories(Project_Category__c projectCategoryTemplate, Integer count, Boolean isInsert) {
        List<Project_Category__c> result = new List<Project_Category__c>();

        if(projectCategoryTemplate == NULL) projectCategoryTemplate = new Project_Category__c();

        for (Integer i = 0; i < count; i++) {
            Project_Category__c pc = projectCategoryTemplate.clone(false, true);
            if (projectCategoryTemplate.Name == NULL)           pc.Name = 'Sample value ' + i;

            result.add(pc);
        }

        if (isInsert) insert result;
        return result;
    }
}