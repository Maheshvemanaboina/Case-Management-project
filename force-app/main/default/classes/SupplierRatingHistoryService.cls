/* *******************************************************************************************************
 * Name               : SupplierRatingHistoryService                                                     *
 * Description        : SRM - Service class used to hold generic methods related to                            *
 *      Supplier_Rating_History__c object                                                                *
 * Created Date       : 28-Jul-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       28-Jul-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
public with sharing class SupplierRatingHistoryService {

    /**
     * @description: create single supplier_rating_history__c record using supplier_rating__c info
     * @param supplierRatings - single Supplier_Rating__c record
     * @param doInsert - if set to true, this method will insert history records
     * @param doSetRatingField  - if set to true, this method will set Rating__c lookup field
     * @return Supplier_Rating_History__c record
     */
    public static Supplier_Rating_History__c createHistoryRecordFromRating(Supplier_Rating__c supplierRating, Boolean doInsert, Boolean doSetRatingField) {
        return createHistoryRecordsFromRatings(new List<Supplier_Rating__c> { supplierRating }, doInsert, doSetRatingField)[0];
    }

    /**
     * @description: create multiple supplier_rating_history__c record using supplier_rating__c infos
     * @param supplierRatings - List of Supplier_Rating__c records
     * @param doInsert - if set to true, this method will insert history records
     * @param doSetRatingField  - if set to true, this method will set Rating__c lookup field
     * @return List of Supplier_Rating_History__c records
     */
    public static List<Supplier_Rating_History__c> createHistoryRecordsFromRatings(List<Supplier_Rating__c> supplierRatings, Boolean doInsert, Boolean doSetRatingField) {
        SYSTEM.debug('INSIDE HISTORY CREATION');
        List<Supplier_Rating_History__c> supplierRatingHistoryList = new List<Supplier_Rating_History__c>();
        String getFeedbackUserId = Label.GetFeedback_User_Id;
        for(Supplier_Rating__c sr : supplierRatings) {
            
                SYSTEM.debug('CREATING INSIDE');
                Supplier_Rating_History__c supplierRatingHistory = new Supplier_Rating_History__c(
                    Value_Element__c = sr.Value_Element__c,
                    Supplier_Hub__c = sr.Supplier_Hub__c,
                    Rating__c = sr.Rating__c,
                    Comment__c = sr.Comment__c,
                    Rated_By__c = sr.LastModifiedById,                    
                    Rated_Date__c = sr.LastModifiedDate,
                    Location__c = sr.Location__c,
                    Business_Group__c= sr.SRM_Business_Group__c,
                    FC_Location__c= sr.FC_Location__c
                );
                if(doSetRatingField) {
                    supplierRatingHistory.Supplier_Rating__c = sr.Id;
                }
            	if(sr.LastModifiedById == getFeedbackUserId){
                        supplierRatingHistory.Rated_By__c = userinfo.getUserId();
                    }
                supplierRatingHistoryList.add(supplierRatingHistory);
                if(doInsert) {
                    insert supplierRatingHistoryList;
                }
            }            
        
SYSTEM.debug('RETURN ING '+ supplierRatingHistoryList);        
        return supplierRatingHistoryList;
    }

}