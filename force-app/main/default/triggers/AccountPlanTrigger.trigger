/*
    Author : Sibananda Bhuyan 15-04-2020
    Description : Trigger for Account Plan ( Field_Of_Play__c ) Object
    NOTE : Please do not write any code here, this is the only piece of code that this trigger should contain, please change anything in the AccountPlanTriggerHandler Class
*/
trigger AccountPlanTrigger on Field_of_Play__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    AccountPlanTriggerHandler accPlanTrig = new AccountPlanTriggerHandler();
    accPlanTrig.process();
}