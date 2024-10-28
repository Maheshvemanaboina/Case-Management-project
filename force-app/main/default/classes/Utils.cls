/* *******************************************************************************************************
 * Name               : Utils                                                                            *
 * Description        : SRM - Utillity class used to hold generic and useful methods                           *
 * Created Date       : 07-Jul-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       07-Jul-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */

public with sharing class Utils {

    /**
     * @description: generic method to get values from list of objects using specified field api name
     * @param objects - list of sobjects
     * @param fieldName - single field api name
     * @return values gathered from the objects fields
     */
    public static Set<String> fetchSet(List<sObject> objects, String fieldName) {
        Set<String> fieldValues = new Set<String>();
        for (sObject obj : objects) {
            String value = String.valueOf(obj.get(fieldName));
            if (String.isNotBlank(value)) {
                fieldValues.add(value);
            }
        }
        return fieldValues;
    }

    public static Map<String, Id> profileName2Id = new Map<String, Id>();

    public static Id getProfileId(String profileName) {

        if(profileName2Id.containsKey(profileName)) {
            return profileName2Id.get(profileName);
        } else {
            for(Profile p : [SELECT Id, Name FROM Profile]) {
                profileName2Id.put(p.Name, p.Id);
            }
            return profileName2Id.get(profileName);
        }

    }

    public static Map<String, String> getPicklistValues(SObjectType sObj, String fieldName) {
        Map<String, String> picklists = new Map<String, String> ();
        if (sObj != null && String.isNotBlank(fieldName)) {
            Map<String, Schema.SObjectField> fields = sObj.getDescribe().fields.getMap();
            List<Schema.PicklistEntry> picklistEntries = fields.get(fieldName).getDescribe().getPickListValues();
            for (Schema.PicklistEntry picklistEntry : picklistEntries) {
                picklists.put(picklistEntry.getValue(), picklistEntry.getLabel());
            }
        }
        return picklists;
    }

    public static Map<String, Id> recordType2Id = new Map<String, Id>();

    public static Id getRecordTypeId(string objectName, string recTypeDevName){

        if(string.isNotBlank(objectName) && string.isNotBlank(recTypeDevName)){
            string key = createKeyForRtMap(objectName,recTypeDevName);
            if(recordType2Id == null || recordType2Id.size() == 0){
                RecordType[]rts = [Select SobjectType, Name, Id, DeveloperName From RecordType];
                for(RecordType r1 : rts){
                    putRecordTypeId(r1.SobjectType, r1.DeveloperName, r1.Id);
                }
            }
            if(recordType2Id.containsKey(key)){
                return recordType2Id.get(key);
            } else {
                return null;
            }
        } else {
            return null;
        }
    }

    public static void putRecordTypeId(string objectName, string recTypeDevName, Id recTypeId){
        if(string.isNotBlank(objectName) && string.isNotBlank(recTypeDevName) && recTypeId != null){
            recordType2Id.put(createKeyForRtMap(objectName, recTypeDevName),recTypeId);
        }
    }

    public static string createKeyForRtMap(string objectName, string recTypeDevName){
        return objectName.toUpperCase() + '.' + recTypeDevName.toUpperCase();
    }
}