/* *******************************************************************************************************
 * Name               : RelatedListController                                                            *
 * Description        : SRM - Controller for aura methods                                                      *
 * Created Date       : 07-09-2020                                                                       *
 * Created By         : Szymon Szczepański                                                               *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    sszcz       07-09-2020 Initial version                                                     *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
public without sharing class RelatedListController {

    @AuraEnabled( cacheable=true )
    public static RelatedListWrapper fetchRecords( Id  recordId )  {
        RelatedListWrapper objWrap = new RelatedListWrapper();
        objWrap.recordCount = [SELECT Count() FROM Assessment_Scoring_Group__c WHERE Assessment__c = :recordId];
        objWrap.listRecords = [SELECT Id, Supplier_Name__c, Supplier_Category__c, Supplier_Country__c, Supplier_Segment__c, Scoring_Members_Count__c FROM Assessment_Scoring_Group__c WHERE Assessment__c = :recordId];
        return objWrap;
    }

    public class RelatedListWrapper {
        @AuraEnabled
        public List < SObject > listRecords;
        @AuraEnabled
        public Integer recordCount;
    }
}