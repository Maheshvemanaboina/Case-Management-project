/* *******************************************************************************************************
 * Name               : SupplierRatingHeaderService                                                      *
 * Description        : SRM - Service class for Supplier Rating Header object                                  *
 * Created Date       : 29-Jul-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       29-Jul-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
public without sharing class SupplierRatingHeaderService {

    /**
     * @description: create supplier_rating_header__c on supplier_hub__c insert
     * @param supplierRatingHeadersToInsert  - List of Supplier Rating Header mocks
     */
    public static void createSupplierRatingHeaders(List<Supplier_Rating_Header__c> supplierRatingHeadersToInsert) {
        if(!supplierRatingHeadersToInsert.isEmpty()) {
            List<Supplier_Hub__c> supplierHubsToUpdateList = new List<Supplier_Hub__c>();

            //check if supplier_rating_header__c does not exists already
            Set<String> supplierHubIds = Utils.fetchSet(supplierRatingHeadersToInsert, 'Supplier_Hub__c');
            if(!supplierHubIds.isEmpty()) {
                for(Supplier_Rating_Header__c srh : [SELECT Id, Supplier_Hub__c FROM Supplier_Rating_Header__c WHERE Supplier_Hub__c IN :supplierHubIds]) {
                    for(Integer i = supplierRatingHeadersToInsert.size() - 1; i >= 0; i--) {
                        if(srh.Supplier_Hub__c == supplierRatingHeadersToInsert[i].Supplier_Hub__c) {
                            //if already exists but lookup was nulled, then attach it to supplier hub and remove from list to insert
                            supplierRatingHeadersToInsert.remove(i);
                            supplierHubsToUpdateList.add(new Supplier_Hub__c(Id = srh.Supplier_Hub__c, Supplier_Rating_Header__c = srh.Id));
                        }
                    }
                }

                //insert rating headers for each supplier hub
                if(!supplierRatingHeadersToInsert.isEmpty()) {
                    insert supplierRatingHeadersToInsert;
                }

                for(Supplier_Rating_Header__c srh : supplierRatingHeadersToInsert) {
                    supplierHubsToUpdateList.add(new Supplier_Hub__c(Id = srh.Supplier_Hub__c, Supplier_Rating_Header__c = srh.Id));
                }
                //update supplier rating header field on supplier hub - bypass triggers for this action (no need to run trigger)
                SRM_TriggerHandler.bypass(ConstUtils.TRG_NAME_SUPPLIER_HUB);
                update supplierHubsToUpdateList;
                SRM_TriggerHandler.clearBypass(ConstUtils.TRG_NAME_SUPPLIER_HUB);
            }
        }
    }


    /**
     * @description: decide which method should be fired (when it's batch / schedule / future run it in same context)
     * @param supplierRatingHeaderIds
     */
    public static void recalculateLastRatedDateOnHeader(Set<Id> supplierRatingHeaderIds) {
        if(System.isBatch() || System.isFuture()) {
            recalculateLastRatedDateOnHeaderBase(supplierRatingHeaderIds);
        } else {
            recalculateLastRatedDateOnHeaderFuture(supplierRatingHeaderIds);
        }
    }

    /**
     * @description: recalculate Last_Rated_Date__c field on Supplier Rating Header record (pass here only ids that, where related ratings has changed)
     * @param supplierRatingHeaderIds - Set of Supplier_Rating_Header__c ids
     */
    public static void recalculateLastRatedDateOnHeaderBase(Set<Id> supplierRatingHeaderIds) {
        List<Supplier_Rating_Header__c> supplierRatingHeaderUpdateList = new List<Supplier_Rating_Header__c>();
        //create helper map
        Map<String, Supplier_Rating_Metadata__mdt> segment2SupplierRatingMetadataMap = new Map<String, Supplier_Rating_Metadata__mdt>();
        for(Supplier_Rating_Metadata__mdt srm : [SELECT Number_of_Months_To_Add__c, Segment__c FROM Supplier_Rating_Metadata__mdt WHERE Number_of_Months_To_Add__c != null AND Segment__c != null]) {
            segment2SupplierRatingMetadataMap.put(srm.Segment__c, srm);
        }

        for(Supplier_Rating_Header__c srh : [
                SELECT Rating_Total__c, Ratings_Completed__c, Last_Rated_Date__c,  Supplier_Hub__r.Segment__c, (SELECT Rating__c FROM Supplier_Ratings__r)
                FROM Supplier_Rating_Header__c
                WHERE Id IN :supplierRatingHeaderIds
        ]) {
            //if all ratings have been completed, then save last rated date (even when someone edits it later on, it should save new last rated date)
            if(srh.Rating_Total__c == srh.Ratings_Completed__c && srh.Ratings_Completed__c != 0) {
                Boolean shouldUpdateHeader = true;

                if(!System.isFuture()) {
                    for(Supplier_Rating__c sr : srh.Supplier_Ratings__r) {
                        if(sr.Rating__c == '0') {
                            shouldUpdateHeader = false;
                            break;
                        }
                    }
                }

                if(shouldUpdateHeader && String.isNotBlank(srh.Supplier_Hub__r.Segment__c)) {
                    srh.Last_Rated_Date__c = Datetime.now();
                    Integer numberOfMonthsToAdd = Integer.valueOf(segment2SupplierRatingMetadataMap.get(srh.Supplier_Hub__r.Segment__c).Number_of_Months_To_Add__c);
                    srh.Next_Rating_Date__c = Date.valueOf(srh.Last_Rated_Date__c).addMonths(numberOfMonthsToAdd);
                    supplierRatingHeaderUpdateList.add(srh);
                }
            } else if(srh.Last_Rated_Date__c != null && srh.Rating_Total__c != srh.Ratings_Completed__c) {
                //when last rated date is not null and ratings were reset and someone completes first ratings null the last rated date
                srh.Last_Rated_Date__c = null;
                srh.Next_Rating_Date__c = null;
                supplierRatingHeaderUpdateList.add(srh);
            }
        }

        if(!supplierRatingHeaderUpdateList.isEmpty()) {
            update supplierRatingHeaderUpdateList;
        }
    }

    @future
    public static void recalculateLastRatedDateOnHeaderFuture(Set<Id> supplierRatingHeaderIds) {
        recalculateLastRatedDateOnHeaderBase(supplierRatingHeaderIds);
    }

}