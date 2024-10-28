@isTest 
public class scheduleInactiveLeadDeletionTest {
    static testmethod void TestLeadDelete()
    {
        Test.starttest();
        scheduleInactiveLeadDeletion sc = new scheduleInactiveLeadDeletion();
        String sch ='0 48 * * * ?'; 
        System.schedule('Schedule to delete lead', sch,sc);
        Test.stoptest();
    }
}