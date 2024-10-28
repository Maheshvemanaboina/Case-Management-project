@isTest
public class ProcessInstanceWorkitemControllerTest {

    @isTest
    static void testGetProcessInstanceWorkitem() {
		Account commercialCustIMCD = TestUtility.createAccount('IMCD Holding');
        Insert commercialCustIMCD;
        
        RecordType recordType = [SELECT Id,Name,DeveloperName FROM RecordType WHERE DeveloperName ='FCI_TSS_Case']; 
        Case testCase = new Case(
            Subject = 'Test Case',
            Description = 'Test Description',
            Type = 'Customer/Sales Support',
            Sub_Type__c = 'Application Project',
            Region__c = 'APAC',
            AccountId = commercialCustIMCD.Id,
            RecordTypeId = recordType.Id
        );
        insert testCase;

        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(testCase.Id);
        Approval.ProcessResult result = Approval.process(req);
        System.assert(result.isSuccess());
        List<Id> newWorkitemIds = result.getNewWorkitemIds();
        String targetObjectId = ProcessInstanceWorkitemController.getProcessInstanceWorkitem(newWorkitemIds[0]);
        System.assertEquals(testCase.Id, targetObjectId);
    }
}