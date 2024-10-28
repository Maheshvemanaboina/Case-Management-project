/*       
@Name           - AccountTriggerHandler
@Author         - Krzysztof Magdowski | Email - krzysztof.magdowski@waeg.com
@ModifiedBy     - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@Version        - 1.0
@CreatedDate    - 15-07-2019
@UsedBy         - AccountTrigger
@Description    - TriggerHandler for AccountTrigger
@Changes        - No Changes done

UserId              | Author-Email                  | Date          | Comment
====================|===============================|===============|=========
0054H000005dHBKQA2  | krzysztof.magdowski@waeg.com  | 15-07-2019    | Created Trigger
*/

public with sharing class AccountTriggerHandler extends TriggerHandler {
    
    /* @Description
        Method Name : processBeforeInsert()

        1. A method from TriggerHandler class
        2. Only runs on beforeInsert 
        
        Following things happen in the method:
            1. Updates the Account's region based on the billing Country selected
    */
    
    public override void processBeforeInsert(){
        AccountRegionUpdateHandler.getCountrySetting((List<Account>)Trigger.new);
        //AccountRegionUpdateHandler.updateAccountOwner((List<Account>)Trigger.new);
        //isAccountUpdateOwnerTrigAfterUpdateRecursive
        if(!RecursionHandler.isAccountUpdateOwnerTrigAfterUpdateRecursive){
            RecursionHandler.isAccountUpdateOwnerTrigAfterUpdateRecursive = true;
            if(UserUtility.getCurrentUser().Profile.Name != Constants.TEST_FCI_DISTRIBUTOR_PROFILE){
                UpdateAccountOwner.updateOwner((List<Account>)Trigger.new);
            }
        }
        EndCustomerBusinessSegmentValidation.validateEndCustomerOnInsert((List<Account>)Trigger.new);
    }

    public override void processBeforeUpdate(){
        
        restrictUserTomakeAccountInactive.showErrorMessage(trigger.new,(map<id,account>)trigger.oldMap);
        EndCustomerBusinessSegmentValidation.validateEndCustomerBusinessSegment((List<Account>)Trigger.new, (Map<Id,account>)Trigger.oldMap, Trigger.isUpdate);
    }    
    /* @Description
        Method Name : processAfterInsert()

        1. A method from TriggerHandler class
        2. Only runs on After Insert context

        Following things happen in the method:
            1. Created Account Sharing for Community Users
    */
	

    
    public override void processAfterInsert(){
       
        AccountSharingUtility.createAccountSharingOnAccountCreate((List<Account>)trigger.new);
        AddAccountOwnerToAccountTeam.addAccountOwnerInAccountTeams((List<Account>)trigger.new);
        //SendQualifiedProspectToSAPHandler.callUtilityHandler((List<Account>)trigger.new);
        if(UserUtility.getCurrentUser().Profile.Name == Constants.TEST_FCI_DISTRIBUTOR_PROFILE){
            System.enqueueJob(new UpdateAccountOwnerQueueable((List<Account>)Trigger.new));
        }
    }
    
    /* @Description
        Method Name : processAfterUpdate()

        1. A method from TriggerHandler class
        2. Only runs on After Update context

        Following things happen in the method:
            1. Recalculates sharing if there is any update on Account
    */

    public override void processAfterUpdate(){
        AccountSharingUtility.recalculateAccountSharingOnAccountUpdate((List<Account>)trigger.new);
        //UpdateAccountOwner.updateOwnerAfterUpdate((List<Account>)Trigger.new,(Map<Id,Account>)Trigger.oldMap);
        //SendQualifiedProspectToSAPHandler.callUtilityHandler((List<Account>)trigger.new, (Map<Id,Account>)trigger.OldMap);
        System.debug('isAccountTrigAfterUpdateRecursive'+RecursionHandler.isAccountTrigAfterUpdateRecursive);
         if(!RecursionHandler.isAccountTrigAfterUpdateRecursive ){
             RecursionHandler.isAccountTrigAfterUpdateRecursive = true;
             
                
             /*for(account acc : (List<Account>)Trigger.new){
                 System.debug('acc'+acc.Name);
             }*/
      	    UpdateAccountOwner.updateOwnerAfterUpdate((List<Account>)Trigger.new,(Map<Id,Account>)Trigger.oldMap); 
            AddAccountOwnerToAccountTeam.removePreviousOwnerAndAddNewOwnerInAccTeams((Map<Id,Account>)Trigger.newMap,(Map<Id,Account>)Trigger.oldMap);
         }
    }
}