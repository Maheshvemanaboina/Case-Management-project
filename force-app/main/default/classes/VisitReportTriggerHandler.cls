public with sharing class VisitReportTriggerHandler extends TriggerHandler {

    public override void processAfterUpdate(){
        VisitReportSendNotesUtility.sendEmailToSendNotesUsers((List<Visit_Report__c>)trigger.new);
    }
}