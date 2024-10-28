/* *******************************************************************************************************
 * Name               : AssessmentScoringItemsController                                                 *
 * Description        : SRM - Controller class for assessmentScoringItemsComponent (LWC component)             *
 * Created Date       : 08-Jul-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       08-Jul-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
public without sharing class AssessmentScoringItemsController {

    public static String SCORE_X_USED = 'Score_{0}_Used__c';
    public static String SCORE_CHOICE_X = 'Score_Choice_{0}__c';
    public static final String CATEGORY_RISK_MANAGEMENT = 'Risk Management';

    /**
     * @author: Mateusz Wolak-Książek
     * @description: get assessment scoring items related to assessment scoring record
     * @param assessmentScoringId
     * @return List<AssessmentScoringItemWrapper> - wrapper list for assessment scoring item records
     */
    @AuraEnabled
    public static List<AssessmentScoringItemWrapper> getAssessmentScoringItems(Id assessmentScoringId) {
        List<AssessmentScoringItemWrapper> assessmentScoringItemWrappers = new List<AssessmentScoringItemWrapper>();

        for(Assessment_Scoring_Item__c assessmentScoringItem : [
                SELECT Category__c, Detailed_Question__c, Score__c, Score_1_Used__c, Score_Choice_1__c, Score_2_Used__c, Score_Choice_2__c,
                        Score_3_Used__c, Score_Choice_3__c, Score_4_Used__c, Score_Choice_4__c, Score_5_Used__c, Score_Choice_5__c, User__c, Assessment_Scoring__r.Assessment__c,
                        Assessment_Scoring__r.Assessment__r.Assessment_Type__c, Assessment_Scoring__r.Supplier_Account__c
                FROM Assessment_Scoring_Item__c
                WHERE Assessment_Scoring__c = :assessmentScoringId
                WITH SECURITY_ENFORCED
        ]) {
            if(assessmentScoringItem.Assessment_Scoring__r.Assessment__c != null && assessmentScoringItem.Assessment_Scoring__r.Assessment__r.Assessment_Type__c != null && assessmentScoringItem.Assessment_Scoring__r.Assessment__r.Assessment_Type__c == ConstUtils.ASSESSMENT_TYPE_SURVEY) {
                //if Assessment Type is equal to Survey, display only questions assigned to logged in user
                if(assessmentScoringItem.User__c == UserInfo.getUserId()) {
                    AssessmentScoringItemWrapper assessmentScoringItemWrapper = new AssessmentScoringItemWrapper(assessmentScoringItem);
                    if(!assessmentScoringItemWrapper.answerChoiceMap.isEmpty() && String.isNotBlank(assessmentScoringItemWrapper.detailedQuestion)) {
                        assessmentScoringItemWrappers.add(assessmentScoringItemWrapper);
                    }
                }
            } else {
                AssessmentScoringItemWrapper assessmentScoringItemWrapper = new AssessmentScoringItemWrapper(assessmentScoringItem);
                if(!assessmentScoringItemWrapper.answerChoiceMap.isEmpty() && String.isNotBlank(assessmentScoringItemWrapper.detailedQuestion)) {
                    assessmentScoringItemWrappers.add(assessmentScoringItemWrapper);
                }
            }

        }

        return assessmentScoringItemWrappers;
    }

    /**
     * @description: get current logged in user data info
     * @return LookupSearchResult
     */
    @AuraEnabled
    public static LookupSearchResult getCurrentUserData() {
        String userIcon = 'standard:user';
        User user = [SELECT Name, Email FROM User WHERE Id = :UserInfo.getUserId()];
        return new LookupSearchResult(
                user.Id,
                'User',
                userIcon,
                user.Name,
                user.Email
        );
    }

    /**
     * @author: Mateusz Wolak-Książek
     * @description: save assessment scoring items using passed wrappers info
     * @param assessmentScoringItemWrappers - list of assessment scoring item wrappers
     * @return String - serialized list of saved records or aurahandledexception is thrown
     */
    @AuraEnabled(Cacheable=false)
    public static String saveAssessmentScoringItems(List<AssessmentScoringItemWrapper> assessmentScoringItemWrappers) {
        try {
            List<Assessment_Scoring_Item__c> assessmentScoringItemList = new List<Assessment_Scoring_Item__c>();
            List<Risk__c> riskAssessments = new List<Risk__c>();

            for(AssessmentScoringItemWrapper assessmentScoringItemWrapper : assessmentScoringItemWrappers) {
                assessmentScoringItemList.add(new Assessment_Scoring_Item__c(Id = assessmentScoringItemWrapper.id, Score__c = assessmentScoringItemWrapper.currentAnswerScore));
                if(assessmentScoringItemWrapper.risk != NULL) {
                    riskAssessments.add(assessmentScoringItemWrapper.risk);
                }
            }

            //update assessment scoring items data with new scores
            update assessmentScoringItemList;
            //if tasks related to assessment scoringi items with Category "Risk Management" is not empty, insert this tasks
            if(!riskAssessments.isEmpty()) {
                insert riskAssessments;
            }

            return JSON.serialize(assessmentScoringItemList);
        } catch(Exception e) {
            //add error logging (save record / send email)
            throw new AuraHandledException('ERROR: ' + e.getMessage());
        }
    }

    public class AssessmentScoringItemWrapper {
        @AuraEnabled public String id {get; set;}
        @AuraEnabled public String category {get; set;}
        @AuraEnabled public String detailedQuestion {get; set;}
        @AuraEnabled public String currentAnswer {get; set;}
        @AuraEnabled public String currentAnswerScore {get; set;}
        @AuraEnabled public String previousAnswerScore {get; set;}
        @AuraEnabled public Boolean showWarningIcon {get; set;}
        @AuraEnabled public List<PicklistValueWrapper> answerOptions {get; set;} //get set optionally?
        @AuraEnabled public Map<String, String> answerChoiceMap {get; set;} //get set optionally?
        @AuraEnabled public String supplierHubId {get; set;}
        @AuraEnabled public Risk__c risk {get; set;} //get set optionally?

        public AssessmentScoringItemWrapper(){}

        public AssessmentScoringItemWrapper(Assessment_Scoring_Item__c record) {
            this.Id = record.Id;
            this.category = record.Category__c;
            this.detailedQuestion = record.Detailed_Question__c;
            this.currentAnswerScore = record.Score__c;
            this.showWarningIcon = this.category != null && this.currentAnswerScore != null && this.category.equalsIgnoreCase(CATEGORY_RISK_MANAGEMENT) && Integer.valueOf(this.currentAnswerScore) > 3;
            this.currentAnswer = getCurrentAnswerConfig(record);
            this.previousAnswerScore = this.currentAnswerScore;
            this.answerChoiceMap = getAnswerChoiceMapConfig(record);
            this.answerOptions = getAnswerOptionsConfig(this.answerChoiceMap.keySet());
            this.supplierHubId = record.Assessment_Scoring__r.Supplier_Account__c;
            this.risk = NULL;
        }

        //get dynamically current answer choice from assessment scoring item record
        private String getCurrentAnswerConfig(Assessment_Scoring_Item__c record) {
            if(String.isNotBlank(this.currentAnswerScore) && this.currentAnswerScore != '0') {
                String score_choise_I_api_name = String.format(SCORE_CHOICE_X, new List<String> { this.currentAnswerScore });
                String score_choise_I_value = String.valueOf(record.get(score_choise_I_api_name));
                return this.Id + ';' + score_choise_I_value;
            }
            return '';
        }

        //build dynamically answer choice map based on assessmenct scoring item fields
        private Map<String, String> getAnswerChoiceMapConfig(Assessment_Scoring_Item__c record) {
            //Score_Choice_X__c field value => X (X is current number in a for loop - from 1 to 5)
            Map<String, String> answerChoiceMap = new Map<String, String>();
            for(Integer i = 1; i < 6; i++) { //this is hardcoded since there shouldn't be more fields added - increase this value when new Score fields are added
                String score_I_used_api_name = String.format(SCORE_X_USED, new List<String> { String.valueOf(i) });
                Boolean score_I_used_value = Boolean.valueOf(record.get(score_I_used_api_name));
                //if field is checked then add new value to choice map
                if(score_I_used_value) {
                    String score_choice_I_api_name = String.format(SCORE_CHOICE_X, new List<String> { String.valueOf(i) });
                    String score_choice_I_value = String.valueOf(record.get(score_choice_I_api_name));
                    answerChoiceMap.put(score_choice_I_value, String.valueOf(i));
                }
            }
            return answerChoiceMap;
        }

        //build picklist displayed at each row using keyset from answerChoiceMap
        private List<PicklistValueWrapper> getAnswerOptionsConfig(Set<String> answerChoiceValues) {
            List<PicklistValueWrapper> picklistValueWrappers = new List<PicklistValueWrapper>();
            for(String acv : answerChoiceValues) {
                picklistValueWrappers.add(new PicklistValueWrapper(acv, this.Id));
            }
            return picklistValueWrappers;
        }
    }

    public class PicklistValueWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;

        public PicklistValueWrapper() { }

        public PicklistValueWrapper(String value, String recordId) {
            this.label = value;
            this.value = recordId + ';' + value;
        }
    }
}