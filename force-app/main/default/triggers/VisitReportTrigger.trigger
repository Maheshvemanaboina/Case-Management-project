trigger VisitReportTrigger on Visit_Report__c (after update) {

    VisitReportTriggerHandler visitrig = new VisitReportTriggerHandler();
    visitrig.process();
}