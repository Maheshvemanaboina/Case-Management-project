/*------------------------------------------------------------  
Author:       João Almeida
Company:      Cognizant
Description:  handles CPQ quote trigger actions
Test Class: SendNotificationToPGMTest

History
2023-06-14    João Almeida    Created class
2023-06-15    João Almeida    Refactored code into multiple private methods
2023-06-16    João Almeida    Get PGM emails by opportunity application name
------------------------------------------------------------*/
public class SendNotificationToPGM {

    @InvocableMethod
    Public static void sendNotification(List<Id> quoteLstIds){
        List<Id> QuotelineIdData = new List<Id>();
        Map<String,String> quoteRegionMap = new Map<String,String>();
        Map<String,SBQQ__Quote__c> quoteMap = new Map<String,SBQQ__Quote__c>();
        Map<String,PGMEmailSetting__c> appEmailMap = PGMEmailSetting__c.getAll();
        if(!quoteLstIds.isEmpty()){
            for(SBQQ__Quote__c quotes :[Select Id, name, SBQQ__Type__c, Sales_Region__c, SBQQ__Opportunity2__r.Opportunity_Application__c, SBQQ__SalesRep__r.Name, SBQQ__SalesRep__r.Email, Primary_Business_Segment__c, Commercial_Approval_Comment__c
                From SBQQ__Quote__c Where Id In:quoteLstIds]){
                quoteRegionMap.put(quotes.Id,quotes.Sales_Region__c);
                quoteMap.put(quotes.Id,quotes);
            }
            
            EmailTemplate template = [Select Id, HTMLValue, Body, Name From EmailTemplate Where developername  = 'PGM_Email_Notification_Template' LIMIT 1];

            for(String quoteId :quoteRegionMap.keySet()) {
                SBQQ__Quote__c quoteInfo = quoteMap.get(quoteId);
                List<String> PGMEmails = getPGMEmailSetting(quoteInfo);
                List<String> ccEmaillist = getEmailCCList(quoteId, quoteRegionMap);
                
                // only send email notification if the main email addresses are defined
                if(PGMEmails.size() > 0){
                    
                    String emailBody = buildEmailBody(template, quoteInfo);
                
                    List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setSubject('Commercial Approval notification');
                    
                    mail.setHtmlBody(emailBody);
                    mail.setTemplateID(template.Id);
                    mail.setSaveAsActivity(false);
                    mail.setTargetObjectId(UserInfo.getUserId());
                    mail.setTreatTargetObjectAsRecipient(false);
                    
                    System.debug('sendNotification to emails: ' + String.join(PGMEmails,','));
                    mail.setToAddresses(PGMEmails);
                    if (ccEmaillist.size() > 0) {
                        mail.setCcAddresses(ccEmaillist); 
                    }   
                    allmsg.add(mail);
                    Messaging.sendEmail(allmsg);
                } 
            }
            
        }
    }

    /**
     * method to get PGM email settings based upon the quote application
     *
     * @return  a list of PGM email settings
     **/
    private static List<String> getPGMEmailSetting(SBQQ__Quote__c quoteInfo) {
        List<String> PGMEmails = new List<String>();
        // PGMEmailSetting__c myCS2 = PGMEmailSetting__c.getValues(app);
        List<PGMEmailSetting__c> lstPGMs = [Select id, Name, PGM_1__c, PGM_2__c, PGM_3__c, Application_Name__c  From PGMEmailSetting__c Where Application_Name__c =:quoteInfo.SBQQ__Opportunity2__r.Opportunity_Application__c];
        
        if(!lstPGMs.isEmpty()){
            
            for(PGMEmailSetting__c pgm:lstPGMs ){
                if(pgm.PGM_1__c != null){
                    PGMEmails.add(pgm.PGM_1__c );
                }
                if(pgm.PGM_2__c != null){
                    PGMEmails.add(pgm.PGM_2__c );
                }
                if(pgm.PGM_3__c != null){
                    PGMEmails.add(pgm.PGM_3__c );
                }
            }
        }
        return PGMEmails;
    }

    /**
     * method to get email CC list based upon the quote sales region
     *
     * @param  quoteId  the quote id to send an email about it
     * @param  quoteRegionMap  a map between quote id and quote sales region
     * @return  a list of CC emails related to the quote sales region
     **/
    private static List<String> getEmailCCList(String quoteId, Map<String,String> quoteRegionMap) {
        List<String> ccEmaillist = new List<String>();
        Quote_Region_Email_Setting__c  getEmailForRegion; 
        
        if(quoteRegionMap.containsKey(quoteId)){
            if(quoteRegionMap.get(quoteId) != null)
            {
                getEmailForRegion = Quote_Region_Email_Setting__c.getValues(quoteRegionMap.get(quoteId));
            }   
            if(getEmailForRegion != null){
                if(getEmailForRegion.Email_1__c != null){
                    ccEmaillist.add(getEmailForRegion.Email_1__c);
                }
                if(getEmailForRegion.Email_2__c != null){
                    ccEmaillist.add(getEmailForRegion.Email_2__c);
                }
                if(getEmailForRegion.Email_3__c != null){
                    ccEmaillist.add(getEmailForRegion.Email_3__c);
                }
            }
        }
        return ccEmaillist;
    }

