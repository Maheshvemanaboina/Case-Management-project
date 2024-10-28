@isTest
public class CloseSalesAgreementBatchScheduleTest {
    
    static testmethod void schedulerTest(){
        CloseSalesAgreementBatchSchedule cs = new CloseSalesAgreementBatchSchedule();
		System.schedule('CloseSalesAgreementBatchSchedule', '0 0 6 * * ?',cs);
    } 

}