public class sendNotificationOnInsert implements Queueable {
    Id tile;
    Id emailTemplate;
    List<ID> conID;
    Id emailId;
    
    public sendNotificationOnInsert(Id tile,Id emailTemplate,List<ID> conID,Id emailId){
    	this.tile = tile;
        this.emailTemplate = emailTemplate;
        this.conID = conID;
        this.emailId = emailId;
    }
    
    public void execute(QueueableContext context) {
         sendEmails(tile,emailTemplate,conID,emailId);   
    }
    
    @future
    public static void sendEmails(Id tile,Id emailTemplate,List<ID> conID,Id emailId){
         List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
         for(integer i=0 ; i<conID.size(); i++){
               Messaging.SingleEmailMessage message =new Messaging.SingleEmailMessage(); 
                    message.setOrgWideEmailAddressId(emailId);
                    message.setReplyTo('noreply-fc@frieslandcampina.com');
        			message.setUseSignature(false);
       				message.setSaveAsActivity(false); 
                    message.setWhatId(tile);
                    message.setTemplateID(emailTemplate); 
                    message.setTargetObjectId(conID[i]);  
                    mails.add(message);    
          }
          
        if(!mails.isEmpty()){
            system.debug('mails.size '+mails.size());
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails,false);
            if (!results[0].isSuccess()) { 
                System.debug( results[0].getErrors()[0].getStatusCode() + ': ' + results[0].getErrors()[0].getMessage());
    		}                                     		         
        }
    }

}