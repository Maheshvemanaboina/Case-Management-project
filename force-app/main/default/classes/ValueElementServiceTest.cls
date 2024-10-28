/* *******************************************************************************************************
* Name               : ValueElementServiceTest                                                          *
* Description        : SRM - Test class for ValueElementService                                               *
* Created Date       : 04-Aug-2020                                                                      *
* Created By         : Mateusz Wolak-Książek                                                            *
* -----------------------------------------------------------------------------------------------       *
* VERSION    AUTHOR            DATE                                                                     *
*   1.0 -    Mateusz W-K       04-Aug-2020 Initial version                                              *
*                                                                                                       *
*                                                                                                       *
******************************************************************************************************* */
@IsTest
private class  ValueElementServiceTest {

    @IsTest
    static void shouldNotAllowDelete() {

        List<Value_Element__c> valueElements = TestUtils.newValueElements(new Value_Element__c(Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_STRATEGIC, Is_Active__c = true), 4, true);

        Test.startTest();

        Map<String, List<Value_Element__c>> segment2ValueElementMap = ValueElementService.getSegmentToValueElementsMap();

        Test.stopTest();

        System.assertNotEquals(null, segment2ValueElementMap);
        System.assert(!segment2ValueElementMap.isEmpty());
        System.assert(!segment2ValueElementMap.get(ConstUtils.SUPPLIER_HUB_SEGMENT_STRATEGIC).isEmpty());
    }

}