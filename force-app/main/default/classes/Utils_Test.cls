/* *******************************************************************************************************
 * Name               : Utils_Test                                                                       *
 * Description        : SRM - Test class for Utils class                                                       *
 * Created Date       : 07-Jul-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       07-Jul-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */

@IsTest
private class Utils_Test {

    @isTest
    public static void shouldFetchFieldAsASetInSObjectList() {
        //given
        List<Account> accounts = TestUtils.newAccounts(new Account(), 2, false);
        accounts[0].Name = 'Name0';
        accounts[1].Name = 'Name1';

        //when
        Set<String> values = Utils.fetchSet(accounts, 'Name');
        Map<String, String> picklistValueMap = Utils.getPicklistValues(ContentVersion.sObjectType, 'Category__c');

        //then
        system.assertEquals(2, values.size());
        system.assert(values.contains('Name0'));
        system.assert(values.contains('Name1'));
        System.assert(!picklistValueMap.isEmpty());
    }

    @isTest
    public static void shouldGetRecordTypeId() {

        Id designHouseRecordTypeId = Utils.getRecordTypeId('Account', 'SRM_Account');

        system.assertNotEquals(null, designHouseRecordTypeId);
    }
}