    /**
     * method to build the email body
     *
     * @param  template  the email template
     * @param  quoteInfo  the quote record
     * @return  the HTML table string with all lines
     **/
    private static String buildEmailBody(EmailTemplate template, SBQQ__Quote__c quoteInfo) {
        String emailBody = template.HTMLValue;

        String link = '<a href="' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + quoteInfo?.Id + '" target="_blank">'+quoteInfo?.Name+'</a>';

        emailBody = emailBody.replace('{!SBQQ__Quote__c.Link}', link);

        if(quoteInfo != null && String.isNotBlank(quoteInfo.Name)) {
            emailBody = emailBody.replace('{!SBQQ__QuoteLine__c.SBQQ__Quote__c}',quoteInfo.Name);
        }
        if(quoteInfo != null && String.isNotBlank(quoteInfo.SBQQ__Type__c)) {
            emailBody = emailBody.replace('{!SBQQ__Quote__c.SBQQ__Type__c}',quoteInfo.SBQQ__Type__c);
        }
        if(quoteInfo != null && String.isNotBlank(quoteInfo.SBQQ__Opportunity2__r.Opportunity_Application__c)){
            emailBody = emailBody.replace('{!SBQQ__QuoteLine__c.SBQQ__Quote__r.SBQQ__Opportunity2__r.Opportunity_Application__c}',quoteInfo.SBQQ__Opportunity2__r.Opportunity_Application__c);
        }
        if(quoteInfo != null && String.isNotBlank(quoteInfo.SBQQ__SalesRep__r.Name)){
            emailBody = emailBody.replace('{!SBQQ__QuoteLine__c.SBQQ__Quote__r.SBQQ__SalesRep__r.Name}',quoteInfo.SBQQ__SalesRep__r.Name );
        }
        emailBody =emailBody.replace('QUOTELINE_TABLE',buildQuoteLinesTable(quoteInfo));
        return emailBody;
    }

    /**
     * method to build the quote lines HTML table for the email body
     *
     * @param  quoteInfo  the quote record related to the quote lines
     * @return  the HTML table string with all lines
     **/
    private static String buildQuoteLinesTable(SBQQ__Quote__c quoteInfo) {
        String table='';
        List<SBQQ__QuoteLine__c> quoteLines = [Select Id, Name, SBQQ__Quantity__c, Unit_of_measure__c,
            SBQQ__Quote__r.Contract_Duration__c, Product_Code__c, SBQQ__ListPrice__c, Floor_Price__c, Walkaway_Price__c,
            SBQQ__Group__r.SBQQ__Account__r.Name, SBQQ__Group__r.SBQQ__StartDate__c, SBQQ__Group__r.SBQQ__EndDate__c,
            SBQQ__Product__r.name, SBQQ__Product__r.Product_Segment_4__c, CommercialApproval__c
            From SBQQ__QuoteLine__c
            Where SBQQ__Quote__c =:quoteInfo.Id AND Product_RecordType_DeveloperName__c='BGI_Product_SKU' AND CommercialApproval__c=true];

        //String style='<style>table {    border-collapse: collapse;font-family: arial, helvetica, sans-serif; font-size: x-small;}td, th {    border: 1px solid black;padding:10px;}</style>';
        String style = '<style>table, th, td {padding: 10px; border: 1px solid black; border-collapse: collapse;text-align: center;}</style>';
        table+=style+'<table style="border-color: #000000; border-width: medium; width: 100%; border-style: solid;" cellspacing="0" >'
        +'<tbody><tr><th>Sold-To</th><th border: 1px solid black>Business Segment</th>'
        +'<th border: 1px solid black>Product Name</th><th border: 1px solid black>SAP Product Number</th><th border: 1px solid black>Product Segment 4</th>'
        +'<th border: 1px solid black>Contract Start Date</th><th border: 1px solid black>Contract End Date</th><th border: 1px solid black>FCA Price</th>'
        +'<th border: 1px solid black>Walkaway Price</th><th border: 1px solid black>Floor Price</th><th border: 1px solid black>Volume</th><th border: 1px solid black>UOM</th>'
        +'<th border: 1px solid black>Approval Comment</th></tr>';
        
        for(SBQQ__QuoteLine__c quoteLine : quoteLines){
            String start = quoteLine.SBQQ__Group__r.SBQQ__StartDate__c != null ? quoteLine.SBQQ__Group__r.SBQQ__StartDate__c.format() : '';
            String enddate = quoteLine.SBQQ__Group__r.SBQQ__EndDate__c != null ? quoteLine.SBQQ__Group__r.SBQQ__EndDate__c.format() : '';
            
            // only display the lines that require approval
            if(quoteLine.CommercialApproval__c){
                String approvalComment = String.isNotBlank(quoteInfo.Commercial_Approval_Comment__c) ? quoteInfo.Commercial_Approval_Comment__c : '';
                table+='<tr>'
                +'<td>'+quoteLine.SBQQ__Group__r.SBQQ__Account__r.Name+'</td><td>'+quoteInfo.Primary_Business_Segment__c
                +'</td><td>'+quoteLine.SBQQ__Product__r.name+'</td><td>'+quoteLine.Product_Code__c+'</td><td>'+quoteLine.SBQQ__Product__r.Product_Segment_4__c
                +'</td><td>'+start+'</td><td>'+enddate+'</td><td>'+quoteLine.SBQQ__ListPrice__c+'</td><td>'+quoteLine.Walkaway_Price__c
                +'</td><td>'+quoteLine.Floor_Price__c+'</td><td>'+quoteLine.SBQQ__Quantity__c+'</td><td>'+quoteLine.Unit_of_measure__c+'</td><td>'+approvalComment
                +'</td></tr>';
            }
        }
        
        table+='</tbody></table>';

        return table;
    }
}