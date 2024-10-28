@isTest
public class SendVisitNotesTest {

    @TestSetup
    static void makeData(){
        TriggerHandler.skipTrigger = true;
        List<Account> accsCustomLocToInsert = new List<Account>();
        Account commercialCust = TestUtility.createAccount('IMCD Holding');
        accsCustomLocToInsert.add(commercialCust);
        insert accsCustomLocToInsert;
        
        List<Account> accsToInsert = new List<Account>();
        Account customerLocItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCust);
        accsToInsert.add(customerLocItaly);
        insert accsToInsert;

        List<Contact> contactsToInsert = new List<Contact>();
        Contact cItaly = TestUtility.createContact(commercialCust, customerLocItaly);
        contactsToInsert.add(cItaly);
        insert contactsToInsert;
       
        
        Visit_report__c visitRec = TestUtility.getVisitReportInstance(commercialCust,customerLocItaly);
        insert visitRec;

        List<Customer_Attendees__c> cAttsToInsert = new List<Customer_Attendees__c>();
        Customer_Attendees__c custAtt1 = TestUtility.getCustomerAttendeesInstance(visitRec.Id, cItaly.Id);
        cAttsToInsert.add(custAtt1);
        
        Customer_Attendees__c custAtt2 = TestUtility.getCustomerAttendeesInstance(visitRec.Id, cItaly.Id);
        cAttsToInsert.add(custAtt2);
        insert cAttsToInsert;

        List<Salesforce_or_Non_Salesforce_User__c> rfcAttsToInsert = new List<Salesforce_or_Non_Salesforce_User__c>();
        Salesforce_or_Non_Salesforce_User__c rfcAtt1 = TestUtility.getSalesforceNonSalesforceUser(visitRec.Id, UserInfo.getUserId());
        rfcAttsToInsert.add(rfcAtt1);
        
        Salesforce_or_Non_Salesforce_User__c rfcAtt2 = TestUtility.getSalesforceNonSalesforceUser(visitRec.Id, UserInfo.getUserId());
        rfcAttsToInsert.add(rfcAtt2);
        insert rfcAttsToInsert;
        
         TriggerHandler.skipTrigger = false;
    }

    @isTest
    static void checkRFCAttendees(){
        System.debug('check RFC');
        Visit_report__c visitRec = [SELECT Id,Send_Visit_Notes__c,Visit_Date__c,Name,Customer_Needs__c ,Customer_Name__c,Customer_Name__r.Name,Purpose_of_the_Visit__c,Agenda_Discussed__c,Brief_Conclusion__c,CreatedById 
        FROM Visit_Report__c LIMIT 1];
        visitRec.Send_Visit_Notes__c = 'RFC Attendees;';
        Test.startTest();
        update visitRec;
        Integer invocations = Limits.getEmailInvocations();
        
        Map<String,EmailTemplate> empMap = VisitReportUtility.getAllEmailTemplate();
        
        VisitReportUtility.getVisitEmailTemplateMap();  
        VisitReportUtility.getSingleEmailMessageInstanceforCustomerAttendees(empMap.get('Visit Notes_RFC Attendees'),visitRec,new Customer_Attendees__c(),new map<id,user>{});
        Test.stopTest();
        System.assertEquals(1, invocations);
    }
    
    @isTest
    static void checkCustomerAttendees(){
        System.debug('check customer');
        Visit_report__c visitRec = [SELECT Id,Send_Visit_Notes__c,Visit_Date__c,Name,Customer_Needs__c ,Customer_Name__c,Customer_Name__r.Name,Purpose_of_the_Visit__c,Agenda_Discussed__c,Brief_Conclusion__c,CreatedById 
        FROM Visit_Report__c LIMIT 1];
        visitRec.Send_Visit_Notes__c = 'RFC Attendees;';
        Test.startTest();
        update visitRec;
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(1, invocations);
    }
    
    @isTest
    static void checkCombinedCustAttandRFC(){
        System.debug('check RFC and customer');
        Visit_report__c visitRec = [SELECT Id,Send_Visit_Notes__c,Visit_Date__c,Name,Customer_Needs__c ,Customer_Name__c,Customer_Name__r.Name,Purpose_of_the_Visit__c,Agenda_Discussed__c,Brief_Conclusion__c,CreatedById 
        FROM Visit_Report__c LIMIT 1];
        visitRec.Send_Visit_Notes__c = 'RFC Attendees;';
        update visitRec;
        Test.startTest();
        //Since Customer Attendees picklist value is deactivated
        /*visitRec.Send_Visit_Notes__c = 'RFC Attendees;Customer Attendees;';
        update visitRec;*/
        Integer invocations = Limits.getEmailInvocations();
        test.stopTest();   
        System.assertEquals(0, invocations);
    }
}