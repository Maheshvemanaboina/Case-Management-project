/* *******************************************************************************************************
 * Name               : ResetOutdatedRatingsSchedule                                                     *
 * Description        : SRM - Schedule and batch class - resets completed ratings when they are out of date    *
 * Created Date       : 30-Jul-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       30-Jul-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
public with sharing class ResetOutdatedRatingsSchedule implements Schedulable, Database.Batchable<sObject> {

    public void execute(SchedulableContext sc) {
        Database.executebatch(new ResetOutdatedRatingsSchedule());
    }

    public Database.querylocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
                SELECT Supplier_Rating_Header__c
                FROM Supplier_Hub__c
                WHERE Ratings_Out_Of_Date__c = true
                AND Ratings_Not_Completed_Number__c = 0
        ]);
    }


    /**
     * @description:
     * @param BC
     * @param scope
     */
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Supplier_Hub__c> supplierHubList = (List<Supplier_Hub__c>)scope;
        Set<String> supplierRatingHeaderIds = Utils.fetchSet(supplierHubList, 'Supplier_Rating_Header__c');
        List<Supplier_Rating__c> supplierRatingUpdateList = new List<Supplier_Rating__c>();

        for(Supplier_Rating_Header__c srh : [
            SELECT Rating_Total__c, Ratings_Completed__c, (SELECT Rating__c, Comment__c FROM Supplier_Ratings__r)
            FROM Supplier_Rating_Header__c
            WHERE Id IN :supplierRatingHeaderIds
        ]) {
            for(Supplier_Rating__c sr : srh.Supplier_Ratings__r) {
                sr.Rating__c = '0';
                sr.Comment__c = '';
                supplierRatingUpdateList.add(sr);
            }
        }

        if(!supplierRatingUpdateList.isEmpty()) {
            update supplierRatingUpdateList;
        }
    }

    public void finish(Database.BatchableContext BC) {}

    public static void scheduleThisClass() {
        String rand = Test.isRunningTest() ? ';' + Math.random() : '';
        System.schedule('ResetOutdatedRatingsSchedule daily' + rand, '0 0 1 * * ? *', new ResetOutdatedRatingsSchedule());
    }


}