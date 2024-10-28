/*
    Author : Sibananda Bhuyan
    Description : Trigger for FCI Custoemr Support Object
    NOTE : Please do not write any code here, this is the only piece of code that this trigger should contain, please change anything in the FCICustomerSupportTriggerHandler Class
*/
trigger FCICustomerSupportTrigger on FCI_Customer_Support__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    FCICustomerSupportTriggerHandler fciTrig = new FCICustomerSupportTriggerHandler();
    fciTrig.process();
}