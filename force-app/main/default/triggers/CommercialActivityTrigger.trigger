/*       
@Name           - CommercialActivityTrigger
@Author         - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@ModifiedBy     - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@Version        - 1.0
@CreatedDate    - 12-08-2020
@UsedBy         - CommercialActivityTriggerHandler
@Description    - Trigger for Commercial Activity Object
@Changes        - No Changes done
NOTE            - Please do not write any code here, this is the only piece of code that this trigger should contain, please change anything in the CommercialActivityTriggerHandler Class

UserId              | Author-Email                           | Date          | Comment
====================|========================================|===============|=========
0054H000004H3IaQAK  | sibananda.bhuyan@frieslandcampina.com  | 12-08-2020    | Created Trigger
*/

trigger CommercialActivityTrigger on Commercial_Activity__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CommercialActivityTriggerHandler commActTrig = new CommercialActivityTriggerHandler();
    commActTrig.process();
    
}