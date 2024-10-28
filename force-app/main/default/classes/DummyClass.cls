/*------------------------------------------------------------  
Author:       Gianluca Calcagni
Company:      Waeg
Description:  Dummy class used to invoke a method that does nothing. This is useful to stop a process builder flow 

History
2019-08-23    Gianluca Calcagni    Created class
------------------------------------------------------------*/  
global without sharing class DummyClass {



    // METHODS //

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  It does nothing. This is useful to stop a process builder flow
    Inputs:       none
    Returns:      void
    Test Class:   DummyClassTest

    History:
    2019-08-23    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    @InvocableMethod(
        label='Dummy Apex step for Process Builder'
    )
    global static void dummyMethod() {
        // DO NOTHING //
        return;
    }



}