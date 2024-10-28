public with sharing class SalesAgreementVolumeUpdateScheduleJob implements Schedulable {
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new SalesAgreementVolumeUpdateBatch(), 25);
    }
}