@isTest
public class ContractTriggerHandler_Test {
    
    public static testmethod void contractTest(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing112233test', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='Testing112233test@testorg.com');
        
        insert u;
        u.SAP_Employee_Id__c = '12345';
        update u;
        
        Account acc = TestUtility.createCommercialCustomer('Commercial Account');
        insert acc;
        
        Account customerL = TestUtility.createCommercialCustomer(acc.id);
        insert customerL;
        
        Contract con = new contract();
        con.Contract_Owner__c = '12345';
        con.Parent_Account__c = acc.id;
        con.AccountId = customerL.id;
        con.StartDate = date.today();
        con.EndDate = date.today().addMonths(2);
        insert con;
        
        u.SAP_Employee_Id__c = '123456';
        update u;
        
        con.Contract_Owner__c = '123456';
        //con.StartDate = date.today();
        con.EndDate = date.today().addMonths(3);
        update con;
    }

}