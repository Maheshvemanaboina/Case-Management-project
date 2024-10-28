@isTest
public class GetObjectApiNameActionTest {
    @testSetup
    static void setup() {  
        Account accobj = TestUtility.createAccount('FCI Test 1');
        insert accobj; 
    }
    @isTest
    static void testGetSObjectApiName() {
        Account acc = [select Id from Account];

        Test.startTest();

        List<String> sobjectApiNames = GetObjectApiNameAction.getSObjectApiName(new List<Id>{acc.Id});

        Test.stopTest();
        Assert.areEqual('Account', sobjectApiNames[0], 'sobject api name assertion');
    }
}