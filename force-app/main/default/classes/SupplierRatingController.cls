/* *******************************************************************************************************
 * Name               : SupplierRatingController                                                         *
 * Description        : SRM - Controller class for supplierRatingComponent (LWC component)                     *
 * Created Date       : 21-Jul-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       21-Jul-2020 Initial version                                              *
 *   1.1 -    Mateusz W-K       03-Aug-2020 Added supplier location logic                                *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
public with sharing class SupplierRatingController {

    public static String MSG_TMPL = 'MSG:{0}';

    /**
     * @description: get supplier locations using supplier hub id
     * @param supplierHubId - single id of supplier hub
     * @return - List of Supplier_Location__c records
     */
    @AuraEnabled(Cacheable=true)
    public static List<Supplier_Location__c> getSupplierLocations(Id supplierHubId) {
        return [
                SELECT Id, Location__c, Location__r.Name,FC_Location_With_BG__c,Business_Group__c
                FROM Supplier_Location__c
                WHERE Supplier_Hub__c = :supplierHubId
                AND Location__c <> NULL
            	AND Location__r.Is_Active__c = true
            	AND Is_Active__c = true
                ORDER BY Location__r.Name ASC
        ];
    }

    /**
     * @description: check if current user has edit acces
     * @return - Boolean
     */
    @AuraEnabled(Cacheable=true)
    public static Boolean getHasSupplierRatingReadAccess() {
        return ConstUtils.globalDescribe.get(ConstUtils.OBJ_NAME_SUPPLIER_RATING).getDescribe().isAccessible();
    }

    /**
     * @description: check if current user has edit acces
     * @return - Boolean
     */
    @AuraEnabled(Cacheable=true)
    public static Boolean getHasSupplierRatingEditAccess() {
        return ConstUtils.globalDescribe.get(ConstUtils.OBJ_NAME_ACCOUNT).getDescribe().isUpdateable();
    }

    /**
     * @param supplierHubId - single supplier hub indetifier
     * @return List of Supplier_Rating__c - records related to supplier hub or mocks created using custom metadata setting
     */
    @AuraEnabled(Cacheable=true)
    public static List<Supplier_Rating__c> getSupplierRatings(Id supplierHubId, Id FClocationId, string selectedBusinesGroup) {
        system.debug('########## '+ selectedBusinesGroup);
        Supplier_Location__c selectedFCLocation= getLocationRecord(FClocationId);
        Supplier_Hub__c supplierHub = getSupplierHub(supplierHubId);
        if(String.isNotBlank(supplierHub.Segment__c)) {
            return prepareSupplierRatingData(supplierHub, selectedFCLocation.Location__c, selectedFCLocation.FC_Location_With_BG__c);
        } else {
            return new List<Supplier_Rating__c>();
        }
    }

    /**
     * @param supplierHubId - id of supplier hub to which will be supplier ratings connected
     * @param supplierRatings - Ratings record (can be already records from DB modified or new records to create)
     * @return List of Supplier_Rating__c after changes
     */
    @AuraEnabled
    public static List<Supplier_Rating__c> saveSupplierRatings(Id supplierHubId, Id FClocationId, List<Supplier_Rating__c> supplierRatings, List<Task> ratingTasks) {
        Supplier_Location__c selectedFCLocation= getLocationRecord(FClocationId);
        List<Supplier_Rating__c> supplierRatingUpdateList = new List<Supplier_Rating__c>();
        for(Supplier_Rating__c sr : supplierRatings) {
            if(String.isNotBlank(sr.Rating__c) && sr.Rating__c != '0') {
                if(sr.Rating__c == '1' || sr.Rating__c == '2') {
                    sr.Bypass_Task_Creation__c = true;
                }
            }
            String errorString = '';
            system.debug('sr.Comment__c ' + sr.Comment__c);
             system.debug('sr.Not_Applicable__c ' + sr.Not_Applicable__c);
            if(sr.Comment__c == NULL & sr.Not_Applicable__c){
                errorString = 'Comment is required for Not Applicable records' ;                
            }
            
            system.debug('errorstring '+ errorString);
            if(errorString != ''){
                throw new AuraHandledException(errorString);
            }
            supplierRatingUpdateList.add(sr);
        }
        try {
            update supplierRatingUpdateList;
        } catch(Exception e) {
            //add error logging (save record / send email)
            throw new AuraHandledException('Update call error; ERROR: ' + e.getMessage());
        }

        if(!ratingTasks.isEmpty()) {
            try {
                ratingTasks = asssignSupplierRecordType(ratingTasks);
                system.debug('####### '+ ratingTasks);
                insert ratingTasks;
            } catch(Exception e) {
                //add error logging (save record / send email)
                throw new AuraHandledException('Insert call error; ERROR: ' + e.getMessage());
            }
        }

        return prepareSupplierRatingData(getSupplierHub(supplierHubId), selectedFCLocation.Location__c, selectedFCLocation.FC_Location_With_BG__c);
    }

    /**
     * @description: prepare rating data - queried existing records or create mock for the ones that doesn't exist (that are set up in custom metadata setting)
     * @param supplierHub - supplier hub record with segment field queried
     * @return list of supplier ratings related to supplier hub record (or mocks created)
     */
    public static List<Supplier_Rating__c> prepareSupplierRatingData(Supplier_Hub__c supplierHub, Id locationId, string businessGroup) {
        system.debug('BuisnessGoupr '+ supplierHub);
        system.debug('BuisnessGoupr '+ locationId);
        system.debug('BuisnessGoupr '+ businessGroup);
        List<Supplier_Rating__c> supplierRatings = getSupplierRatingData(supplierHub, locationId, businessGroup);
		SYSTEM.debug('supplierRatings '+ supplierRatings);
        if(supplierRatings.isEmpty()) {
            throw new AuraHandledException( String.format(MSG_TMPL, new List<String> { 'Could Not find Rating for specified location and business group.' }));
        }

        return supplierRatings;
    }

    /**
     * @param supplierHubId
     * @return Supplier_Hub__c record
     */
    public static Supplier_Hub__c getSupplierHub(Id supplierHubId) {
        return [
                SELECT Segment__c, Supplier_Rating_Header__c
                FROM Supplier_Hub__c
                WHERE Id = :supplierHubId
        ];
    }

    /**
     * @param supplierHubId - single supplier hub identifier
     * @return List of Supplier_Rating__c - related to supplier hub records
     */
    public static List<Supplier_Rating__c> getSupplierRatingData(Supplier_Hub__c supplierHub, Id locationId, string businessGroup) {
        return [
                SELECT Id, Value_Element_Name__c, Rating__c, Comment__c, Rated_by__c, Rated_by__r.Name, Rated_date__c, LastModifiedBy.Name, LastModifiedDate, Value_Element__r.Min_Stars_Hover_Text__c, Value_Element__r.Max_Stars_Hover_Text__c, Not_Applicable__c
                FROM Supplier_Rating__c
                WHERE Location__c = :locationId
                AND Location_With_BG__c =: businessGroup
                AND (
                        Supplier_Hub__c = :supplierHub.Id
                        OR Supplier_Rating_Header__c = :supplierHub.Supplier_Rating_Header__c
                )
            	AND Rating_Is_Active__c = TRUE
        ];
    }
    
    /**
     * Method assigning the Supplier record type to task.
     */
    public static List<Task> asssignSupplierRecordType(List<Task> taskList){
		Id supplierRrecordTypeId=Schema.SObjectType.Task.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        for(Task obj: taskList){
            obj.recordTypeId = supplierRrecordTypeId;
        }
        return taskList;
    }
    
    
    public static Supplier_Location__c getLocationRecord(Id supplierLocationId) {
        return [
                SELECT Location__c, Location__r.Name,FC_Location_With_BG__c, Business_Group__c
                FROM Supplier_Location__c
                WHERE Id = :supplierLocationId  limit 1
            ];
    }
}