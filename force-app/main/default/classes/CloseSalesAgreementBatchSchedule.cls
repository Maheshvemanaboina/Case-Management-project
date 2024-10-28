public with sharing class CloseSalesAgreementBatchSchedule implements Schedulable{
    public void execute(SchedulableContext sc) {
        CloseSalesAgreementBatch cs = new CloseSalesAgreementBatch();
        Database.executeBatch(cs);
    }
}