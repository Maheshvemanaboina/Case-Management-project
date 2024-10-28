global without sharing class ApprovalReminderScheduler implements Schedulable {

    global void execute(SchedulableContext sc){
        ApprovalReminderScheduleClass Ars = new ApprovalReminderScheduleClass();
        Ars.ScheduleEmail();
        //String cronExp = '0 0 * * * ?';
        //System.schedule('Hourly', cronExp, Ars );
    }
}