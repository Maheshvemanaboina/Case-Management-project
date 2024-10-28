@istest
public class UpdateNumberOfQuoteTest {
    
     static testmethod void validateContractSource()
    {
        
        TriggerHandler.skipTrigger = true;
        Account accObj = new Account(Name = 'Test Account',Type='TEST',BillingCity='BANGALORE',BillingCountry='INDIA');
        
        insert accObj;
        Opportunity Op = new Opportunity();
        if(accObj!=NULL){
        Op.ACCOUNTID = accObj.Id;
        Op.Name = 'TestOp';
        Op.Type = 'Renewal';
        Op.StageName = 'Prospect';
        //Op.CloseDate = Date.newInstance(2024,06,30);
        Op.CloseDate = Date.today().addDays(30);
        op.No_of_Quotes__c =  12;    
        insert Op;
        
        }   
        SBQQ__Quote__c quotes = new SBQQ__Quote__c(
            SBQQ__Opportunity2__c = Op.Id,
            SBQQ__Status__c ='Accepted by customer',            
            SBQQ__BillingCity__c ='Bangalore',
            Reason_Opportunity_Won_Loss__c='Best price offer'   );            
        insert quotes;   
        
        test.startTest();
        delete quotes;
        test.stopTest();
        TriggerHandler.skipTrigger = false;
        
    }

}