/******************************
* Written By : Rekha
* Purpose : To Roll up of Sales Manager(SM), Sales Assistant(SA) and Person Responsible(PR) to Account Teams from Partner Role

@Changes
*Rekha : 22-11-2021 --- To update account team member role when partner role relationship name get changes from SAP
*Mahendra : 07-09-2022 - To deactivate the partner role when the role (or) sales area has changed in SAP and pushed to SF
					   - To add/remove the account team member as per the changes of partner roles pushed from SAP
* ****************************/
public class PartnerRoleTriggerHandler  extends TriggerHandler{  
     
    
    public override void processAfterInsert(){         
        
        //variable declaration
         list<Partner_Role__c> newList = (list<Partner_Role__c>) trigger.new;
        set<Id> partnerRoleIds = new set<Id>();
        set<string> sapEmployeeIdSet = new set<string>();
        
        //loop through the new list and check for sap_employee_id 
        for(Partner_Role__c each : newList){
            if(each.SAP_Employee_Id__c!=NULL){
               partnerRoleIds.add(each.id);
               sapEmployeeIdSet.add(each.SAP_Employee_Id_Without_Zeros__c);
               RecursionHandler.receivedPartnerRoleRecords.add(each.id);
               RecursionHandler.receivedPartnerRoleRecordsSourceAccountMap.put(each.id, each.Source_Account__c);
            }
        }  
        //system.debug('-----'+sapEmployeeIdSet);
        
        // call method to add team member
        if(partnerRoleIds.size()>0){
            CreateAccountTeamMember.addMember(partnerRoleIds, sapEmployeeIdSet);
        }
   
    }
   
