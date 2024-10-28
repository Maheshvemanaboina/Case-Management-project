/*       
@Name           - AccountTeamUpdateHandler
@Author         - Rekha | Email - rekha.harshit@frieslandcampina.com
@ModifiedBy     - 
@Version        - 1.0
@CreatedDate    - 11-01-2022
@UsedBy         - AccountTrigger
@Description    - This class handles actions whenever account teams get updated
@Changes        - methods 'checkRoleChange' & 'defineAccesslevelToTeamMember' on 16th FEB 2022

User              | Author-Email                        | Date          | Comment
==================|=====================================|===============|=========
Rekha             | rekha.harshit@frieslandcampina.com  | 10-01-2022    | 
Rekha             | rekha.harshit@frieslandcampina.com  | 16-02-2022    |  methods 'checkRoleChange' & 'defineAccesslevelToTeamMember'
*/


public class AccountTeamUpdateHandler {
    
    /*@Description: If a primary team member role/business segment gets updated, then the related end customer's owner is
     * recaculated again
    */
    public static void updateEndCustomerOwner(list<Account_Team__c> newList,map<id,Account_Team__c> oldMap){
    	
        set<id> h5AccountIds = new set<id>();       
        list<account> endCustomerList = new list<account>();
        set<string> businessSegmentSet = new set<string>();
        
        id endCustomerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_End_Customer').getRecordTypeId();
        
        for(Account_Team__c each : newList){
            if(each.primary__c!=oldmap.get(each.id).primary__c || each.primary__c && ((each.Business_Segment__c!=oldmap.get(each.id).Business_Segment__c && each.Business_Segment__c!=NULL)|| (each.Team_Role__c!=oldmap.get(each.id).Team_Role__c && each.Team_Role__c!=NULL))){
            	h5AccountIds.add(each.Source_Account__c); 
                businessSegmentSet.add(each.Business_Segment__c);
                businessSegmentSet.add(oldmap.get(each.id).Business_Segment__c);
            }
        }
        
        if(!h5AccountIds.isEmpty()){
        	endCustomerList = [SELECT id,Distributor_Location__c,Business_Segment__c,RecordTypeId,ownerId FROM Account WHERE RecordTypeId=:endCustomerRecordTypeId and Distributor_Location__c IN : h5AccountIds AND Business_Segment__c IN : businessSegmentSet];   
        }
        //system.debug('----endCustomerList-'+endCustomerList);
        
        if(endCustomerList.size()>0)
            UpdateAccountOwner.updateOwner(endCustomerList);
    }
    
    
    /*@Description: This method check whether a role is updated and send the list 
     *              to method 'defineAccesslevelToTeamMember' to update the access rights
    */
    public static void checkRoleChange(list<Account_Team__c> newList,map<id,Account_Team__c> oldMap){
        
        list<Account_Team__c> updatedTeamList = new list<Account_Team__c>();
        for(Account_Team__c each : newList){
            if(each.Team_Role__c!=oldmap.get(each.id).Team_Role__c){
            	updatedTeamList.add(each);    
            }
        }
        
        if(updatedTeamList.size()>0)
        	defineAccesslevelToTeamMember(updatedTeamList);    
    }
    
    
    /*@Description: This method assigns default access right to team members
     *              when they are created through partner role or manually
    */
    public static void defineAccesslevelToTeamMember(list<Account_Team__c> newList){       
        for(Account_Team__c each : newList){            
            if(each.Team_Role__c==Constants.ACCOUNT_TEAM_ROLE_CMO){
                each.Account_Access__c='Edit';
                each.Contact_Access__c='Edit';
                each.Opportunity_Access__c='Edit';                // Updated Opportuity access from Read to Read/Write as per the ticket ENH-5109
                each.Case_Access__c='Edit';                
            }
            if(each.Team_Role__c==Constants.ACCOUNT_TEAM_ROLE_SALES_MANAGER){
            	each.Account_Access__c='Edit';
                each.Contact_Access__c='Edit';
                each.Opportunity_Access__c='Edit';
                each.Case_Access__c='Edit';    
            }
            if(each.Team_Role__c==Constants.ACCOUNT_TEAM_ROLE_OFO){
            	each.Account_Access__c='Read';
                each.Contact_Access__c='Read';
                each.Opportunity_Access__c='None';
                each.Case_Access__c='Read';    
            }
        }
        
    }

}