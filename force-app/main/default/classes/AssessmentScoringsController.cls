/* *******************************************************************************************************
 * Name               : AssessmentScoringsController                                                     *
 * Description        : SRM - Controller class for assessmentScoringsComponent (LWC component)                 *
 * Created Date       : 08-Jul-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       08-Jul-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
public without sharing class AssessmentScoringsController {

    private static final String STATUS_READY = ConstUtils.ASSESSMENT_STATUS_READY;
    private static final List<String> ASSESSMENT_VISIBILITIES;

    static {
        Boolean isExternalUser = String.isNotBlank([SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId);
        ASSESSMENT_VISIBILITIES = isExternalUser ?
                        new List<String> { ConstUtils.ASSESSMENT_VISIBILITY_BOTH, ConstUtils.ASSESSMENT_VISIBILITY_EXTERNAL } :
                        new List<String> { ConstUtils.ASSESSMENT_VISIBILITY_BOTH, ConstUtils.ASSESSMENT_VISIBILITY_INTERNAL, ConstUtils.ASSESSMENT_VISIBILITY_EXTERNAL /* for internal users show external assesments but do not allow to score */ };
        }

    @AuraEnabled(Cacheable=true)
    public static Boolean getIsExternalUser() {
        return String.isNotBlank([SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId);
    }

        /**
         * @author: Mateusz Wolak-Książek
         * @description: retrieve assessment scoring related to supplier account id
         * @param supplierAccountId
         * @return Assessment_Scoring__c list
         */
    @AuraEnabled(Cacheable=true)
    public static Integer getTotalRecordsCount(Id supplierHubId, String descriptionLike) {
        if(String.isNotBlank(supplierHubId)) {
            supplierHubId = getProperRecordId(supplierHubId);
        }
        if(String.isNotBlank(descriptionLike)) {
            descriptionLike = String.format('%{0}%', new List<String>{
                    descriptionLike
            });
            //count how many records are there with searched description
            return [
                    SELECT count()
                    FROM Assessment_Scoring__c
                    WHERE Supplier_Account__c = :supplierHubId
                    AND Assessment__r.Status__c = :ConstUtils.ASSESSMENT_STATUS_READY
                    AND Assessment_Visibility__c IN :ASSESSMENT_VISIBILITIES
                    AND Assessment_Description__c LIKE :descriptionLike
                    WITH SECURITY_ENFORCED
            ];

        }
        return [
            SELECT count()
            FROM Assessment_Scoring__c
            WHERE Supplier_Account__c = :supplierHubId
            AND Assessment_Visibility__c IN :ASSESSMENT_VISIBILITIES
            AND Assessment__r.Status__c = :ConstUtils.ASSESSMENT_STATUS_READY
            WITH SECURITY_ENFORCED
        ];
    }

    /**
     * @author: Mateusz Wolak-Książek
     * @description: retrieve assessment scoring related to supplier account id
     * @param supplierAccountId
     * @return Assessment_Scoring__c list
     */
    @AuraEnabled(Cacheable=true)
    public static List<Assessment_Scoring__c> getAssessmentScorings(Id supplierHubId, String descriptionLike, Integer pageLimit, Integer pageOffset, String orderBy, String orderDirection) {
        if(String.isNotBlank(supplierHubId)) {
            supplierHubId = getProperRecordId(supplierHubId);
        }
        orderBy = String.isNotBlank(orderBy) ? orderBy : 'CreatedDate';
        orderDirection = String.isNotBlank(orderDirection) ? orderDirection : 'DESC';

        String query = 'SELECT Assessment_Type__c, Assessment_Description__c, Effective_Start_Date__c, Effective_End_Date__c, Percentage_Complete__c, Status__c, Assessment_Visibility__c ';
        query += 'FROM Assessment_Scoring__c ';
        query += 'WHERE Supplier_Account__c = :supplierHubId ';
        query += 'AND Assessment__r.Status__c = :STATUS_READY ';
        query += 'AND Assessment_Visibility__c IN :ASSESSMENT_VISIBILITIES ';
        query += '{0} ';
        query += 'WITH SECURITY_ENFORCED ';
        query += 'ORDER BY {1} {2} ';
        query += 'LIMIT :pageLimit ';
        query += 'OFFSET :pageOffset ';

        if(String.isNotBlank(descriptionLike)) {
            descriptionLike = String.format('%{0}%', new List<String>{
                    descriptionLike
            });
            query = String.format(query, new List<String>{
                    'AND Assessment_Description__c LIKE :descriptionLike', orderBy, orderDirection
            });
        } else {
            query = String.format(query, new List<String>{
                    '', orderBy, orderDirection
            });
        }

        return Database.query(query);
    }

    /**
     * @description: if recordId is type of Account, then return Supplier Hub Id insted
     * @return same or modified (if was account id) recordId
     */
    public static Id getProperRecordId(Id recordId) {
        if(Id.valueOf(recordId).getSobjectType() == Schema.Account.SObjectType) {
            recordId = [SELECT Id FROM Supplier_Hub__c WHERE Supplier_Account__c = :recordId].Id;
        }
        return recordId;
    }

}