/* *******************************************************************************************************
 * Name               : AssessmentControler                                                              *
 * Description        : SRM - Controller for common Assessment methods                                         *
 * Created By         : WAEG dawidlebieda                                                                *
 * Created Date       : 20/05/2020                                                                       *
 * ----------------------------------------------------------------------------------------------------- *
 * VERSION    AUTHOR                            DATE                                                     *
 *  1.0   -   WAEG dawidlebieda                   20/05/2020          Initial version                    *
 ******************************************************************************************************* */
public with sharing class AssessmentControler {

    @AuraEnabled(Cacheable=true)
    public static List<Question__c> retrieveQuestions(Id key) {
        System.debug('Retrieving questions: ' + key);
        Assessment__c assessment;
        if (key != null) {
            assessment = [SELECT Status__c, Language__c FROM Assessment__c WHERE Id = :key];
        }
        List<Assessment_Question__c> assessmentQuestions = retrieveAssessmentQuestions(key);
        List<String> assessmentQuestionsDetaildQuestions = new List<String>();
        for (Assessment_Question__c assessmentQuestion : assessmentQuestions) {
            assessmentQuestionsDetaildQuestions.add(assessmentQuestion.Detailed_Question__c);
        }
        List<Question__c> questions = [
                SELECT Id, Detailed_Question__c, Language__c, Question_Summary__c, Category__c
                FROM Question__c
                WHERE Language__c = :assessment.Language__c
                AND Detailed_Question__c != :assessmentQuestionsDetaildQuestions
                AND Status__c = 'Ready'
                ORDER BY Question_ExternalId__c
        ];

        return questions;
    }

    @AuraEnabled(Cacheable = true)
    public static List<Question__c> retrieveQuestionsByKey(String key, Id assessment) {
        Assessment__c assessmentRecord;
        if (assessment != null) {
            assessmentRecord = [SELECT Status__c, Language__c FROM Assessment__c WHERE Id = :assessment];
        }
        List<Assessment_Question__c> assessmentQuestions = retrieveAssessmentQuestions(assessment);
        List<String> assessmentQuestionsDetaildQuestions = new List<String>();
        for (Assessment_Question__c assessmentQuestion : assessmentQuestions) {
            assessmentQuestionsDetaildQuestions.add(assessmentQuestion.Detailed_Question__c);
        }
        key = '%' + key + '%';
        list<Question__c> questions = [
                SELECT Detailed_Question__c, Question_Summary__c, Category__c
                FROM Question__c
                WHERE (Category__c LIKE :key OR
                Question_Summary__c LIKE :key OR
                Detailed_Question__c LIKE :key) AND
                Language__c = :assessmentRecord.Language__c AND Detailed_Question__c != :assessmentQuestionsDetaildQuestions
        ];

        if (questions.isEmpty()) {
            throw new AuraHandledException('No Record Found..');
        }
        return questions;
    }

    @AuraEnabled(Cacheable = true)
    public static List<Assessment_Question__c> retrieveAssessmentQuestions(Id key) {
        List<Assessment_Question__c> assessmentQuestions = [
                SELECT Id, Sequence__c, Relative_Weight__c, Detailed_Question__c, Question_Summary__c, Question__c, Category__c, Question__r.Category__c
                FROM Assessment_Question__c
                WHERE Assessment__c = :key
                ORDER BY Sequence__c
        ];
        return assessmentQuestions;
    }

    @AuraEnabled
    public static void deleteAssessmentQuestions(Id assessmentId) {
        List<Assessment_Question__c> assessmentQuestions = [SELECT Id, Sequence__c, Relative_Weight__c FROM Assessment_Question__c WHERE Assessment__c = :assessmentId];
        delete assessmentQuestions;
    }

    @AuraEnabled
    public static void insertAssessmentQuestions(List<Assessment_Question__c> assessmentQuestions, Id assessmentId) {
        deleteAssessmentQuestions(assessmentId);

        for (Assessment_Question__c assessmentQuestion : assessmentQuestions) {
            String sobjectType = assessmentQuestion.Id.getSObjectType().getDescribe().getName();
            if (sobjectType == 'Question__c') {
                assessmentQuestion.Question__c = assessmentQuestion.Id;
            }
            assessmentQuestion.Assessment__c = assessmentId;
            assessmentQuestion.Id = null;
        }
        insert assessmentQuestions;
    }

    @AuraEnabled(cacheable=true)
    public static boolean checkStatus(Id assessmentId) {
        Assessment__c assessment;
        if (assessmentId != null) {
            assessment = [SELECT Status__c FROM Assessment__c WHERE Id = :assessmentId];
        }
        if (assessment.Status__c.equals('Ready')) {
            return true;
        }
        return false;
    }

    @AuraEnabled(cacheable=true)
    public static boolean checkScoringGroupStatus(Id assessmentId) {
        Assessment__c assessment;
        if (assessmentId != null) {
            assessment = [SELECT Assessment_Scoring_Group_Status__c FROM Assessment__c WHERE Id = :assessmentId];
        }
        if (assessment.Assessment_Scoring_Group_Status__c != null && assessment.Assessment_Scoring_Group_Status__c.equals('Submitted')) {
            return true;
        }
        return false;
    }

    @AuraEnabled
    public static Id getAssesmentQuestionId(Id questionId, Id recordId) {
        if (questionId != null) {
            return [SELECT Id From Assessment_Question__c WHERE Question__c = :questionId AND Assessment__c = :recordId LIMIT 1].Id;
        }
        return null;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Assessment_Scoring_Group__c> retrieveAssessmentScoringGroups(Id key) {
        System.debug('retrieveAssessmentScoringGroups APEX');
        Assessment__c assessment;
        if (key != null) {
            assessment = [SELECT Status__c, Language__c FROM Assessment__c WHERE Id = :key];
        }
        List<Assessment_Scoring_Group__c> assessmentScoringGroups = [
                SELECT Id, Supplier_Hub__c, Assessment__c, Supplier_Name__c, Supplier_Segment__c, Supplier_Category__c, Supplier_Country__c
                FROM Assessment_Scoring_Group__c
                WHERE Assessment__c = :key
        ];
        return assessmentScoringGroups;
    }

    @AuraEnabled(Cacheable = true)
    public static List<Supplier_Hub__c> retrieveSuppliersByKeys(String supplier, String segment, String category, String country, Id assessment) {
        Assessment__c assessmentRecord;
        if (assessment != null) {
            assessmentRecord = [SELECT Status__c, Language__c FROM Assessment__c WHERE Id = :assessment];
        }
        List<Assessment_Scoring_Group__c> assessmentScoringGroups = retrieveAssessmentScoringGroups(assessment);
        Set<Id> assessmentGroupMembersIds = new Set<Id>();
        for (Assessment_Scoring_Group__c assessmentScoringGroup : assessmentScoringGroups) {
            assessmentGroupMembersIds.add(assessmentScoringGroup.Supplier_Hub__c);
        }

        supplier = '%' + supplier + '%';
        segment = '%' + segment + '%';
        category = '%' + category + '%';
        country = '%' + country + '%';


        String query = 'SELECT Id, Segment__c, Supplier_Name__c, Category_Name__c, Primary_Country__c, DUNS_Number__c ';
        query += 'FROM Supplier_Hub__c ';
        query += 'WHERE Id != :assessmentGroupMembersIds ';


        if (supplier != '%%') {
            query += 'AND Supplier_Name__c LIKE :supplier ';
        }

        if (segment != '%%') {
            query += 'AND Segment__c LIKE :segment ';
        }

        if (category != '%%') {
            query += 'AND Category_Name__c LIKE :category ';
        }

        if (country != '%%') {
            query += 'AND Primary_Country__c LIKE :country ';
        }
        query += 'LIMIT 20';

        List<Supplier_Hub__c> supplierHubs = Database.query(query);
        return supplierHubs;
    }

    @AuraEnabled
    public static void insertAssessmentScoringGroups(List<Supplier_Hub__c> suppliers, Id assessmentId) {
        List<Assessment_Scoring_Group__c> assessmentScoringGroups = new List<Assessment_Scoring_Group__c>();
        for (Supplier_Hub__c supplier : suppliers) {
            assessmentScoringGroups.add(new Assessment_Scoring_Group__c(Assessment__c = assessmentId, Supplier_Hub__c = supplier.Id));
        }
        insert assessmentScoringGroups;
    }

    @AuraEnabled
    public static Assessment__c cloneAssessment(Id assessmentId) {
        Assessment__c oldAssessment;
        Assessment__c newAssessment;
        try {
            if (assessmentId != null) {
                oldAssessment = [
                        SELECT Id, Assessment_Description__c, Name, Assessment_Scoring_Group_Status__c, Assessment_Type__c,
                                Dimensions__c, Effective_Start_Date__c, Effective_End_Date__c, Language__c, Status__c, Visibility__c,
                                X_Axis_Heading__c, Y_Axis_Heading__c, Z_Axis_Heading__c
                        FROM Assessment__c
                        WHERE Id = :assessmentId
                ];
                newAssessment = oldAssessment.clone(false, true);
                newAssessment.Status__c = ConstUtils.ASSESSMENT_STATUS_INACTIVE;
                newAssessment.Assessment_Description__c = Label.SRM_Cloned + newAssessment.Assessment_Description__c;
                insert newAssessment;

                List<Assessment_Question__c> assessmentQuestions = retrieveAssessmentQuestions(assessmentId);
                List<Assessment_Question__c> newAssessmentQuestions = new List<Assessment_Question__c>();

                for (Assessment_Question__c assessmentQuestion : assessmentQuestions) {
                    Assessment_Question__c asque = assessmentQuestion.clone(false, false);
                    asque.Assessment__c = newAssessment.Id;
                    newAssessmentQuestions.add(asque);
                }
                if (newAssessmentQuestions.size() > 0) {
                    insert newAssessmentQuestions;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(Label.SRM_UnexpectedError + ': ' + e.getMessage());
        }
        return newAssessment;
    }
}