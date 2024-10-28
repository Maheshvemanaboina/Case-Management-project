/*------------------------------------------------------------  
Author:       Gianluca Calcagni
Company:      Waeg
Description:  Used to enable the CPQ triggers in Process Builder

History
2019-10-10    Gianluca Calcagni    Created class
------------------------------------------------------------*/
global without sharing class CpqEnableTriggers {



    @InvocableMethod( label='Enable CPQ Triggers in Process Builder' )
    global static void cpqEnableTriggers() {
        SBQQ.TriggerControl.enable();
    }



}