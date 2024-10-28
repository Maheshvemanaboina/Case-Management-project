/*
* @Author : Shiva Karna 
* @Date : 28-July 2021
* @Desc : This test class was created for CPQActivePriceControlTriggerHandler class.
* @Jira : SCPQ-1055
*/
@isTest
private class CPQActivePriceControlTriggerHandlerTest {
    @isTest
    private static void activePriceControlTest(){
      // Create a sample product //
        Product2 sampleProduct = DataFactoryTest.getProductSKUs( 1 )[ 0 ];
        sampleProduct.Product_Code__c = '000000000000094500';
        insert sampleProduct;    
      // Create a sample account //
        Account sampleAccount = DataFactoryTest.getAccountCommercialCustomers( 1 )[ 0 ];        
        sampleAccount.SAP_Number__c = '0000100655';
        sampleAccount.SAP_Number_PE1__c = '0000100655';
        
        insert sampleAccount;
        CPQ_Active_Price_Model__c activePriceModelRec = new CPQ_Active_Price_Model__c(SAP_Number_Upload__c='0000100655',
                                                                                      Material_Number_Upload__c='000000000000094500',
                                                                                      Price_Model__c=true);
        insert activePriceModelRec;
        activePriceModelRec.Price_Model__c=false;
        update activePriceModelRec;
    }
}