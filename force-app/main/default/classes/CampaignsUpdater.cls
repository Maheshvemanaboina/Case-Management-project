/*       
@Name                  CampaignsUpdater
@Author                praneeth.krishna@frieslandcampina.com
@Version               1
@CreatedDate           March 11, 2022
@UsedBy                
@Description           Class to gather some information about all campaigns and update it status.
                       status will be inprogress if today's date < enddate 
					   status will be completed if today's date >= enddate
@Changes
UserId           | Author-Email                         | Date                | Comment
================ |======================================|=====================|=========
*/
global without sharing class CampaignsUpdater implements Database.Batchable<sObject>,schedulable {
    global void execute(SchedulableContext sc) {
        CampaignsUpdater cu = new CampaignsUpdater(); 
        database.executebatch(cu);
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select Id,Name,ParentId,EndDate,Status,OwnerId,Owner.Email,Owner.Name from Campaign'+
                       ' WHERE EndDate != null and Business_Segment__c !=null and StartDate != null';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Campaign> cmpList) {
        List<Campaign> campaingsUpdate = new List<Campaign>();
        List<Campaign> campaingsUpdate2 = new List<Campaign>();
        for(Campaign eachCmp : cmpList){
            if((eachCmp.EndDate.isSameDay(System.today()) || System.today() > eachCmp.EndDate) && (eachCmp.Status != 'Completed' && eachCmp.Status != 'Aborted')){
                eachCmp.Status = 'Completed';
                campaingsUpdate.add(eachCmp);
                /*if(eachCmp.ParentId  != null){
                    if(campaingUpdate.containsKey(eachCmp.ParentId)){
                         campaingUpdate.remove(eachCmp.ParentId);
                    }                   
                }*/
            }
            else if(System.today() < eachCmp.EndDate && (eachCmp.Status != 'In Progress' && eachCmp.Status != 'Completed' && eachCmp.Status != 'Aborted')){
				eachCmp.Status = 'In Progress';
                campaingsUpdate.add(eachCmp);
            } 
            if(System.today() < eachCmp.EndDate && System.today().daysBetween(eachCmp.EndDate) == 30 && (eachCmp.Status != 'Completed' && eachCmp.Status != 'Aborted')){
                system.debug('entered email block ');
                system.debug('eachCmp.owner.email '+eachCmp.owner.email);
                campaingsUpdate2.add(eachCmp);                
            }
        }
        if(campaingsUpdate.size() > 0){
            update campaingsUpdate;   
        }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        if(campaingsUpdate2.size() > 0){
            for(Campaign camp : campaingsUpdate2){
                 Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                 Datetime dT = camp.EndDate;
                 string datetimestr = dT.format('MMM dd, yyyy');  
                 List<String> sendTo = new List<String>();
                 sendTo.add(camp.owner.email);
                 email.setToAddresses(sendTo);
                 email.setSubject('Notification reminder'); 
                 String body='Hi '+camp.owner.Name+',';
                 body += ' <br/><br/>' + 'Please be informed that Campaign ';
                 body += '<a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+camp.id+'">'+camp.Name+'</a>';
                 body +=' is close to end date('+datetimestr+'). Please update the end date if campaign is extended or otherwise system will set the campaign status to Completed. <br/> <br/>Regards,<br/>FCI HelpDesk Team';
                 system.debug('body  '+body);
                 email.setHtmlBody(body);
                 mails.add(email);	                      
            }
        }
        if(mails.size() > 0){
           Messaging.sendEmail(mails); 
        }        
    }   
     
    global void finish(Database.BatchableContext BC) {
      
    }
}