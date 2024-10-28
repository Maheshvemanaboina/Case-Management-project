/* *******************************************************************************************************
 * Name               : CreateTaskModalControllerTest                                                    *
 * Description        : SRM - Test class for CreateTaskModalController class                             *
 * Created Date       : 31-Jul-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       31-Jul-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
@IsTest
private class CreateTaskModalControllerTest {

    @IsTest
    static void shouldSearchUsers() {

        Test.startTest();

        List<LookupSearchResult> lookupSearchResults = CreateTaskModalController.searchUsers('Test', new List<String>());

        Test.stopTest();

        System.assert(!lookupSearchResults.isEmpty());
    }

}