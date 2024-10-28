/**
* @UserStory		:	US 144653 - As an Approver of the SCAF record, I should get a reminder email notification for every 3 days until I approve/reject the SCAF record + Bug - 146790 + Bug- 147575
* @Author   		:   LSD SCAF Expedition 2030 Dev Team
* @Modified Date 	:   06 June 2024
* @Desc 	        :   Optimized the existing Class to send remider emails to approvers after 3 days of submit for approval

* ************************************************************************************/
/*
* Class Name               :  ApprovalReminderScheduleClass
* Description              :  Class to send remider emails to approvers after 3 days of submit for approval
*/
public without sharing class ApprovalReminderScheduleClass {
    /*
	* Method Name               :  scheduleEmail
	* Description               :  Fetching ProcessInstance,Scaf recod,ProcessInstanceWorkItem
	*/   
    public void scheduleEmail(){
        Set<id> processInstanceIds = new Set<id>();
        Set<Id> scafIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        Map<String,SCAFWrapClass> scafWrapMap = new Map<String,SCAFWrapClass>();
        List<ProcessInstance> processInstanceList = [SELECT Id, Status, CreatedDate, CompletedDate, TargetObjectId, 		TargetObject.Type,TargetObject.Name
                                                     FROM ProcessInstance 
                                                     WHERE TargetObject.Type ='SCAF__c' and status='Pending' order by CreatedDate];
        for(ProcessInstance pI : processInstanceList){
            System.debug(LoggingLevel.INFO,'processInstanceList --> '+ pI);
            processInstanceIds.add(pI.Id);
            scafIds.add(pI.TargetObjectId);
            System.debug(LoggingLevel.INFO,'scafIds-->'+scafIds);
        }
        
        Map<id,SCAF__C> scafMap = new Map<Id,SCAF__c>([SELECT id,Name,Account_Name__r.Name,Account_Name__c 
                                                       FROM SCAF__c 
                                                       WHERE Id in:scafIds AND Account_Name__r.Name!=Null AND Account_Name__c!=Null]);
        List<ProcessInstanceWorkitem> processInstanceWorkitemList = new List<ProcessInstanceWorkitem>();
        if(!test.isRunningTest()){
            processInstanceWorkitemList = [SELECT id,ActorId,ElapsedTimeInHours,ProcessInstanceId,ProcessInstance.TargetObjectId 
                                           FROM ProcessInstanceWorkitem
                                           WHERE ElapsedTimeInHours >= 72 and ProcessInstanceId in:processInstanceIds];
        }
        else{
            processInstanceWorkitemList = [SELECT id,ActorId,ElapsedTimeInHours,ProcessInstanceId,ProcessInstance.TargetObjectId 
                                           FROM ProcessInstanceWorkitem 
                                           WHERE ProcessInstanceId in:processInstanceIds];
        }
        getActorFromPIWorkItem(processInstanceWorkitemList,scafWrapMap,scafMap,userIds);
        addActorIdToSendMail(scafWrapMap,userIds);
    }
    /*
	* Method Name               :   getActorFromPIWorkItem
	* Description               :   Get actor is from ProcessInstanceWorkitem
	*/ 
    public static void getActorFromPIWorkItem( List<ProcessInstanceWorkitem> processInstanceWorkitemList, Map<String,SCAFWrapClass> scafWrapMap, Map<id,SCAF__C> scafMap,Set<Id> userIds){
        if(!processInstanceWorkitemList.IsEmpty()){
            for(ProcessInstanceWorkitem pw : processInstanceWorkitemList){
                System.debug(LoggingLevel.INFO,'processInstanceWorkitemList -> '+pw);
                if(!scafWrapMap.containsKey(pw.ActorId)){
                    SCAFWrapClass swc = new SCAFWrapClass();
                    swc.actorId = pw.ActorId;
                    userIds.add(swc.actorId);
                    System.debug(LoggingLevel.INFO,'actorId-->'+ swc.actorId);
                    if (scafMap.containsKey(Pw.ProcessInstance.TargetObjectId)){
                        swc.processInstanceWorkitemMap.put(Pw.ProcessInstance.TargetObjectId,pw);
                    }
                    if(scafMap.containsKey(Pw.ProcessInstance.TargetObjectId)){
                        swc.scafObjs.add(scafMap.get(Pw.ProcessInstance.TargetObjectId));
                    }
                    scafWrapMap.put(swc.actorId,swc);
                }
                else{
                    SCAFWrapClass swcGet = scafWrapMap.get(pw.ActorId);
                    swcGet.scafIds.add(Pw.ProcessInstance.TargetObjectId);
                    if (scafMap.containsKey(Pw.ProcessInstance.TargetObjectId)) {
                        swcGet.processInstanceWorkitemMap.put(Pw.ProcessInstance.TargetObjectId,pw);
                    }
                    
                    if (scafMap.containsKey(Pw.ProcessInstance.TargetObjectId)) {
                        swcGet.scafObjs.add(scafMap.get(Pw.ProcessInstance.TargetObjectId));
                    }
                    scafWrapMap.put(swcGet.actorId,swcGet);
                }
            }
        }
    }
    
    /*
	* Method Name               :   addActorIdToSendMail
	* Description               :   Collecting the approvers 
	*/   
    public static void addActorIdToSendMail(Map<String,SCAFWrapClass> scafWrapMap,Set<Id>userIds){
        if(!scafWrapMap.isEmpty()){ 
            Map<id,User> userMap = new Map<Id,User>([SELECT id,Name,Email FROM User WHERE Email!=null AND Id=:userIds]);
            For(User user:userMap.values()){
                if(scafWrapMap.containsKey(user.Id)){
                    SCAFWrapClass swcEm = scafWrapMap.get(user.Id); 
                    swcEm.emailList.add(userMap.get(user.Id).Email);
                    scafWrapMap.put(swcEm.actorId,swcEm);
                }
            }
            sendEmailToApprover(scafWrapMap);              
        }
    }
    
    /*
	* Method Name               :   sendEmailToApprover
	* Description               :   Sending Remider Email To Approver
	*/  
    public static void sendEmailToApprover( Map<String,SCAFWrapClass> scafWrapMap){
        List<Messaging.SingleEmailMessage> emailMessageArr = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emTemp = [SELECT id,Body, subject, name,HTMLValue 
                                FROM EmailTemplate
                                WHERE developername = 'SCAF_Approval_Reminder_Template' LIMIT 1];
        
        for(SCAFWrapClass SWC : scafWrapMap.values()){
            for(SCAF__C scf : SWC.scafObjs){
                String emBody = emTemp.HtmlValue.Replace('{!SCAF__c.Name}', scf.Name);
                emBody = emBody.Replace('{!Workitem.ID}',SWC.processInstanceWorkitemMap.get(scf.Id).Id);
                String emSubject = '';
                if(scf.Account_Name__c!=null){
                    emBody = emBody.replace('{!SCAF__c.Account_NameId__c}',scf.Account_Name__c);//147575
                    emBody = emBody.replace('{!SCAF__c.Account_Name__c}',scf.Account_Name__r.Name);//147575
                    emSubject = emTemp.Subject.Replace('{!SCAF__c.Account_Name__c}', scf.Account_Name__r.Name);
                }
                if(!SWC.emailList.isEmpty()){
                    Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
                    emailMessage.setSubject(emSubject);
                    emailMessage.setToAddresses(SWC.emailList);
                    System.debug(LoggingLevel.INFO,'SWC.emailList-->'+SWC.emailList);
                    emailMessage.setHtmlBody(emBody);
                    emailMessageArr.add(emailMessage); 
                }
            }
        }
        if(!emailMessageArr.isEmpty()){
            Messaging.sendEmail(emailMessageArr);
        } 
    }
    
    public class SCAFWrapClass{
        public set<Id> scafIds = new Set<Id>();
        public Id actorId;
        public set<SCAF__c> scafObjs = new Set<SCAF__C>();
        public List<String> emailList = new List<String>();
        public Map<Id,ProcessInstanceWorkitem> processInstanceWorkitemMap = new Map<Id,ProcessInstanceWorkitem>();
    }
    
}