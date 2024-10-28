/*------------------------------------------------------------  
Author:       Gianluca Calcagni
Company:      Waeg
Description:  Used to disable the CPQ triggers in Process Builder

History
2019-10-10    Gianluca Calcagni    Created class
------------------------------------------------------------*/
global without sharing class CpqDisableTriggers {



    @InvocableMethod( label='Disable CPQ Triggers in Process Builder' )
    global static void cpqDisableTriggers() {
        SBQQ.TriggerControl.disable();
    }



}