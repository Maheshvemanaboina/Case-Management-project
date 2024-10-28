/*
    Author : Sibananda Bhuyan 15-04-2020
    Description : Trigger for Business Strategy Object
    NOTE : Please do not write any code here, this is the only piece of code that this trigger should contain, please change anything in the BusinessStrategyTriggerHandler Class
*/
trigger BusinessStrategyTrigger on Business_Strategy__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    BusinessStrategyTriggerHandler bizStratTrig = new BusinessStrategyTriggerHandler();
    bizStratTrig.process();
}