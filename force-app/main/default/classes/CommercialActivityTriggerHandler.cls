/*       
@Name           - CommercialActivityTriggerHandler
@Author         - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@ModifiedBy     - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@Version        - 1.0
@CreatedDate    - 12-08-2020
@UsedBy         - CommercialActivityTrigger
@Description    - This is a handler class for Commercial Activity Object. This class extends the virtual TriggerHandler class which has all the below methods
                    1. processBeforeInsert()
                    2. processBeforeUpdate()
                    3. processBeforeDelete()
                    4. processAfterInsert()
                    5. processAfterUpdate()
                    6. processAfterDelete()
@Changes        - No Changes done

NOTE : Please use any of the above methods and override them in the below class to use them. DO NOT ADD ANY OTHER METHOD BELOW

UserId              | Author-Email                           | Date          | Comment
====================|========================================|===============|=========
0054H000004H3IaQAK  | sibananda.bhuyan@frieslandcampina.com  | 12-08-2020    | Created Trigger
*/

public with sharing class CommercialActivityTriggerHandler extends TriggerHandler {
    
    /* @Description
        Method Name : processAfterInsert()

        1. A method from TriggerHandler class
        2. Only runs on AfterInsert 
        
        Following things happen in the method:
            1. Shares Commercial Activity records with community users
    */

    public override void processAfterInsert(){
        CommercialActivitySharingUtility.shareAllCommercialActivitiesAndKPIsWithCommunityUsers((List<Commercial_Activity__c>)trigger.new);
    	CommercialActivityScoringHandler.UpdateBucketTotalScore((List<Commercial_Activity__c>)trigger.new,null);
    }
    
    /* @Description
        Method Name : processBeforeUpdate()

        1. A method from TriggerHandler class
        2. Only runs on BeforeUpdate 
        
        Following things happen in the method:
            1. Calculates Scoring for Commercial Activity KPI Records
    */

    public override void processBeforeUpdate(){
        CommercialActivityScoringHandler.updateScore((List<Commercial_Activity__c>)trigger.new);
    }
	
    //Creted by Vijay for the purpose of calculating the total at main bucket level.
    // Created date: 19-10-2021
    public override void processAfterUpdate(){
        CommercialActivityScoringHandler.UpdateBucketTotalScore((List<Commercial_Activity__c>)trigger.new,(Map<Id,Commercial_Activity__c>)trigger.oldMap);
    }
    
    // Creted by Vijay for the purpose of calculating the total score at main bucket level
    // Created date: 19-10-2021
    public override void processAfterDelete(){
        CommercialActivityScoringHandler.UpdateBucketTotalScore(null,(Map<Id,Commercial_Activity__c>)trigger.oldMap);
    }
     public override void processBeforeDelete(){
        KpisDeleteValidator.validateCommercialActivity((List<Commercial_Activity__c>)trigger.old);        
    }
    
}