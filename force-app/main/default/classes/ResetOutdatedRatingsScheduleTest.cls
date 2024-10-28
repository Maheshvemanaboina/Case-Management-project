/* *******************************************************************************************************
 * Name               : ResetOutdatedRatingsScheduleTest                                                 *
 * Description        : SRM - Test class for ResetOutdatedRatingsSchedule.cls                                  *
 * Created Date       : 04-Aug-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       04-Aug-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
@IsTest
private class ResetOutdatedRatingsScheduleTest {

    @TestSetup
    static void testSetup() {
        List<Value_Element__c> valueELements = TestUtils.newValueElements(new Value_Element__c(Is_Active__c = true), 5, true);
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(new Supplier_Hub__c(Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_STRATEGIC), true);
        Supplier_Location__c supplierLocation = TestUtils.newSupplierLocation(new Supplier_Location__c(Supplier_Hub__c = supplierHub.Id), false);
        list<location__c> locs = [SELECT id FROM Location__c];
        for(location__c lo:locs ){
            lo.is_active__c = true;
        }
        update locs;
        insert supplierLocation;
        List<Supplier_Rating__c> supplierRatings = [SELECT Rating__c, Comment__c, Value_Element__r.Name, Location__r.Name, Supplier_Rating_Header__c FROM Supplier_Rating__c];

        for(Supplier_Rating__c sr : supplierRatings) {
            sr.Rating__c = '4';
            sr.Comment__c = 'Great job!';
        }

        update supplierRatings;
    }

    @IsTest
    static void shouldResetOutdatedRatings() {

        Test.startTest();

        Supplier_Rating_Header__c srh = [SELECT Next_Rating_Date__c FROM Supplier_Rating_Header__c];
        srh.Next_Rating_Date__c = Date.today().addDays(-1);
        update srh;


        Database.executeBatch(new ResetOutdatedRatingsSchedule());

        ResetOutdatedRatingsSchedule rors = new ResetOutdatedRatingsSchedule();
        String sch = '0 0 23 * * ?';
        System.schedule('Test Reset Outdated Data', sch, rors);

        ResetOutdatedRatingsSchedule.scheduleThisClass();

        Test.stopTest();

        for(Supplier_Rating__c sr : [SELECT Rating__c, Comment__c FROM SUpplier_Rating__c]) {
            System.assertEquals('0', sr.Rating__c);
            System.assert(String.isBlank(sr.Comment__c));
        }

    }

}