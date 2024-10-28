@isTest
public class BreadCrumbCommControllerTest {
      
    @isTest static void verifyData(){
        test.startTest();
        
       Account accObj = TestUtility.createAccount('TestPillow');
        insert accObj;
        Account parentAcc = TestUtility.createCommercialCustomer();
        insert parentAcc;
        Account contactWorkLocation = TestUtility.createCustomerLocation(parentAcc);
        insert contactWorkLocation;
        String accId = BreadCrumbCommController.fetchGenRecId('Account' ,accObj.Name,accObj.Distributor_Location__c);
        string loc='';
         String accId1 = BreadCrumbCommController.fetchGenRecId('Account' ,accObj.Name,loc);
       Contact con = TestUtility.createContact(parentAcc, contactWorkLocation);
        insert con;
        Case cs = TestUtility.createCase(con);
        insert cs;
        
        case cs1 = new case();
        List<case> csList = new List<case>();
        
        cs1.AccountId=contactWorkLocation.Id;
        cs1.ContactId=con.Id;
        csList.add(cs1);
        insert csList;
		String csId = BreadCrumbCommController.fetchRecId(cs1.CaseNumber);
        //==========================================================//
             
        
        test.stopTest();
        System.assertEquals(String.valueOf([SELECT ID FROM ACCOUNT WHERE NAME ='TestPillow'].Id), accId);
        System.assertEquals(String.valueOf([SELECT ID FROM ACCOUNT WHERE NAME ='TestPillow'].Id), accId1);
       // System.assertEquals(String.valueOf([SELECT ID FROM CASE WHERE CaseNumber =:casesToInsert[0].CaseNumber].Id), String.valueOf(casesToInsert[0].Id));
                //System.assertEquals(String.valueOf([SELECT ID ,CaseNumber FROM CASE WHERE CaseNumber =:csList].Id),csId);

    }

}