@isTest
public class LeadVisitRTTest {
  @testSetup
    static void dataSetup(){
        
    }
    @isTest
    static void recordTypeTest(){
        Map<String,String> recordtypes = new Map<String,String>();
        recordtypes = LeadVisitRT.fetchRecordTypeValues();
        system.assert(recordtypes.size()>0);
        String recordTypeName = LeadVisitRT.getRecTypeId(recordtypes.get('FCI Visit Report'));       
        system.assert(recordTypeName != '');
    }    
}