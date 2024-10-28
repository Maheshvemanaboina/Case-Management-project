public with sharing class ApprovalSLAScheduleJob implements Schedulable {
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new ApprovalSLABatch());
    }
}