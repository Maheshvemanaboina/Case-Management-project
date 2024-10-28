/*       
@Name           - UpdateAccountOwner
@Author         - Rekha | Email - rekha.harshit@frieslandcampina.com
@ModifiedBy     - 
@Version        - 1.0
@CreatedDate    - 10-01-2022
@UsedBy         - AccountTrigger
@Description    - Used to update End customer owner.
@Changes        - No Changes done

User              | Author-Email                        | Date          | Comment
==================|=====================================|===============|=========
Rekha             | rekha.harshit@frieslandcampina.com  | 10-01-2022    | 
*/

public  without sharing class UpdateAccountOwner extends TriggerHandler{
        
    /*@Description: To update End customer's owner from account teams. The Sales manager from the account teams
     * with the same business segment will be the owner of an End customer. If there is no match found then the H5 account owner 
     * will be the owner of the End Customer
    */
    Public static void updateOwner(list<account> accList){       
       
        
        set<id> h5AccountIdSet = new set<id>();
        set<string> businessSegmentSet = new set<string>();  
        //list<AccountTeamMember> atmList = new list<AccountTeamMember>();
        List<Account_Team__c> atmList = new List<Account_Team__c>();
        map<id,account> h5AccountMap = new map<id,account>();
        list<account> accountListToUpdate = new list<account>();
        map<id,account> accountMapToUpdate = new map<id,account>();
        list<DebugLog__c> debugLogsToInsert = new list<DebugLog__c>();
        
        String ATMrole = System.Label.Account_team_member_role; // custom label which holds role sales manager
        String endCustomerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_End_Customer').getRecordTypeId();
                
        for(account each : accList){
            if(each.RecordTypeId.equals(endCustomerRecordTypeId) && each.Distributor_Location__c!=NULL){
                h5AccountIdSet.add(each.Distributor_Location__c);  
                if(each.Business_Segment__c!=NULL)
                businessSegmentSet.add(each.Business_Segment__c);
                
                if(each.id!=NULL)
                    accountListToUpdate.add(each);
            }    
        }
        system.debug('---h5AccountIdSet--'+h5AccountIdSet);
        system.debug('---businessSegmentSet--'+businessSegmentSet);
        
        if(!h5AccountIdSet.isEmpty()){
        	//h5AccountMap = new map<id,account>([SELECT id,ownerId,owner.isactive FROM account WHERE id IN : h5AccountIdSet]); 
            for(account acc : accList){
                if(!h5AccountMap.isEmpty() && h5AccountMap.containskey(acc.Distributor_Location__c) && h5AccountMap.get(acc.Distributor_Location__c)!=NULL){
                	 if(h5AccountMap.get(acc.Distributor_Location__c).owner.isactive)
                     	acc.ownerId = h5AccountMap.get(acc.Distributor_Location__c).ownerId;                     
                }   
            }    
        }
       
       // if(!h5AccountIdSet.isEmpty()){
            
        	if(!h5AccountIdSet.isEmpty() && !businessSegmentSet.isEmpty())
        	atmList = [SELECT id,Source_Account__c,Business_Segment__c,Team_Member__c FROM Account_Team__c WHERE primary__c = true and Team_Role__c=:ATMrole and Source_Account__c IN :h5AccountIdSet and Business_Segment__c IN : businessSegmentSet];
            system.debug('---atmList--'+atmList); 
            for(account acc : accList){
                if(!atmList.isEmpty()){
                    for(Account_Team__c each : atmList){  
                        if(acc.Distributor_Location__c == each.Source_Account__c && acc.Business_Segment__c == each.Business_Segment__c)
                            acc.OwnerId = each.Team_Member__c; 
                    }
                }
                else{
                	
                    if(!h5AccountMap.isEmpty() && h5AccountMap.containskey(acc.Distributor_Location__c) && h5AccountMap.get(acc.Distributor_Location__c)!=NULL){
                        if(h5AccountMap.get(acc.Distributor_Location__c).owner.isactive)
                            acc.ownerId = h5AccountMap.get(acc.Distributor_Location__c).ownerId;
                        else
                            debugLogsToInsert.add(logError('Account','',string.valueof(acc),'Apex Class','UpdateAccountOwner','updateOwner','Error',h5AccountMap.get(acc.Distributor_Location__c).ownerId+'- Inactive user can not be an account owner','INTERNAL ERROR','When End customer account is created',''));        
                    }       
                        
                }
               
            }
            for(account acc : accList){
               /* if(!h5AccountMap.isEmpty() && h5AccountMap.containskey(acc.Distributor_Location__c) && h5AccountMap.get(acc.Distributor_Location__c)!=NULL && h5AccountMap.get(acc.Distributor_Location__c).owner.isactive == false){
                	system.debug('--acc owner null----');
                    debugLogsToInsert.add(logError('Account','',string.valueof(acc),'Apex Class','UpdateAccountOwner','updateOwner','Error',h5AccountMap.get(acc.Distributor_Location__c).ownerId+'- Inactive user can not be an account owner','INTERNAL ERROR','When End customer account is created',''));    
                }*/
                if(acc.id!=NULL)
                    accountListToUpdate.add(acc);
            }   
            
        //}
        system.debug('----accountListToUpdate--'+accountListToUpdate.size());
        if(accountListToUpdate.size()>0){
            accountMapToUpdate.putall(accountListToUpdate);
            //update accountMapToUpdate.values();
            Database.SaveResult[] srList = Database.update(accountMapToUpdate.values(), false);
            Set<Id> updatedAccountIdsSet = new Set<Id>();
            for(Integer i=0;i<srList.size();i++){
                if (srList[i].isSuccess()) {
                    //Collect all the updated accounts when the owner is changed and add to a set
                    updatedAccountIdsSet.add(srList[i].getId());
                }
                else if(!srList[i].isSuccess()){ 
                    for(Database.Error err : srList[i].getErrors()) {
                        DebugLog__c errs = logError('Account','',string.valueof(accountMapToUpdate.values()[i]),'Apex Class','UpdateAccountOwner','updateOwner','Error',err.getStatusCode()+': '+err.getMessage(),'INTERNAL ERROR','When Account Owner is updated','');
                        debugLogsToInsert.add(errs);
                    }
                }
            }
            
            //Recalculate Account, Opportunity and Case Sharing as it deletes the Account Sharing (where sharing reason is manual) when the Account owner is changed
            if(!updatedAccountIdsSet.isEmpty()){
                recalculateAccountSharingOnAccountOwnerUpdate(updatedAccountIdsSet);
            }
        } 
        if(debugLogsToInsert.size()>0)
            insert debugLogsToInsert;
        
    }
    
     //this method logs error 
    public static DebugLog__c logError(String Objectname,string objectNumber,string record,string processType,string processName,string opertationName,string severity,string errorMessage,string status,string comment,string stackTrace){
        DebugLog__c errorLog = new DebugLog__c(); 
        errorLog.Object__c = Objectname;
        errorLog.Object_Number__c =objectNumber;
        errorLog.Record__c = record;
        errorLog.Errored_Process_Type__c = processType;
        errorLog.Errored_Process_Name__c = processName;      
        errorLog.Operation_Name__c = opertationName; 
        errorLog.Severity__c = severity;
        errorLog.Message__c = errorMessage;
        errorLog.TypeName__c = status;
        errorLog.Comments__c = comment;
        errorLog.StackTraceString__c  = stackTrace; 
        
        return errorLog;
    }
    
  
    Public static void updateOwnerAfterUpdate(list<account> accList,Map<Id,Account> accOldMap){ 
         //System.debug('Method');
         String customerLocationRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Customer_Location').getRecordTypeId();
        set<id> customerLocAccountIdSet = new set<id>();
        String endCustomerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_End_Customer').getRecordTypeId();

        Map<Id,Account> accMap = new Map<Id,Account>();
        
    	for(account each : accList){
            System.debug('each'+each.RecordTypeId);
            if(each.RecordTypeId.equals(customerLocationRecordTypeId) && each.ownerId != accOldMap.get(each.Id).ownerId){
               // System.debug('1');
               
                    customerLocAccountIdSet.add(each.Id);
                	accMap.put(each.Id,each);
                
                    
            } else if(
                each.RecordTypeId.equals(endCustomerRecordTypeId) && 
                each.Business_Segment__c != accOldMap.get(each.Id).Business_Segment__c && 
                each.Distributor_Location__c != null
            ){
                customerLocAccountIdSet.add(each.Distributor_Location__c);
            }  
        }
        
        
          //List<Account> endCustomer = [SELECT Id, Business_Segment__c ,RecordTypeId,OwnerId,Distributor_Location__c,Distributor_Location__r.OwnerId FROM Account WHERE RecordTypeId =: endCustomerRecordTypeId AND Distributor_Location__c IN :customerLocAccountIdSet];
       		//updateOwner(endCustomer);
        if(customerLocAccountIdSet.Size()>0){
            database.executeBatch(new UpdateEndCustOwner(customerLocAccountIdSet));
        }
       		 
       
        /*  
       /* String customerLocationRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Customer_Location').getRecordTypeId();
        String endCustomerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_End_Customer').getRecordTypeId();
        set<id> customerLocAccountIdSet = new set<id>();
        
    	for(account each : accList){
            if(each.RecordTypeId.equals(customerLocationRecordTypeId) && each.ownerId != accOldMap.get(each.Id).ownerId){
                
                if(each.id!=NULL)
                    customerLocAccountIdSet.add(each.Id);
            }    
        }
        List<Account> endCustomer = [SELECT Id, OwnerId FROM Account WHERE RecordTypeId =: endCustomerRecordTypeId AND Distributor_Location__c IN :customerLocAccountIdSet];
		System.debug('endCustomer'+endCustomer);
        for(Account endCusAcc : endCustomer)
        {
            endCusAcc.OwnerId = endCusAcc.Distributor_Location__r.OwnerId;
        }
    }*/
    }
    
    /**  
        * @description  To recalculate account, opportunity and case sharing
        * @param        updatedAccountIdsSet
        * @return       void
    */
    private static void recalculateAccountSharingOnAccountOwnerUpdate(Set<Id> updatedAccountIdsSet){
        Set<Id> userIds		= new Map<Id,User>(UserUtility.getAllCommunityUsers()).keySet();
        AccountSharingUtility.createSharingForAccount(userIds, updatedAccountIdsSet);// Initiates Account Sharing for Community
        OpportunitySharingUtility.createOpportunitySharing(new Map<Id, Opportunity>(OpportunitySharingUtility.allOpportunitiesRelatedToAccounts(updatedAccountIdsSet)).keySet()); //Recreates Opportunity Sharing due to Account Sharing Deletion
        CaseSharingUtility.createSharingForCase(new Map<Id, Case>(CaseSharingUtility.allCasesRelatedToAccounts(updatedAccountIdsSet)).keySet()); //Recreates Case Sharing due to Account Sharing Deletion
    }
}