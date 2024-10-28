global class scheduleInactiveLeadDeletion implements Schedulable {
 global void execute(SchedulableContext ctx) {
        inactiveLeadDeletionBatch IAD = new inactiveLeadDeletionBatch();
        database.executebatch(IAD);
    }
}