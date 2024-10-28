/* *******************************************************************************************************
 * Name               : SupplierRatingsDeletionBatch                                                     *
 * Description        : SRM - Batch class - handle supplier_rating__c records deletion                         *
 * Created Date       : 28-Jul-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       28-Jul-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
public without sharing class SupplierRatingsDeletionBatch implements Database.Batchable<sObject> {
    Map<Id, Value_Element__c> valueElementMap;

    public SupplierRatingsDeletionBatch(Map<Id, Value_Element__c> valueElementMap) {
        this.valueElementMap = valueElementMap;
    }

    public Database.querylocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
            [
                SELECT Id
                FROM Supplier_Rating__c
                WHERE Value_Element__c IN :valueElementMap.keySet()
            ]
        );
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        //delete supplier ratings - on after delete trigger, values will be pushed to history record
        delete (List<Supplier_Rating__c>)scope;
    }

    public void finish(Database.BatchableContext BC) {}
}