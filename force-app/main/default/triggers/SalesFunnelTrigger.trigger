/*       
@Name           - SalesFunnelTrigger
@Author         - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@ModifiedBy     - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@Version        - 1.0
@CreatedDate    - 12-08-2020
@UsedBy         - SalesFunnelTriggerHandler
@Description    - Trigger for Commercial Performance Object
@Changes        - No Changes done
NOTE            - Please do not write any code here, this is the only piece of code that this trigger should contain, please change anything in the CommercialActivityTriggerHandler Class

UserId              | Author-Email                           | Date          | Comment
====================|========================================|===============|=========
0054H000004H3IaQAK  | sibananda.bhuyan@frieslandcampina.com  | 12-08-2020    | Created Trigger
*/

trigger SalesFunnelTrigger on Sales_Funnel__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    SalesFunnelTriggerHandler salesTrig = new SalesFunnelTriggerHandler();
    salesTrig.process();
}