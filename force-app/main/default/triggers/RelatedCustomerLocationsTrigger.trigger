/*
    Author : Sibananda Bhuyan 15-04-2020
    Description : Trigger for Other Related Customer Location ( Other_Related_Customer_Location__c ) Object
    NOTE : Please do not write any code here, this is the only piece of code that this trigger should contain, please change anything in the RelatedCustomerLocationsTriggerHandler Class
*/
trigger RelatedCustomerLocationsTrigger on Other_Related_Customer_Location__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    RelatedCustomerLocationsTriggerHandler relCustLocTrig = new RelatedCustomerLocationsTriggerHandler();
    relCustLocTrig.process();
}