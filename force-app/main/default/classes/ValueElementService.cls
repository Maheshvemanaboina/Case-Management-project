/* *******************************************************************************************************
 * Name               : ValueElementService                                                              *
 * Description        : SRM - Helper class for Value_Element__c object methods                                 *
 * Created Date       : 03-08-2020                                                                       *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       03-08-2020 Initial version                                               *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
public without sharing class ValueElementService {

    public static Map<String, List<Value_Element__c>> getSegmentToValueElementsMap() {
        Map<String, List<Value_Element__c>> segment2ValueElementsMap = new Map<String, List<Value_Element__c>>();

        for(Value_Element__c ve : [SELECT Segment__c FROM Value_Element__c WHERE Is_Active__c = true ORDER BY Segment__c ASC]) {
            if(segment2ValueElementsMap.containsKey(ve.Segment__c)) {
                segment2ValueElementsMap.get(ve.Segment__c).add(ve);
            } else {
                segment2ValueElementsMap.put(ve.Segment__c, new List<Value_Element__c> { ve });
            }
        }

        return segment2ValueElementsMap;
    }

}