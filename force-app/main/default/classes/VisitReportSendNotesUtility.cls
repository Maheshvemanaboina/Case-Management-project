public with sharing class VisitReportSendNotesUtility {
    
    public static void sendEmailToSendNotesUsers(List<Visit_Report__c> visitReportList){
        Map<Id,Visit_Report__c> visitReportMap = new Map<Id,Visit_Report__c>();
        Map<Id,List<String>> visitNotesMap = new Map<Id,List<String>>();
        Map<Id,List<Messaging.SingleEmailMessage>> custAttSingleEmailMap = new Map<Id,List<Messaging.SingleEmailMessage>>();
        Map<Id,List<Messaging.SingleEmailMessage>> rfcAttSingleEmailMap = new Map<Id,List<Messaging.SingleEmailMessage>>();
        List<Messaging.SingleEmailMessage> singleEmailList = new List<Messaging.SingleEmailMessage>();
        for(Visit_Report__c visit : visitReportList){  
            if(isEmailSendingRequired(visit, (Visit_Report__c)trigger.oldMap.get(visit.Id))){
                visitReportMap.put(visit.Id, visit);
                visitNotesMap.put(visit.Id,returnNewAddedValues(visit, (Visit_Report__c)trigger.oldMap.get(visit.Id)));
            }
        }
        Map<Id,Visit_Report__c> visitMap = new Map<Id,Visit_Report__c>([SELECT Id,Visit_Date__c,Name,Customer_Needs__c ,Customer_Name__c,Customer_Name__r.Name,Purpose_of_the_Visit__c,Agenda_Discussed__c,Brief_Conclusion__c,CreatedById
                                                                        FROM Visit_Report__c
                                                                       WHERE Id IN: visitReportMap.keySet()]);
        if(!visitMap.isEmpty()){
            //custAttSingleEmailMap = VisitReportUtility.getCustomerAttendeesSingleEmailList(visitMap);
            rfcAttSingleEmailMap = VisitReportUtility.getRFCAttendeesSingleEmailList(visitMap);
        }
        for(Id visitId : visitNotesMap.keySet()){
            for(String sendNoteVal : visitNotesMap.get(visitId)){
                if(sendNoteVal.equals(Constants.SEND_VISIT_NOTE_CUSTOMER_ATTENDEE_VALUE)){
                    singleEmailList.addAll(custAttSingleEmailMap.get(visitId));
                }
                if(sendNoteVal.equals(Constants.SEND_VISIT_NOTE_RFC_ATTENDEE_VALUE)){
                    singleEmailList.addAll(rfcAttSingleEmailMap.get(visitId));
                }
            }
        }

        if(!singleEmailList.isEmpty()){
            System.debug('singleEmailList size --> '+singleEmailList.size());
            Messaging.sendEmail(singleEmailList);
        }
    }

    private static boolean isEmailSendingRequired(Visit_Report__c newVisit,Visit_Report__c oldVisit){
        if(oldVisit.Send_Visit_Notes__c == null && newVisit.Send_Visit_Notes__c != null && newVisit.Send_Visit_Notes__c.split(';').size() > 0){
            return true;
        }
        else if(newVisit.send_Visit_Notes__c != null && (newVisit.Send_Visit_Notes__c.split(';').size() > oldVisit.Send_Visit_Notes__c.split(';').size())){
            return true;
        }
        return false;
    }

    private static List<String> returnNewAddedValues(Visit_Report__c newVisit,Visit_Report__c oldVisit){
        if(oldVisit.Send_Visit_Notes__c == null && newVisit.Send_Visit_Notes__c.split(';').size() > 0){
            return newVisit.Send_Visit_Notes__c.split(';');
        }
        else if(newVisit.Send_Visit_Notes__c.split(';').size() > oldVisit.Send_Visit_Notes__c.split(';').size()){
            return newVisit.Send_Visit_Notes__c.remove(oldVisit.Send_Visit_Notes__c).split(';');

        }
        return null;
    }


    //TO DO - create dummy contact and use in sertargetObjectId or explicitly use setHTMLBody from template and replace merge fields respectively
}