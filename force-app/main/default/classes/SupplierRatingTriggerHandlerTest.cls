/* *******************************************************************************************************
 * Name               : SupplierRatingTriggerHandlerTest                                                 *
 * Description        : SRM - Test class for SupplierRatingTriggerHandlerTest                                  *
 * Created Date       : 24-Jul-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       24-Jul-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
@IsTest
private class SupplierRatingTriggerHandlerTest {

    @IsTest
    static void shouldCreateSupplierRatingHistoryRecords() {
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(new Supplier_Hub__c(Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_STRATEGIC), true);
        List<Supplier_Rating__c> supplierRatings = TestUtils.newSupplierRatings(new Supplier_Rating__c(Supplier_Hub__c = supplierHub.Id), 5, true);

        Map<Id, String> supplierRatingId2CommentBeforeChangeMap = new Map<Id, String>();
        Map<Id, String> supplierRatingId2RatingBeforeChangeMap = new Map<Id, String>();

        Test.startTest();

        for(Integer i = 0; i < supplierRatings.size(); i++) {
            supplierRatingId2CommentBeforeChangeMap.put(supplierRatings[i].Id, supplierRatings[i].Comment__c);
            supplierRatingId2RatingBeforeChangeMap.put(supplierRatings[i].Id, supplierRatings[i].Rating__c);
            supplierRatings[i].Comment__c = 'Test value change ' + i;
            supplierRatings[i].Rating__c = '3';
            SUPPLIERrATINGS[I].No_Change_On_Rating__c = true;
        }

        update supplierRatings;

        Test.stopTest();

        for(Supplier_Rating_History__c srh : [
            SELECT Comment__c, Rating__c, Supplier_Rating__c
            FROM Supplier_Rating_History__c
            WHERE Supplier_Rating__c IN: supplierRatingId2CommentBeforeChangeMap.keySet()
        ]) {
            //check if comment in history record is equal to the value from before update
            System.assertEquals(srh.Comment__c, supplierRatingId2CommentBeforeChangeMap.get(srh.Supplier_Rating__c));
            //check if rating in history record is equal to the value from before update
            System.assertEquals(srh.Rating__c, supplierRatingId2RatingBeforeChangeMap.get(srh.Supplier_Rating__c));
        }
    }


    @IsTest
    static void shouldCreateSupplierRatingHistoryRecordsOnRatingsDelete() {
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(new Supplier_Hub__c(Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_STRATEGIC), true);
        List<Supplier_Rating__c> supplierRatings = TestUtils.newSupplierRatings(new Supplier_Rating__c(Supplier_Hub__c = supplierHub.Id), 5, true);

        Map<Id, String> supplierRatingId2CommentBeforeDeleteMap = new Map<Id, String>();
        Map<Id, String> supplierRatingId2RatingBeforeDeleteMap = new Map<Id, String>();

        for(Integer i = 0; i < supplierRatings.size(); i++) {
            supplierRatings[i].Comment__c = 'Test value change ' + i;
            supplierRatings[i].Rating__c = '3';
            supplierRatings[i].Rating__c = '3';
            supplierRatings[i].No_Change_On_Rating__c = true;
            supplierRatingId2CommentBeforeDeleteMap.put(supplierRatings[i].Id, supplierRatings[i].Comment__c);
            supplierRatingId2RatingBeforeDeleteMap.put(supplierRatings[i].Id, supplierRatings[i].Rating__c);
        }

        update supplierRatings;

        Test.startTest();

        delete supplierRatings;

        Test.stopTest();

        for(Supplier_Rating_History__c srh : [
                SELECT Comment__c, Rating__c, Supplier_Rating__c
                FROM Supplier_Rating_History__c
                WHERE Supplier_Rating__c IN: supplierRatingId2CommentBeforeDeleteMap.keySet()
        ]) {
            //check if comment in history record is equal to the value from before update
            System.assertEquals(srh.Comment__c, supplierRatingId2CommentBeforeDeleteMap.get(srh.Supplier_Rating__c));
            //check if rating in history record is equal to the value from before update
            System.assertEquals(srh.Rating__c, supplierRatingId2RatingBeforeDeleteMap.get(srh.Supplier_Rating__c));
        }
    }
    @IsTest
    static void shouldCreateFollowUpTask() {
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(new Supplier_Hub__c(Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_STRATEGIC), true);
        List<Supplier_Rating__c> supplierRatings = TestUtils.newSupplierRatings(new Supplier_Rating__c(Supplier_Hub__c = supplierHub.Id), 5, true);
        datetime myDate = datetime.newInstance(2022, 01, 08);
        Supplier_Rating__c objRating = supplierRatings[0];
        objRating.Follow_Up_Task_TimeStamp__c = myDate;
        objRating.Follow_up_task_created__c = true;
        objRating.Rating__c = '2';
        update objRating;
        Test.startTest();
        SupplierRatingTriggerHelper.createHistoryRecordForGetFeedback(objRating, userinfo.getUserId());
        Test.stopTest();
    }
    @IsTest
    static void shouldCreateFollowUpTaskIfNotPresent() {
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(new Supplier_Hub__c(Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_STRATEGIC), true);
        List<Supplier_Rating__c> supplierRatings = TestUtils.newSupplierRatings(new Supplier_Rating__c(Supplier_Hub__c = supplierHub.Id), 5, true);
        datetime myDate = datetime.newInstance(2022, 01, 08);
        Supplier_Rating__c objRating = supplierRatings[0];
        objRating.Rating__c = '2';
        update objRating;
    }
    @isTest
    static void getHistoryRecordsTest(){
         Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(new Supplier_Hub__c(Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_STRATEGIC), true);
        List<Supplier_Rating__c> supplierRatings = TestUtils.newSupplierRatings(new Supplier_Rating__c(Supplier_Hub__c = supplierHub.Id), 5, true);
        supplierRatings[0].Rating__C  = '4';
        update supplierRatings[0];
        
        String ratingIds = '["'+supplierRatings[0].Id+ '"]';
        Test.startTest();
        system.debug('ratingIds '+ ratingIds);
        SRM_GetHistoryRecords.getHistoryRecords(ratingIds);
        Test.stopTest();
    }
    @isTest
    static void historyTest(){
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(new Supplier_Hub__c(Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_STRATEGIC), true);
        List<Supplier_Rating__c> supplierRatings = TestUtils.newSupplierRatings(new Supplier_Rating__c(Supplier_Hub__c = supplierHub.Id), 5, true);
        SupplierRatingTriggerHelper.createHistoryRecordForGetFeedback(supplierRatings[0], userinfo.getUserId());
    }

}