    public override void processAfterUpdate(){

        Boolean notFirstRun = false;//Variable to identify whether the after update event entered first time or not
        if(RecursionHandler.afterUpdateFirstRun){
            RecursionHandler.afterUpdateFirstRun = false;
        }else{
            notFirstRun = true;
        }
        
        //system.debug('notFirstRun = '+notFirstRun);
        
        if(!RecursionHandler.inFutureContext){
            //system.debug('-------after update--');             
            //system.debug('-------RecursionHandler.inFutureContext--'+RecursionHandler.inFutureContext);
            
            RecursionHandler.inFutureContext = true;            
       
             //variable declaration
            list<Partner_Role__c> newList = (list<Partner_Role__c>) trigger.new;
            map<id,Partner_Role__c> oldMap = (map<id,Partner_Role__c>) trigger.oldMap;
            set<string> sapEmployeeIdSetRoleUpdate = new set<string>();
            set<id> sourceAccountSetRoleUpdate = new set<id>();
            set<Id> partnerRoleIdsRoleUpdate = new set<Id>();
            set<Id> partnerRoleIds = new set<Id>();
            set<string> sapEmployeeIdSet = new set<string>();            
            //set<id> updatedPartnerRoleIds = new set<id>();
            set<id> sourceAccountOfUpdatedPartnerRoles = new set<id>();
            Set<String> sourceAccountUserSet = new Set<String>();
            Set<Id> partnerRoleSourceAccountSet = new Set<Id>();
            //system.debug('after update newList size = '+newList.size());
            //system.debug('after update newList = '+newList);
            for(Partner_Role__c each : newList){
                //system.debug('each Id - '+each.Id);
                
                //Purpose : Deactivated/Deleted partner roles are not sent from SAP.
               //Deactivating a partner role in SF should remove the member from the account team for a particular account.           
             
               
                 If(!RecursionHandler.receivedPartnerRoleRecords.contains(each.Id)){
                     RecursionHandler.receivedPartnerRoleRecords.add(each.id);
                     sourceAccountOfUpdatedPartnerRoles.add(each.Source_Account__c);
                     //system.debug('line 76 RecursionHandler.receivedPartnerRoleRecords = '+RecursionHandler.receivedPartnerRoleRecords);
                 }    
                
                //Rekha - 22-11-2021 - To update account team member role
                //to update account teams if partner role changes
                if(each.Relation_Name__c!=oldMap.get(each.id).Relation_Name__c && each.Relation_Name__c!=NULL){
                    sapEmployeeIdSetRoleUpdate.add(each.SAP_Employee_Id_Without_Zeros__c);
                    sourceAccountSetRoleUpdate.add(each.Source_Account__c);
                    partnerRoleIdsRoleUpdate.add(each.id);
                } 
                
                if(each.active__c!=oldMap.get(each.id).active__c){
                    if(each.active__c){
                       partnerRoleIds.add(each.id);
                       sapEmployeeIdSet.add(each.SAP_Employee_Id_Without_Zeros__c);    
                    }
                }
                
                if(RecursionHandler.receivedPartnerRoleRecords.contains(each.Id)){
                    sourceAccountUserSet.add(each.Source_Account__c+'-'+each.SAP_Employee_Id__c+'-'+each.Sales_Area__c);
                    partnerRoleSourceAccountSet.add(each.Source_Account__c);
                }
            } 
            
            //system.debug('---RecursionHandler.receivedPartnerRoleRecords---'+RecursionHandler.receivedPartnerRoleRecords.size());
            
            //call method to update team member role
            if(partnerRoleIdsRoleUpdate.size()>0){              
               CreateAccountTeamMember.updateAccountTeamMemberRole(partnerRoleIdsRoleUpdate,sourceAccountSetRoleUpdate, sapEmployeeIdSetRoleUpdate);    
            }
            
            //call method to add new team member
            if(partnerRoleIds.size()>0){               
               CreateAccountTeamMember.addMember(partnerRoleIds, sapEmployeeIdSet);
            }
            
            //call method to deactivate the partnerrole which has not updated from SAP
            if(RecursionHandler.receivedPartnerRoleRecords.size()>0 && sourceAccountOfUpdatedPartnerRoles.size()>0){ 
                //system.debug('line 116 deactivate partner role');
               CreateAccountTeamMember.deactivatePartnerRole(RecursionHandler.receivedPartnerRoleRecords,sourceAccountOfUpdatedPartnerRoles, new Set<String>());    
            }
            
            //call method to deactivate the partner role for which the role (or) sales area has changed in SAP and pushed to SF
            if(RecursionHandler.receivedPartnerRoleRecords.size()>0 && partnerRoleSourceAccountSet.size()>0 && sourceAccountUserSet.size() > 0){
                //system.debug('line 122 deactivate partner role');
                CreateAccountTeamMember.deactivatePartnerRole(RecursionHandler.receivedPartnerRoleRecords,partnerRoleSourceAccountSet, sourceAccountUserSet);
            }
        }
        
        //compare existing partner roles in SF with partner roles sent from SAP and deactivate the partner roles that are removed in SAP
        if(!RecursionHandler.isPartnerRoleRecalculationAfterUpdateRecursive && notFirstRun){
            RecursionHandler.isPartnerRoleRecalculationAfterUpdateRecursive = true;
            Set<Id> sourceAccountOfUpdatedPartnerRoles = new Set<Id>();
            list<Partner_Role__c> updatedList = (list<Partner_Role__c>) trigger.new;
            Map<Id, Partner_Role__c> partnerRoleOldMap = (Map<Id, Partner_Role__c>) trigger.oldMap;
            Set<Id> partnerRoleIdSet = new Set<Id>();
            Set<String> sapEmployeeIdSet = new Set<String>();
            
            for(Partner_Role__c pr : updatedList){
                RecursionHandler.receivedPartnerRoleRecordsSourceAccountMap.put(pr.id, pr.Source_Account__c);
                if(pr.active__c!=partnerRoleOldMap.get(pr.id).active__c && pr.active__c){
                       partnerRoleIdSet.add(pr.id);
                       sapEmployeeIdSet.add(pr.SAP_Employee_Id_Without_Zeros__c);    
                }
            }
            
            //system.debug('line 137 = RecursionHandler.receivedPartnerRoleRecordsSourceAccountMap = '+RecursionHandler.receivedPartnerRoleRecordsSourceAccountMap);
            //call method to deactivate the partnerrole which has not updated from SAP
            if(RecursionHandler.receivedPartnerRoleRecordsSourceAccountMap.size()>0){   
                //system.debug('line 140 deactivate partner role');
               CreateAccountTeamMember.deactivatePartnerRoleNonFuture(RecursionHandler.receivedPartnerRoleRecordsSourceAccountMap.KeySet(),new Set<Id>(RecursionHandler.receivedPartnerRoleRecordsSourceAccountMap.values()), new Set<String>());    
            }
            
            //call method to add new team member
            if(partnerRoleIdSet.size()>0){               
               CreateAccountTeamMember.addMember(partnerRoleIdSet, sapEmployeeIdSet);
            }
        }
    }
}