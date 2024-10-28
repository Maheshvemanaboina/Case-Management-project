/******************************************************************************************     
@NameOfClass  :BatchClassToInActiveUser
@CreatedBy    :Mohammad Rafi + mohammad.rafi@frieslandcampina.com
@CreatedDate :23-06-2021
@Last ModifiedBy:-Praneeth Krishna
@Last ModifiedDate:-05-09-2022
@Description :Using this batch class ,we will retreive all active users, which are not logged
in morethan 60 days and we will deactivate these user. Also we will de-activate the users who are not loggedin at all after 60 days of creation date.
*********************************************************************************************/
global  without sharing class BatchClassToInActiveUser implements Database.Stateful,Database.Batchable<sObject>,Schedulable{
    public static DateTime loginTimeforSFInternalUser = system.now()-60;   
    public String userName ='Test user';
    public static String SRMPlatformPlusUserProfile ='SRM Platform Plus User';
    public static String SRMPlatformStarterUserProfile ='SRM Platform Starter User';
    public static String sfInternlUserProfileStr = System.Label.Internal_User_Profiles; 
    public static String SfInternlUserProfileLabel = sfInternlUserProfileStr.trim();
  	public static List<String> sfInternalUserProfileList = SfInternlUserProfileLabel.split(',');
    public List<Site> listofSite = [SELECT Id,Name,GuestRecordDefaultOwnerId FROM Site limit 50000];
    List<String> errorList = new List<String>();
    
    global void execute(SchedulableContext sc) {
        BatchClassToInActiveUser executeBatchClassToInActiveUser = new BatchClassToInActiveUser(); 
        database.executebatch(executeBatchClassToInActiveUser);    
    }
    

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query;
        if(!Test.isRunningTest()){
            query = 'Select Id,Name,Profile.Name,Reporting_Key_User_Name__c,UserRole.Name,IsActive,Username,Createddate,lastlogindate,Friesland_Campina_Role__c FROM User WHERE (lastLoginDate <= :loginTimeforSFInternalUser and Profile.Name IN:sfInternalUserProfileList and isactive=true) or (lastlogindate=null and createddate<=:loginTimeforSFInternalUser and Profile.Name IN:sfInternalUserProfileList and isactive=true)';
        }else{
            query = 'Select Id,Name,UserRole.Name,Profile.Name,IsActive,Username,Friesland_Campina_Role__c FROM User WHERE isActive=true and Name =:userName';
        }
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext bc, List<User> listOfUser){
        List<User> listOfFinalUser = new  List<User>();
        listOfFinalUser = getUserList(listOfUser,listofSite);
        if(listOfFinalUser.size()>0){
            Database.SaveResult[] dsrs = Database.Update(listOfFinalUser, false); 
            Integer index = 0;
            for(Database.SaveResult dsr : dsrs){
                if(!dsr.isSuccess()){
                    String errMsg = dsr.getErrors()[0].getMessage();
                    errorList.add(listOfFinalUser[index].Id+','+listOfFinalUser[index].Name+','+errMsg);
                }                              
            index ++;
            }
        }	                     
    }  
    
    global void finish(Database.BatchableContext bc){
        if(!errorList.isEmpty()){
        AsyncApexJob a = [SELECT id, ApexClassId,JobItemsProcessed, TotalJobItems,NumberOfErrors, CreatedBy.Email FROM AsyncApexJob WHERE id = :BC.getJobId()];
        String body = 'Batch job to deactivate inactive user has finished. There Were '
            + errorList.size()
            + ' errors. Please find the error list attached to the Case.';
        
        // Creating the CSV file
        String finalstr = 'User Id,Name,Error \n';
        String subject = 'Deactivate Users - Apex Batch Error List';
        String attName = 'Deactivate Users Errors.csv';
        for(String str  : errorList){
            system.debug('before split '+str);
            String[] results = str.split(',');
            system.debug('results '+results);
            string recordString = results[0]+'","'+results[1]+'","'+results[2]+'"\n';
            finalstr = finalstr +recordString;
        }    
        
        // Define the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        
        // Create the email attachment    
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(attName);
        efa.setBody(Blob.valueOf(finalstr));
        
        // Sets the paramaters of the email
        email.setSubject( subject );
        //Created a custom label with the email id to send email to in case of error
        List<String> sendTo = new List<String>();
		sendTo.addAll((Label.Internal_User_Contact_Email).split(','));
		email.setToAddresses(sendTo);
        email.setPlainTextBody( body );
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        
        // Sends the email         
        Messaging.SendEmailResult [] r = 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});  
        }
    }
    
    public static List<User> getUserList(List<User> ExistingListofUser,List<Site> listofSite){
        List<User> returnUserList = new List<User>(); 
        Map<Id,Id> mapOfUserIdVsSiteId = new Map<Id,Id>();
        Map<Id,Id> mapOfReportingUserVsUser= new Map<Id,Id>();
        if(listofSite.size()>0){
            for(Site s :listofSite){
                if(s.GuestRecordDefaultOwnerId !=null){
                    mapOfUserIdVsSiteId.put(s.GuestRecordDefaultOwnerId,s.Id);
                }
            }   
        }
        List<User> listOfAllUser = new List<User>();
        listOfAllUser = [SELECT Id,Reporting_Key_User_Name__c,Reporting_Key_User_Name__r.name FROM User Where Reporting_Key_User_Name__c !=null and Profile.Name IN:sfInternalUserProfileList  limit 50000 ];
        if(listOfAllUser.size()>0){
            for(User uVar:listOfAllUser){
                if(uVar.Reporting_Key_User_Name__c !=null){                  
                    mapOfReportingUserVsUser.put(uVar.Reporting_Key_User_Name__c,uVar.Id);
                }
            }    
        }
        
        for(User u:ExistingListofUser){     
            if(!mapOfReportingUserVsUser.containsKey(u.Id) && 
               !mapOfUserIdVsSiteId.containsKey(u.Id) &&
               !Label.AutoDeactivate_Users.contains(u.Name) &&
              (!(u.Profile.Name == SRMPlatformPlusUserProfile || u.Profile.Name == SRMPlatformStarterUserProfile) 
               || (u.Friesland_Campina_Role__c != 'Procurement' && u.Friesland_Campina_Role__c != 'QA'))){
                u.IsActive = false;
                returnUserList.add(u); 
            }
        } 
        Return returnUserList;
    }
}