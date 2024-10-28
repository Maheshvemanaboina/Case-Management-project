public class scheduledSrmTaskBatch implements Schedulable{
    public void execute(SchedulableContext sc) {
        BatchCreateFollowUpTasks b = new BatchCreateFollowUpTasks(); 
        database.executebatch(b);
    }
}