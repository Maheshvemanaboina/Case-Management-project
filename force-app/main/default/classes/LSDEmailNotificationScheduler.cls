global without sharing class LSDEmailNotificationScheduler implements Schedulable {
    
    global void execute(SchedulableContext ctx){
        BatchClassForEmailReminderofLSDOwner b = new BatchClassForEmailReminderofLSDOwner();
        database.executeBatch(b);
    }
}