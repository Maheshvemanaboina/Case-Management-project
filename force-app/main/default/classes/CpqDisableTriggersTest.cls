/*------------------------------------------------------------  
Author:       Gianluca Calcagni
Company:      Waeg
Description:  Used to disable the CPQ triggers in Process Builder

History
2019-10-10    Gianluca Calcagni    Created test class
------------------------------------------------------------*/
@isTest
private class CpqDisableTriggersTest {



    @isTest
    static void testCpqDisableTriggers() {
        CpqDisableTriggers.cpqDisableTriggers();
    }



}