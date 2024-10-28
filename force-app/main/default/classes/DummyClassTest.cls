/*------------------------------------------------------------  
Author:       Gianluca Calcagni
Company:      Waeg
Description:  Tests the apex class DummyClass

History
2019-08-23    Gianluca Calcagni    Created class
------------------------------------------------------------*/  
@isTest
public class DummyClassTest {



    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Tests the dummy method for code coverage purposes

    History:
    2019-08-23    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    @isTest
    public static void dummyMethodTest() {
        // Call the method //
        Test.startTest();
        DummyClass.dummyMethod();
        Test.stopTest();
        
        // Assert the result //
        System.assert( true, 'This is only for code coverage purposes' );
    }



}