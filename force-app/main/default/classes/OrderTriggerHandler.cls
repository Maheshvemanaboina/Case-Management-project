/******************************
 * Written By : Rekha
 * Purpose : To add status to Order and owner whenever an order is getting created from SAP
 * Update : Changed Structure of the Trigger, added sharing rule for Community users
 * ****************************/

public with sharing class OrderTriggerHandler extends TriggerHandler {
    
    public override void processBeforeInsert(){

        OrderDataUpdate.updateOrderOnBeforeInsert((List<Order>)trigger.New);
    }

    public override void processBeforeUpdate(){

        OrderDataUpdate.updateOrderOnBeforeUpdate((List<Order>)trigger.New, (Map<Id,Order>)trigger.OldMap);
    }

}