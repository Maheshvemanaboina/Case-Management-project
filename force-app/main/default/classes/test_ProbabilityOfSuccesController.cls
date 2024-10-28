@isTest
    public class test_ProbabilityOfSuccesController {
    static testMethod void testInlineEditControlCreate(){

        Project__c a = new Project__c(name='Test');
        insert a;
        
        Test.startTest();
        
          
        PageReference pageRef = Page.ProbabilityOfSucessVFPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        ProbabilityOfSuccess1 q =  new ProbabilityOfSuccess1(sc);
        q.save();
        q.fetchMydtpList();
        
        Test.stopTest();

        }
    }