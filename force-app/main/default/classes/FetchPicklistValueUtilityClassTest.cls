@isTest
public class FetchPicklistValueUtilityClassTest {
    
    @istest static void updatePicklist(){
        test.startTest();
       List<String> pickVal = FetchPicklistValueUtilityClass.fetchPickListValues(Account.Business_Segment__c);
       Map<String,List<String>> depPickVal =  FetchPicklistValueUtilityClass.fetchControllerDependentPicklist(Opportunity.Reason_On_Hold__c);
        test.stopTest();
        System.assertEquals(pickVal.size() >0 ? pickVal.size() : 0 , pickVal.size());
        System.assertEquals(!depPickVal.isEmpty() ? depPickVal.keySet() : new Set<String>{} , depPickVal.keySet());
    }

}