/*
    Author : Sibananda Bhuyan
    Description : Trigger for Forecast Accuracy Object
    NOTE : Please do not write any code here, this is the only piece of code that this trigger should contain, please change anything in the ForecastAccuracyTriggerHandler Class
*/
trigger ForecastAccuracyTrigger on Forecast_Accuracy__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    ForecastAccuracyTriggerHandler forecastTrig = new ForecastAccuracyTriggerHandler();
    forecastTrig.process();
}