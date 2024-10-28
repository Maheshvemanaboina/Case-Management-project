@isTest
    public class test_ProjectPlanningController {
    static testMethod void testInlineEditControlCreate(){

        Project__c a = new Project__c(name='Test');
        insert a;
        
        Test.startTest();
        
          
        PageReference pageRef = Page.ProbabilityOfSucessVFPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        projectPlanningController q =  new projectPlanningController(sc);
        q.save();
        q.fetchMydtpList();
        
        Test.stopTest();

        }
    }