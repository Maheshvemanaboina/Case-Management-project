public with sharing class VisitReportUtility {

    public static Map<String,EmailTemplate> emailTemplateMap;
	public static Map<Id,User> userMap;
    public VisitReportUtility() {

    }

    public static Map<String,EmailTemplate> getAllEmailTemplate(){
        if(emailTemplateMap == null){
            emailTemplateMap = new Map<String,EmailTemplate>();
            for(EmailTemplate emTemp : [SELECT Id,Name,htmlvalue,body,subject
                                        FROM EmailTemplate WHERE DeveloperName IN ('Visit_Notes_RFC_Attendees', 'Visit_Notes_Customer_Attendees')]){
                emailTemplateMap.put(emTemp.Name, emTemp);
                                            
            }
        }
        return emailTemplateMap;
    }

    public static Map<String,String> getVisitEmailTemplateMap(){
        Map<String,String> visitEmailMap = new Map<String,String>{  Constants.SEND_VISIT_NOTE_CUSTOMER_ATTENDEE_VALUE => 'Visit Notes_Customer Attendees',
                                                                    Constants.SEND_VISIT_NOTE_RFC_ATTENDEE_VALUE => 'Visit Notes_RFC Attendees' };
        return visitEmailMap;
    }

    public static Messaging.SingleEmailMessage getSingleEmailMessageInstanceforCustomerAttendees(EmailTemplate empTemp,Visit_Report__c visitObj,Customer_Attendees__c cAtt,Map<Id,User> userMap){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String emailSub = empTemp.Subject;
        emailSub = emailSub.replace('{!Visit_Report__c.Name}', visitObj.Name);
        emailSub = emailSub.replace('{!Visit_Report__c.Visit_Date__c}', String.valueOf(visitObj.Visit_Date__c));
        mail.setSubject(emailSub); 
        mail.setToAddresses(new List<String>{cAtt.Contact__r.Email});
        String emailBody = empTemp.HtmlValue;
        emailBody = cAtt.Contact__r.Name != NULL ? emailBody.replace('{!Customer_Attendees__c.Contact__c}', cAtt.Contact__r.Name) : emailBody.replace('{!Customer_Attendees__c.Contact__c}', '');
        emailBody = visitObj.Name != NULL ? emailBody.replace('{!Visit_Report__c.Name}', visitObj.Name) : emailBody.replace('{!Visit_Report__c.Name}', '');
        emailBody = visitObj.Visit_Date__c != NULL ? emailBody.replace('{!Visit_Report__c.Visit_Date__c}', String.valueOf(visitObj.Visit_Date__c)) : emailBody.replace('{!Visit_Report__c.Visit_Date__c}', '');
        emailBody = visitObj.Purpose_of_the_Visit__c != NULL ? emailBody.replace('{!Visit_Report__c.Purpose_of_the_Visit__c}', visitObj.Purpose_of_the_Visit__c) : emailBody.replace('{!Visit_Report__c.Purpose_of_the_Visit__c}', '');
        emailBody = visitObj.Agenda_Discussed__c != NULL ? emailBody.replace('{!Visit_Report__c.Agenda_Discussed__c}', visitObj.Agenda_Discussed__c) : emailBody.replace('{!Visit_Report__c.Agenda_Discussed__c}', '');
        emailBody = visitObj.Customer_Needs__c != NULL ? emailBody.replace('{!Visit_Report__c.Customer_Needs__c}', visitObj.Customer_Needs__c) : emailBody.replace('{!Visit_Report__c.Customer_Needs__c}', '');
        emailBody = userMap.containsKey(visitObj.createdById) ? emailBody.replace('{!Visit_Report__c.CreatedBy}', userMap.get(visitObj.createdById).Name) : emailBody.replace('{!Visit_Report__c.CreatedBy}', '');
        mail.setHtmlBody(emailBody);
        mail.setSenderDisplayName('FrieslandCampina Ingredients');
        mail.setSaveAsActivity(false);
        //mail.setOrgWideEmailAddressId(owa.id);
        return mail;
    }

    public static Messaging.SingleEmailMessage getSingleEmailMessageInstanceforRFCAttendees(EmailTemplate empTemp,Visit_Report__c visitObj,Salesforce_or_Non_Salesforce_User__c rfcObj,Map<Id,User> userMap){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> emailList = new List<String>();
        String emailSub = empTemp.Subject;
        emailSub = emailSub.replace('{!Visit_Report__c.Name}', visitObj.Name);
        emailSub = emailSub.replace('{!Visit_Report__c.Visit_Date__c}', String.valueOf(visitObj.Visit_Date__c));
        mail.setSubject(emailSub);
        if(rfcObj.FrieslandCampina_Employee__c != NULL){
            emailList.add(rfcObj.FrieslandCampina_Employee__r.Email);
        }
        if(rfcObj.NC_FrieslandCampina_employee_NC__c != NULL){
            emailList.add(rfcObj.NC_FrieslandCampina_employee_NC__r.Email);
        }
        if(!String.isBlank(rfcObj.RFC_Non_User_Email_Address__c)){
            emailList.add(rfcObj.RFC_Non_User_Email_Address__c);
        }
        mail.setToAddresses(emailList);
        String emailBody = empTemp.HtmlValue;
        emailBody = rfcObj.FrieslandCampina_Employee__r.Name != NULL ? emailBody.replace('{!Salesforce_or_Non_Salesforce_User__c.FrieslandCampina_Employee__c}', rfcObj.FrieslandCampina_Employee__r.Name) : emailBody.replace('{!Salesforce_or_Non_Salesforce_User__c.FrieslandCampina_Employee__c}','');
        emailBody = visitObj.Name != NULL ? emailBody.replace('{!Visit_Report__c.Name}', visitObj.Name) : emailBody.replace('{!Visit_Report__c.Name}','');
        emailBody = visitObj.Customer_Name__r.Name != NULL ? emailBody.replace('{!Visit_Report__c.Customer_Name__c}', visitObj.Customer_Name__r.Name) : emailBody.replace('{!Visit_Report__c.Customer_Name__c}','');
        emailBody = visitObj.Visit_Date__c != NULL ? emailBody.replace('{!Visit_Report__c.Visit_Date__c}', String.valueOf(visitObj.Visit_Date__c)) : emailBody.replace('{!Visit_Report__c.Visit_Date__c}','');
        emailBody = visitObj.Purpose_of_the_Visit__c != NULL ? emailBody.replace('{!Visit_Report__c.Purpose_of_the_Visit__c}', visitObj.Purpose_of_the_Visit__c) : emailBody.replace('{!Visit_Report__c.Purpose_of_the_Visit__c}', '');
        emailBody = visitObj.Agenda_Discussed__c != NULL ? emailBody.replace('{!Visit_Report__c.Agenda_Discussed__c}', visitObj.Agenda_Discussed__c) : emailBody.replace('{!Visit_Report__c.Agenda_Discussed__c}','');
        emailBody = visitObj.Brief_Conclusion__c != NULL ? emailBody.replace('{!Visit_Report__c.Brief_Conclusion__c}', visitObj.Brief_Conclusion__c) : emailBody.replace('{!Visit_Report__c.Brief_Conclusion__c}', '');
        emailBody = userMap.containsKey(visitObj.createdById) ? emailBody.replace('{!Visit_Report__c.CreatedBy}', userMap.get(visitObj.createdById).Name) : emailBody.replace('{!Visit_Report__c.CreatedBy}', '');
        mail.setHtmlBody(emailBody);
        mail.setSenderDisplayName('FrieslandCampina Ingredients');
        mail.setSaveAsActivity(false);
        //mail.setOrgWideEmailAddressId(owa.id);
        return mail;
    }

    public static Map<Id,List<Messaging.SingleEmailMessage>> getCustomerAttendeesSingleEmailList(Map<Id,Visit_Report__c> visitReportMap){
        Map<Id,List<Messaging.SingleEmailMessage>> singleEmailMap = new Map<Id,List<Messaging.SingleEmailMessage>>();
        EmailTemplate emTemp = getAllEmailTemplate().get(getVisitEmailTemplateMap().get(Constants.SEND_VISIT_NOTE_CUSTOMER_ATTENDEE_VALUE));
        for(Customer_Attendees__c cAtt : [SELECT Id,Contact__c,Contact__r.Name,Related_Visit_Report__c,contact__r.Email
                                        FROM Customer_Attendees__c
                                        WHERE Related_Visit_Report__c != NULL
                                        AND Contact__c != NULL
                                        AND Related_Visit_Report__c IN: visitReportMap.keySet()]){
            if(!singleEmailMap.containsKey(cAtt.Related_Visit_Report__c)){
                singleEmailMap.put(cAtt.Related_Visit_Report__c,new List<Messaging.SingleEmailMessage>{getSingleEmailMessageInstanceforCustomerAttendees(emTemp, visitReportMap.get(cAtt.Related_Visit_Report__c), cAtt,getAllUsers())});
                continue;
            }
            List<Messaging.SingleEmailMessage> singEmList = singleEmailMap.get(cAtt.Related_Visit_Report__c);
            singEmList.add(getSingleEmailMessageInstanceforCustomerAttendees(emTemp, visitReportMap.get(cAtt.Related_Visit_Report__c), cAtt,getAllUsers()));
            singleEmailMap.put(cAtt.Related_Visit_Report__c,singEmList);
        }
        if(!singleEmailMap.isEmpty()){
            return singleEmailMap;
        }
        return null;
    }

    public static Map<Id,List<Messaging.SingleEmailMessage>> getRFCAttendeesSingleEmailList(Map<Id,Visit_Report__c> visitReportMap){
        Map<Id,List<Messaging.SingleEmailMessage>> singleEmailMap = new Map<Id,List<Messaging.SingleEmailMessage>>();
        EmailTemplate emTemp = getAllEmailTemplate().get(getVisitEmailTemplateMap().get(Constants.SEND_VISIT_NOTE_RFC_ATTENDEE_VALUE));
        for(Salesforce_or_Non_Salesforce_User__c sUser : [SELECT Id,Related_Visit_Report__c,FrieslandCampina_Employee__c,NC_FrieslandCampina_employee_NC__c,RFC_Non_User_Email_Address__c,FrieslandCampina_Employee__r.Email,NC_FrieslandCampina_employee_NC__r.Email,FrieslandCampina_Employee__r.Name
                                                        FROM Salesforce_or_Non_Salesforce_User__c
                                                        WHERE Related_Visit_Report__c != NULL
                                                        AND Related_Visit_Report__c IN: visitReportMap.keySet()]){

            if(sUser.FrieslandCampina_Employee__c != null || sUser.NC_FrieslandCampina_employee_NC__c != null || !String.isBlank(sUser.RFC_Non_User_Email_Address__c)){
                if(!singleEmailMap.containsKey(sUser.Related_Visit_Report__c)){
                    singleEmailMap.put(sUser.Related_Visit_Report__c,new List<Messaging.SingleEmailMessage>{getSingleEmailMessageInstanceforRFCAttendees(emTemp, visitReportMap.get(sUser.Related_Visit_Report__c), sUser,getAllUsers())});
                    continue;
                }
                List<Messaging.SingleEmailMessage> singEmList = singleEmailMap.get(sUser.Related_Visit_Report__c);
                singEmList.add(getSingleEmailMessageInstanceforRFCAttendees(emTemp, visitReportMap.get(sUser.Related_Visit_Report__c), sUser,getAllUsers()));
                singleEmailMap.put(sUser.Related_Visit_Report__c,singEmList);
            }
            
        }
        if(!singleEmailMap.isEmpty()){
            return singleEmailMap;
        }
        return null;
    }
    
    
    public static Map<Id,User> getAllUsers(){
        if(userMap == null){
            userMap = new Map<Id,User>();
            for(User us : [SELECT Id,email,Name
                           FROM User
                           WHERE email != NULL
                          AND IsActive = true]){
                 userMap.put(us.Id, us);         
            }
        }
        return userMap;
    }

}