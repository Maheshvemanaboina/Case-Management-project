/*------------------------------------------------------------  
Author:       Gianluca Calcagni
Company:      Waeg
Description:  The one and only BatchApexErrorEvent trigger. Due to the nature of this entity, only "after insert" is used

History
2019-07-31    Gianluca Calcagni    Created trigger
------------------------------------------------------------*/
trigger BatchApexErrorEventTrigger on BatchApexErrorEvent ( after insert ) {
    new BatchApexErrorEventTriggerHandler( Trigger.new ).run();
}