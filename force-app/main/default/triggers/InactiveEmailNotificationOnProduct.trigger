trigger InactiveEmailNotificationOnProduct on Product2 (after update) {
 
 List<Messaging.SingleEmailMessage> atm = new List<Messaging.SingleEmailMessage>();  
    Map<id,user> Mapuser = new Map<id, user>([Select id,email from user]);
    List<String> sendTo = new List<String>();
 
  List<OpportunityLineItem> recips = new List<OpportunityLineItem>(
                [SELECT Opportunityid,Product2id,product2.Name,Opportunity.name,Product2.IsActive,
                Opportunity.ownerid,Quantity,UnitPrice,Opportunity.owner.name
                FROM OpportunityLineItem where Product2id in:Trigger.new]);
 
  for(OpportunityLineItem prod : recips){
  
   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
   String Recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+prod.Opportunityid;
    if(prod.Product2.IsActive==false && trigger.oldMap.get(prod.Product2id).IsActive==True){
                User u = Mapuser.get(prod.Opportunity.ownerid);               
                mail.setToAddresses(new List<String>{u.email});
                mail.setUseSignature(false);
                for(OrgWideEmailAddress owa : [select id, Address, DisplayName from OrgWideEmailAddress]) 
  {
   if(owa.DisplayName.contains('noreplyfriesland'))
   { 
    mail.setOrgWideEmailAddressId(owa.id); 
   } 
  }
                mail.setBccSender(false);               
                mail.setSaveAsActivity(false);
                mail.setSubject('Product inactive notification for ' + prod.Opportunity.name);
                String body = 'Dear '+ prod.Opportunity.owner.name+',' +'<br/>'+'<br/>';
                body += 'Please be informed that product ' + prod.product2.Name + ' has been deactivated. Please consider to replace deactivated product in your opportunities:'+'<br/>'+'<br/>';
                body +='Opportunity Name: ' + prod.Opportunity.name +'<br/>'+'<br/>';
                body +='Opportunity Link: ' + '<a href="' + Recordlink+ '">' + Recordlink+ '</a>' +'<br/>'+'<br/>';
                body +='Thanks.';
                mail.setHtmlBody(body);
                atm.add(mail);
            }  
    }
    Messaging.sendEmail(atm);
    }