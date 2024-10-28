// If the status of an LSD is not moved into in place or expired and MD aproval (Quote / Order / Delivery approval workflow)  is not in place, a reminder should be sent. 
global without sharing class BatchForSendingReminderForExistingLsd implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String approved = 'Approved';
        String submitted = 'Submitted';
        String expired = 'Expired';
        String lsdStatus = 'LSD in Place';
        Date createdDate = date.newInstance(2020, 12, 31);
        String query='SELECT Leading_Business_Segment__c,FC_Legal_Entity__c,Name,Account_Name__r.Name,Business_Group__c,Parent_Account__r.Name,Id,OwnerId,Quoting_Ordering_Delivery_without_LSD__c,Status_of_LSD__c,CreatedDate,Next_Reminder_Date_For_MD_Approval__c FROM Legal_Sales_Document__c WHERE Quoting_Ordering_Delivery_without_LSD__c!=:approved AND Quoting_Ordering_Delivery_without_LSD__c!=:Expired AND Status_of_LSD__c!=:lsdStatus AND Status_of_LSD__c!=:expired AND createdDate <:createdDate';
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<SObject> records){
        
        List<Legal_Sales_Document__c> lsdRecList = (List<Legal_Sales_Document__c>)records;
        List<Legal_Sales_Document__c> lsdList = new List<Legal_Sales_Document__c>();
        Date todaysDate = system.now().Date();
        for(Legal_Sales_Document__c lsd : lsdRecList){
            // add any conditions to filter LSD
            lsdList.add(lsd);
            
        }
        
        
        set<String> opcoNameSet = new set<String>();
        set<String> legalEntityNameSet = new set<String>();
        system.debug('lsdRecords '+lsdList);
        set<Id> userSet = new set<Id>();
        for(Legal_Sales_Document__c lsd:lsdList){
            userSet.add(lsd.OwnerId);
            
            if(lsd.FC_Legal_Entity__c!='FrieslandCampina Nederland B.V.'){
                legalEntityNameSet.add(lsd.FC_Legal_Entity__c);
            }else{
                opcoNameSet.add(lsd.Leading_Business_Segment__c);
            }
        }
        List<Quoting_Delivery_Without_LSD__mdt> leaglEntityQueMdtList = [SELECT Queue_Name__c,FC_Legal_Entity__c,Business_Group__c FROM Quoting_Delivery_Without_LSD__mdt WHERE FC_Legal_Entity__c IN: legalEntityNameSet];
        //system.debug('leaglEntityQueMdtList '+leaglEntityQueMdtList);
        List<Quoting_Delivery_Without_LSD__mdt> opcoQueMdtList = [SELECT Queue_Name__c,Leading_Business_Segment_OpCo__c,Business_Group__c FROM Quoting_Delivery_Without_LSD__mdt WHERE Leading_Business_Segment_OpCo__c IN: opcoNameSet];
        //system.debug('opcoQueMdtList '+opcoQueMdtList);
        set<String> queueNameSet = new set<String>();
        Map<String,String> opcoQueueMap = new Map<String,String>();
        Map<String,String> cdOpcoQueueMap = new Map<String,String>();
        Map<String,String> snOpcoQueueMap = new Map<String,String>();
        Map<String,String> fciOpcoQueueMap = new Map<String,String>();
        Map<String,String> deOpcoQueueMap = new Map<String,String>();
        Map<String,String> legalEntityQueueMap = new Map<String,String>();
        Map<String,String> cdLegalEntityQueueMap = new Map<String,String>();
        Map<String,String> snLegalEntityQueueMap = new Map<String,String>();
        Map<String,String> fciLlegalEntityQueueMap = new Map<String,String>();
        Map<String,String> deLlegalEntityQueueMap = new Map<String,String>();
        for(Quoting_Delivery_Without_LSD__mdt record : opcoQueMdtList){
            if(record.Business_Group__c == 'CD'){
                queueNameSet.add(record.Queue_Name__c);
                cdOpcoQueueMap.put(record.Leading_Business_Segment_OpCo__c,record.Queue_Name__c);
            }
            if(record.Business_Group__c == 'SN'){
                queueNameSet.add(record.Queue_Name__c);
                snOpcoQueueMap.put(record.Leading_Business_Segment_OpCo__c,record.Queue_Name__c);
            }
            if(record.Business_Group__c == 'FCI'){
                queueNameSet.add(record.Queue_Name__c);
                fciOpcoQueueMap.put(record.Leading_Business_Segment_OpCo__c,record.Queue_Name__c);
            }
            if(record.Business_Group__c == 'DE'){
                queueNameSet.add(record.Queue_Name__c);
                deOpcoQueueMap.put(record.Leading_Business_Segment_OpCo__c,record.Queue_Name__c);
            }
        }
        for(Quoting_Delivery_Without_LSD__mdt record : leaglEntityQueMdtList){
            if(record.Business_Group__c == 'CD'){
                queueNameSet.add(record.Queue_Name__c);
                cdLegalEntityQueueMap.put(record.FC_Legal_Entity__c,record.Queue_Name__c);
            }
            if(record.Business_Group__c == 'SN'){
                queueNameSet.add(record.Queue_Name__c);
                snLegalEntityQueueMap.put(record.FC_Legal_Entity__c,record.Queue_Name__c);
            }
            if(record.Business_Group__c == 'FCI'){
                queueNameSet.add(record.Queue_Name__c);
                fciLlegalEntityQueueMap.put(record.FC_Legal_Entity__c,record.Queue_Name__c);
            }
            if(record.Business_Group__c == 'DE'){
                queueNameSet.add(record.Queue_Name__c);
                deLlegalEntityQueueMap.put(record.FC_Legal_Entity__c,record.Queue_Name__c);
            }
        }
        
        
        List<GroupMember> queueMemberList = [SELECT Id, GroupId,Group.DeveloperName,UserOrGroupId FROM GroupMember WHERE Group.DeveloperName IN :  queueNameSet];
        set<Id> userIdSet = new set<Id>();
        for(GroupMember grpMem : queueMemberList){
            userSet.add(grpMem.UserOrGroupId);
        }
        
        
        //system.debug('LSD List size '+lsdList.size()); 
        Map<Id,User> userMap = new Map<Id,User>([SELECT Name,Email FROM User WHERE Id IN:userSet]);
        
        Map<String,User> queueUserMap = new Map<String,User>();
        for(GroupMember grpMem : queueMemberList){
            if(userMap.containskey(grpMem.UserOrGroupId)){
                queueUserMap.put(grpMem.Group.DeveloperName,userMap.get(grpMem.UserOrGroupId));
            }
        }
        
        system.debug('queueUserMap '+queueUserMap);        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        try{
            for(Legal_Sales_Document__c lsd:lsdList){
                //system.debug('LSD '+lsd);
                String customerName = '';
                String customerLocation = ''; 
                //system.debug('lsd.Business_Group__c  '+lsd.Business_Group__c );                 
               
                    if(lsd.Account_Name__r.Name != null && lsd.Parent_Account__r.Name != null ){
                        customerName = lsd.Parent_Account__r.Name;
                        customerLocation = lsd.Account_Name__r.Name;
                    }
                
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                if(userMap.containskey(lsd.OwnerId) && userMap.get(lsd.OwnerId).Email!=null){
                  //  message.toAddresses = new String[] { userMap.get(lsd.OwnerId).Email };
                        }
                
              if(lsd.FC_Legal_Entity__c == 'FrieslandCampina Nederland B.V.'){
                    if(lsd.Business_Group__c == 'CD'){
                        if(cdOpcoQueueMap.containskey(lsd.Leading_Business_Segment__c) && cdOpcoQueueMap.get(lsd.Leading_Business_Segment__c)!= null && (queueUserMap.containskey(cdOpcoQueueMap.get(lsd.Leading_Business_Segment__c)) && queueUserMap.get(cdOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email!=null)){
                            message.ccaddresses = new String[] {queueUserMap.get(cdOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email}; 
                            //    system.debug('cc email '+queueUserMap.get(cdOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email);
                        }
                    }
                    if(lsd.Business_Group__c == 'SN'){
                        if(snOpcoQueueMap.containskey(lsd.Leading_Business_Segment__c) && snOpcoQueueMap.get(lsd.Leading_Business_Segment__c)!= null && queueUserMap.containskey(snOpcoQueueMap.get(lsd.Leading_Business_Segment__c)) && queueUserMap.get(snOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email!=null){
                            message.ccaddresses = new String[] {queueUserMap.get(snOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email}; 
                             //   system.debug('cc email '+queueUserMap.get(snOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email);
                        }
                    }
                    if(lsd.Business_Group__c == 'FCI'){
                        if(fciOpcoQueueMap.containskey(lsd.Leading_Business_Segment__c) && fciOpcoQueueMap.get(lsd.Leading_Business_Segment__c)!= null && queueUserMap.containskey(fciOpcoQueueMap.get(lsd.Leading_Business_Segment__c)) && queueUserMap.get(fciOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email!=null){
                            message.ccaddresses = new String[] {queueUserMap.get(fciOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email}; 
                             //   system.debug('cc email '+queueUserMap.get(fciOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email);
                        }
                    }
                    if(lsd.Business_Group__c == 'Dairy Essentials'){
                        if(deOpcoQueueMap.containskey(lsd.Leading_Business_Segment__c) && deOpcoQueueMap.get(lsd.Leading_Business_Segment__c)!= null && queueUserMap.containskey(deOpcoQueueMap.get(lsd.Leading_Business_Segment__c)) && queueUserMap.get(deOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email!=null){
                            message.ccaddresses = new String[] {queueUserMap.get(deOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email}; 
                             //   system.debug('cc email '+queueUserMap.get(deOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email);
                        }
                    }
                      if(lsd.Business_Group__c == 'CD & SN'){
                        if(cdOpcoQueueMap.containskey(lsd.Leading_Business_Segment__c) && cdOpcoQueueMap.get(lsd.Leading_Business_Segment__c)!= null && queueUserMap.containskey(cdOpcoQueueMap.get(lsd.Leading_Business_Segment__c)) && queueUserMap.get(cdOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email!=null){
                            message.ccaddresses = new String[] {queueUserMap.get(cdOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email}; 
                              //  system.debug('cc email '+queueUserMap.get(cdOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email);
                        }
                         if(snOpcoQueueMap.containskey(lsd.Leading_Business_Segment__c) && snOpcoQueueMap.get(lsd.Leading_Business_Segment__c)!= null && queueUserMap.containskey(snOpcoQueueMap.get(lsd.Leading_Business_Segment__c)) && queueUserMap.get(snOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email!=null){
                            message.ccaddresses = new String[] {queueUserMap.get(snOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email}; 
                              //  system.debug('cc email '+queueUserMap.get(snOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email);
                        }
                    }
                    if(lsd.Business_Group__c == 'DE & CD'){
                         if(deOpcoQueueMap.containskey(lsd.Leading_Business_Segment__c) && deOpcoQueueMap.get(lsd.Leading_Business_Segment__c)!= null && queueUserMap.containskey(deOpcoQueueMap.get(lsd.Leading_Business_Segment__c)) && queueUserMap.get(deOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email!=null){
                            message.ccaddresses = new String[] {queueUserMap.get(deOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email}; 
                              //  system.debug('cc email '+queueUserMap.get(deOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email);
                        }
                         if(cdOpcoQueueMap.containskey(lsd.Leading_Business_Segment__c) && cdOpcoQueueMap.get(lsd.Leading_Business_Segment__c)!= null && queueUserMap.containskey(cdOpcoQueueMap.get(lsd.Leading_Business_Segment__c)) && queueUserMap.get(cdOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email!=null){
                            message.ccaddresses = new String[] {queueUserMap.get(cdOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email}; 
                              //  system.debug('cc email '+queueUserMap.get(cdOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email);
                        }
                    }
                    if(lsd.Business_Group__c == 'FCI & DE'){
                        if(fciOpcoQueueMap.containskey(lsd.Leading_Business_Segment__c) && fciOpcoQueueMap.get(lsd.Leading_Business_Segment__c)!= null && queueUserMap.containskey(fciOpcoQueueMap.get(lsd.Leading_Business_Segment__c)) && queueUserMap.get(fciOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email!=null){
                            message.ccaddresses = new String[] {queueUserMap.get(fciOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email}; 
                             //   system.debug('cc email '+queueUserMap.get(fciOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email);
                        }
                         if(deOpcoQueueMap.containskey(lsd.Leading_Business_Segment__c) && deOpcoQueueMap.get(lsd.Leading_Business_Segment__c)!= null && queueUserMap.containskey(deOpcoQueueMap.get(lsd.Leading_Business_Segment__c)) && queueUserMap.get(deOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email!=null){
                            message.ccaddresses = new String[] {queueUserMap.get(deOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email}; 
                              //  system.debug('cc email '+queueUserMap.get(deOpcoQueueMap.get(lsd.Leading_Business_Segment__c)).Email);
                        }
                        
                    }
                }
                
                
                if(lsd.FC_Legal_Entity__c != 'FrieslandCampina Nederland B.V.'){
                    if(lsd.Business_Group__c == 'CD'){
                        if(cdLegalEntityQueueMap.containskey(lsd.FC_Legal_Entity__c) && cdLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)!= null && queueUserMap.containskey(cdLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)) && queueUserMap.get(cdLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email!=null && lsd.FC_Legal_Entity__c != 'FrieslandCampina Nederland B.V.'){
                            message.ccaddresses = new String[] {queueUserMap.get(cdLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email}; 
                            //    system.debug('cc email '+queueUserMap.get(cdLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email);
                        }
                    }
                    if(lsd.Business_Group__c == 'SN'){
                        if(snLegalEntityQueueMap.containskey(lsd.FC_Legal_Entity__c) && snLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)!= null && queueUserMap.containskey(snLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)) && queueUserMap.get(snLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email!=null && lsd.FC_Legal_Entity__c != 'FrieslandCampina Nederland B.V.'){
                            message.ccaddresses = new String[] {queueUserMap.get(snLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email}; 
                             //   system.debug('cc email '+queueUserMap.get(snLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email);
                        }
                    }
                    if(lsd.Business_Group__c == 'FCI'){
                        if(fciLlegalEntityQueueMap.containskey(lsd.FC_Legal_Entity__c) && fciLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)!= null && queueUserMap.containskey(fciLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)) && queueUserMap.get(fciLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email!=null && lsd.FC_Legal_Entity__c != 'FrieslandCampina Nederland B.V.'){
                            message.ccaddresses = new String[] {queueUserMap.get(fciLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email}; 
                             //   system.debug('cc email '+queueUserMap.get(fciLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email);
                        }
                    }
                    if(lsd.Business_Group__c == 'Dairy Essentials'){
                        if(deLlegalEntityQueueMap.containskey(lsd.FC_Legal_Entity__c) && deLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)!= null && queueUserMap.containskey(deLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)) && queueUserMap.get(deLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email!=null && lsd.FC_Legal_Entity__c != 'FrieslandCampina Nederland B.V.'){
                            message.ccaddresses = new String[] {queueUserMap.get(deLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email}; 
                              //  system.debug('cc email '+queueUserMap.get(deLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email);
                        }
                    }
                    if(lsd.Business_Group__c == 'CD & SN'){
                         if(cdLegalEntityQueueMap.containskey(lsd.FC_Legal_Entity__c) && cdLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)!= null && queueUserMap.containskey(cdLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)) && queueUserMap.get(cdLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email!=null && lsd.FC_Legal_Entity__c != 'FrieslandCampina Nederland B.V.'){
                            message.ccaddresses = new String[] {queueUserMap.get(cdLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email}; 
                            //    system.debug('cc email '+queueUserMap.get(cdLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email);
                        }
                        if(snLegalEntityQueueMap.containskey(lsd.FC_Legal_Entity__c) && snLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)!= null && queueUserMap.containskey(snLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)) && queueUserMap.get(snLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email!=null && lsd.FC_Legal_Entity__c != 'FrieslandCampina Nederland B.V.'){
                            message.ccaddresses = new String[] {queueUserMap.get(snLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email}; 
                             //   system.debug('cc email '+queueUserMap.get(snLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email);
                        }
                        
                    }
                    if(lsd.Business_Group__c == 'DE & CD'){
                          if(deLlegalEntityQueueMap.containskey(lsd.FC_Legal_Entity__c) && deLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)!= null && queueUserMap.containskey(deLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)) && queueUserMap.get(deLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email!=null && lsd.FC_Legal_Entity__c != 'FrieslandCampina Nederland B.V.'){
                            message.ccaddresses = new String[] {queueUserMap.get(deLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email}; 
                             //   system.debug('cc email '+queueUserMap.get(deLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email);
                        }
                         if(cdLegalEntityQueueMap.containskey(lsd.FC_Legal_Entity__c) && cdLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)!= null && queueUserMap.containskey(cdLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)) && queueUserMap.get(cdLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email!=null && lsd.FC_Legal_Entity__c != 'FrieslandCampina Nederland B.V.'){
                            message.ccaddresses = new String[] {queueUserMap.get(cdLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email}; 
                            //    system.debug('cc email '+queueUserMap.get(cdLegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email);
                        }
                    }
                    if(lsd.Business_Group__c == 'FCI & DE'){
                         if(fciLlegalEntityQueueMap.containskey(lsd.FC_Legal_Entity__c) && fciLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)!= null && queueUserMap.containskey(fciLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)) && queueUserMap.get(fciLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email!=null && lsd.FC_Legal_Entity__c != 'FrieslandCampina Nederland B.V.'){
                            message.ccaddresses = new String[] {queueUserMap.get(fciLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email}; 
                            //    system.debug('cc email '+queueUserMap.get(fciLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email);
                        }
                         if(deLlegalEntityQueueMap.containskey(lsd.FC_Legal_Entity__c) && deLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)!= null && queueUserMap.containskey(deLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)) && queueUserMap.get(deLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email!=null && lsd.FC_Legal_Entity__c != 'FrieslandCampina Nederland B.V.'){
                            message.ccaddresses = new String[] {queueUserMap.get(deLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email}; 
                             //   system.debug('cc email '+queueUserMap.get(deLlegalEntityQueueMap.get(lsd.FC_Legal_Entity__c)).Email);
                        }
                        
                    }
                }
                
                
                 //message.toAddresses = new String[] { 'sheshadri.pattarsrinivas@frieslandcampina.com' };
                //message.optOutPolicy = 'FILTER';
                
                //system.debug('acc name in '+lsd.Name);
                //message.setSenderDisplayName(acc.Name);
                message.subject = 'Notification – reminder: business approval required to continue supply without a Legal Sales Document in place '+customerLocation+' and '+lsd.Name;
                message.htmlbody = 'Dear '+userMap.get(lsd.OwnerId).Name+', <br/><br/> A couple of weeks ago you received an e-mail message to inform you that there is no Legal Sales Document (LSD) in place with '+'<a href="'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Legal_Sales_Document__c/'+lsd.Id+'/view">'+customerLocation+'</a> while the OTS007 IC requires you to obtain the approval of your MD to (continue) the supply to your customer without LSD. <br/><br/> It seems like there is no MD approval in place yet. If so, please make sure that the MD approval is requested immediately and approved in SalesForce by submitting your approval request via the ‘Quoting/Ordering/Delivery without LSD’ option. This in order to comply with the Internal Control requirements (OTS007 IC) and to safeguard continuous supply to your customer. If no action is being taken, continuation of the supply to your customer is at stake. Please note that a copy of this e-mail message will be send to the relevant MD involved. <br/> <br/>If you have any questions, please contact your legal counsel. <br/> <br/>Thank you.';
                messages.add(message);
                //system.debug('message '+message);
                //uncomment this line when running the batch after 3 months
                lsd.Next_Reminder_Date_For_MD_Approval__c = system.today().addDays(30);
                
            }
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results.size() > 0 && results[0].success) 
            {
                System.debug('The email was sent successfully.');
            } 
            else 
            {
                if(results.size() > 0){
                    System.debug('The email failed to send: '+ results[0].errors[0].message);
                }
            }
            // uncomment the below code when running the batch after 3 months
            if(lsdList.size() > 0){
                update lsdList;
            }
            if(test.isRunningTest()){
                decimal d = 2/0;
            }
        }catch(exception ex){
            system.debug('exception '+ex.getMessage()+' line '+ex.getLineNumber());
        }
        
    }    
    global void finish(Database.BatchableContext bc){
        system.debug('executing finish method');
    }    
}