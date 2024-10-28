/*      
    @Name                 LeadSharingUtility
    @Author               Akhil C Kapali 
    @ModifiedBy           Praneeth Krishna
    @Version              1.0
    @CreatedDate          20-10-2020 
    @UsedBy               Tile Trigger HAndler
    @Description          This class contains custom  logic to send emails to community users if content is updated/uploaded
    @Changes			  moved email triggering logicto future method so that cpu time limit exception doesnt occur
    UserId               | Author-Email                           | Date       	| Comment
    =====================|========================================|=============|================
    */
    
    public without sharing class SendNotificationToPortalUsers {
        public static Id emailId;
        
        public static emailTemplate getEmailTemplate(String developerName ){
            system.debug('enters');
            system.debug('developerName'+developerName);
            try{ 
           		return [SELECT Id FROM EmailTemplate WHERE DeveloperName = :developerName]; 
            }catch(exception e){
                system.debug('following'+ e.getMessage());
                return null;
            }
        }
    
        public static void getOrgWideEmailAddress(){
            system.debug('enters11');
            emailId = [select Id,DisplayName,Address from OrgWideEmailAddress where Address = 'noreply-fc@frieslandcampina.com'].ID;   
            system.debug('exits11');
        }
        
    
        public static void sendEmailOnTileCreate(List<Tile__c> newTileList ){
            try{    
                system.debug('sendEmailOnTileCreate');
                Set<Tile__c> tilesToSendEmail = new set<Tile__c>();
                Map<ID,List<String>> communityNames = new Map<ID,List<String>>();
                emailTemplate distNewId = getEmailTemplate('Notification_to_distributor_when_new_content_is_added');
                emailTemplate custNewId = getEmailTemplate('Notification_to_customer_when_new_content_is_added');
                emailTemplate emplNewId = getEmailTemplate('Notification_to_employee_when_new_content_is_added');
                getOrgWideEmailAddress();
                system.debug('enters13');
                for(Tile__c tile : newTileList){
                    
                    if(tile.Article_Name__c != Null){ 
                        tilesToSendEmail.add(tile);              
                        communityNames.put(tile.id,String.valueOf(tile.Community_Name__c).split(';'));
                    }
                }
                system.debug('enters14');
                if(!communityNames.isEmpty() && !tilesToSendEmail.isEmpty()){
                   getTilesAndUserTosendEmail(tilesToSendEmail,communityNames,distNewId.Id,custNewId.Id,emplNewId.Id);
                }
            }catch(exception e){
                system.debug('following error while sending emails on creating new article'+ e.getMessage());
            }
        }
        
        public static void sendEmailOnTileUpdate(List<Tile__c> newTileList, Map<Id,Tile__c> oldTileMap ){
            try{
                system.debug('sendEmailOnTileUpdate');
                getOrgWideEmailAddress();
                Set<Tile__c> tilesToSendEmail = new set<Tile__c>();
                Map<ID,List<String>> communityNames = new Map<ID,List<String>>();
                emailTemplate distUpdatedId = getEmailTemplate('Notification_to_distributor_when_new_content_is_updated');
                emailTemplate custUpdatedId = getEmailTemplate('Notification_to_customer_when_new_content_is_updated');
                emailTemplate emplUpdatedId = getEmailTemplate('Notification_to_employee_when_new_content_is_updated');        
                for(Tile__c til : newTileList){          
                    if(isSendingMailRequired(til, oldTileMap.get(til.Id))){               
                        tilesToSendEmail.add(til);     
                        communityNames.put(til.id,String.valueOf(til.Community_Name__c).split(';'));
                    }
                }       
                if(!communityNames.isEmpty() && !tilesToSendEmail.isEmpty()){
                    getTilesAndUserTosendEmail(tilesToSendEmail,communityNames,distUpdatedId.Id,custUpdatedId.Id,emplUpdatedId.Id);
                }
            }catch(Exception e){
                 system.debug('following error while sending emails on updating new article'+ e.getMessage());
            }             
        }
        
        public static Boolean isSendingMailRequired(Tile__c newTile, Tile__c oldTile){        
            return newTile.File_ContentDocumentId__c != Null &&
                newTile.File_ContentDocumentId__c != oldTile.File_ContentDocumentId__c;
        }
        
        public static List<User> getCommunityUsers(List<String> communityNames){       
            String query = '';
            if((communityNames.contains(Constants.FCI_CUSTOMER_CONNECT) 
                    && communityNames.contains(Constants.FCI_DISTRIBUTOR_CONNECT) 
                    && communityNames.contains(Constants.FC_EMPLOYEE_CONNECT))
                || (communityNames.contains(Constants.FCI_DISTRIBUTOR_CONNECT) 
                    && (communityNames.contains(Constants.FCI_CUSTOMER_CONNECT) 
                    || communityNames.contains(Constants.FC_EMPLOYEE_CONNECT)))
            ){
                query =  'SELECT Id , Name , email ,Contact.email, Contact.Sub_Segment__c, Profile.Name, Profile.UserLicense.Name , Contact.Region__c, Contact.Business_Segment__c, Community_Account_Role__c FROM User WHERE Contact.Id != Null '+ Constants.QUERY_AND +'IsActive = True' + Constants.QUERY_AND +'(Profile.UserLicense.Name= \'Partner Community\' OR Profile.UserLicense.Name= \'Customer Community Plus\' )';
            } else if(communityNames.contains(Constants.FCI_CUSTOMER_CONNECT) 
                || communityNames.contains(Constants.FC_EMPLOYEE_CONNECT)
            ){
                query =  'SELECT Id , Name , email ,Contact.email, Contact.Sub_Segment__c, Profile.Name, Profile.UserLicense.Name ,Contact.Region__c, Contact.Business_Segment__c, Community_Account_Role__c FROM User WHERE Contact.Id != Null '+ Constants.QUERY_AND + 'IsActive = True' + Constants.QUERY_AND + 'Profile.UserLicense.Name= \'Customer Community Plus\' ';
            } else if(communityNames.contains(Constants.FCI_DISTRIBUTOR_CONNECT)){
                query =  'SELECT Id , Name , email , Contact.email, Contact.Sub_Segment__c, Profile.Name, Profile.UserLicense.Name , Contact.Region__c, Contact.Business_Segment__c, Community_Account_Role__c FROM User WHERE Contact.Id != Null' + Constants.QUERY_AND + 'IsActive = True' + Constants.QUERY_AND +'Profile.UserLicense.Name= \'Partner Community\' ';
            }
            
            return String.isBlank(query)? new List<User>() : Database.query(query);      
        }
        
        public static void getTilesAndUserTosendEmail(Set<Tile__c> tilesToSendEmail, Map<ID,List<String>> communityNames,ID distId,ID custId, Id emplId){
            
            Map<Tile__c,List<User>> mapOfTileListDistiUser = new Map<Tile__c,List<User>>();
            Map<Tile__c,List<User>> mapOfTileListCustomerUser = new Map<Tile__c,List<User>>();
            Map<Tile__c,List<User>> mapOfTileListEmployeeUser = new Map<Tile__c,List<User>>();
            
            for(Tile__c eachTile : tilesToSendEmail){
                List<User> users =  getCommunityUsers(communityNames.get(eachTile.Id));
                for(User eachUser : Users){
                    if(isUserBusinessSegmentResUser(eachUser,eachTile)){                                     
                        if(eachUser.Profile.UserLicense.Name == Constants.FCI_DISTRIBUTOR_PROFILE_LICENSE){
                            setmapOfTileListUsers(eachUser,eachTile,mapOfTileListDistiUser);
                        } if(eachUser.Profile.UserLicense.Name == Constants.FCI_CUSTOMER_PROFILE_LICENSE){
                            if(eachUser.Profile.Name == Constants.FCI_CUSTOMER_PROFILE_NAME && communityNames.get(eachTile.Id).contains(Constants.FCI_CUSTOMER_CONNECT)){     
                                setmapOfTileListUsers(eachUser,eachTile,mapOfTileListCustomerUser);
                                
                            }
                            if(eachUser.Profile.Name == Constants.FCI_EMPLOYEE_PROFILE_NAME && communityNames.get(eachTile.Id).contains(Constants.FC_EMPLOYEE_CONNECT)){
                                
                                setmapOfTileListUsers(eachUser,eachTile,mapOfTileListEmployeeUser);
                                
                            }                        
                        }                                                 
                    }
                    if(isUserSubSegmentResUser(eachUser,eachTile)){                    
                        if(eachUser.Profile.UserLicense.Name == Constants.FCI_DISTRIBUTOR_PROFILE_LICENSE){
                            setmapOfTileListUsers(eachUser,eachTile,mapOfTileListDistiUser);
                        } if(eachUser.Profile.UserLicense.Name == Constants.FCI_CUSTOMER_PROFILE_LICENSE){
                             if(eachUser.Profile.Name == Constants.FCI_CUSTOMER_PROFILE_NAME && communityNames.get(eachTile.Id).contains(Constants.FCI_CUSTOMER_CONNECT)){
                                setmapOfTileListUsers(eachUser,eachTile,mapOfTileListCustomerUser);
                                 
                            }
                            if(eachUser.Profile.Name == Constants.FCI_EMPLOYEE_PROFILE_NAME && communityNames.get(eachTile.Id).contains(Constants.FC_EMPLOYEE_CONNECT)){
                                setmapOfTileListUsers(eachUser,eachTile,mapOfTileListEmployeeUser);
                       
                            } 
                        }        
                    }           
                }            
            }
            if(!mapOfTileListDistiUser.isEmpty()){
                sendEmailToPortalUsers(mapOfTileListDistiUser,distId);            
            }
            if(!mapOfTileListCustomerUser.isEmpty()){
                sendEmailToPortalUsers(mapOfTileListCustomerUser,custId);            
            }
    
            if(!mapOfTileListEmployeeUser.isEmpty()){
                sendEmailToPortalUsers(mapOfTileListEmployeeUser,emplId);            
            }
            
        }
        
        public static void setmapOfTileListUsers(User eachUser,Tile__c eachTile, Map<Tile__c,List<User>> mapOfTileListUsers){
            
            if(!mapOfTileListUsers.containsKey(eachTile)){
                mapOfTileListUsers.put(eachTile,new List<User> ());
            }
            mapOfTileListUsers.get(eachTile).add(eachUser);
        }
        public static Boolean isUserBusinessSegmentResUser(User eachUser,Tile__c eachTile){        
            return eachUser.Community_Account_Role__c != Null && eachUser.Contact.Region__c != Null && 
                eachTile.Sales_Region__c != Null && eachTile.Business_Segment__c != Null && eachUser.Contact.Business_Segment__c != Null &&
                eachUser.Community_Account_Role__c == Constants.USER_COMMUNITY_ACCOUNT_ROLE_BUSINESS_SEGMENT &&
                compareMultiSelectPicklistValue(eachTile.Business_Segment__c,eachUser.Contact.Business_Segment__c) &&
                eachTile.Sales_Region__c.contains(eachUser.Contact.Region__c) ;
            
        }
        
        public static Boolean isUserSubSegmentResUser(User eachUser,Tile__c eachTile){
            
            return  eachUser.Community_Account_Role__c != Null && eachUser.Community_Account_Role__c == Constants.USER_COMMUNITY_ACCOUNT_ROLE_SUB_SEGMENT &&
                eachUser.Contact.Region__c != Null && eachTile.Sales_Region__c != Null && eachTile.Business_Segment__c != Null && eachUser.Contact.Business_Segment__c != Null &&
                compareMultiSelectPicklistValue(eachTile.Business_Segment__c,eachUser.Contact.Business_Segment__c) &&
                compareMultiSelectPicklistValue(eachTile.Sub_Segment__c,eachUser.Contact.Sub_Segment__c) &&
                eachTile.Sales_Region__c.contains(eachUser.Contact.Region__c) ;
            
        }
        
        public static Boolean compareMultiSelectPicklistValue(String firstMultiselectVal, String secondMultselectVal){ 
            
            Set<String> firstMultiselectValSet = String.isBlank(firstMultiselectVal ) ? new Set<String>() : new Set<String>( firstMultiselectVal.split(';') );
            Set<String> secondMultselectValSet = String.isBlank(secondMultselectVal ) ? new Set<String>() : new Set<String>( secondMultselectVal.split(';') );
            
            return  firstMultiselectValSet.removeAll( secondMultselectValSet );
            
        }
        
        public static void sendEmailToPortalUsers(Map<Tile__c,List<User>> mapOfTileListUser,Id emailTemplate){
            List<ID> contactIds = new List<ID>();
            for(Tile__c eachTile : mapOfTileListUser.keySet()){ 
                 for(Integer i = 0; i<mapOfTileListUser.get(eachTile).size(); i++){   
                            user userRec = mapOfTileListUser.get(eachTile)[i];              
                            if(userRec.Contact.email != Null && !contactIds.contains(userRec.ContactId)) {
                                contactIds.add(userRec.ContactId);
                            }   
                }           
                if(!contactIds.isEmpty() && System.isFuture() == true){ 
                      //sendNotificationOnInsert sendEmail = new sendNotificationOnInsert(eachTile.Id,emailTemplate,contactIds,emailId);
                      //System.enqueueJob(sendEmail);
                      //To resolve the issue "Too many queueable jobs : 2" The above two lines are commented and replaced with the method "senEmail" in the next line
                    sendEmail(eachTile.Id,emailTemplate,contactIds,emailId);
                }else if(!contactIds.isEmpty() && !test.isRunningTest()){
                     sendEmails(eachTile.Id,emailTemplate,contactIds,emailId); 
                }
            }            
        }
        
        @future
        public static void sendEmails(Id tile,Id emailTemplate,List<ID> conID,Id emailId){
             sendEmail(tile, emailTemplate, conID, emailId);
        }
        
        private static void sendEmail(Id tile,Id emailTemplate,List<ID> conID,Id emailId){
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