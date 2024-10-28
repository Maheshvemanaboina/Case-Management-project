@isTest()
private class GetPardortProspectActivityWithCacheTest {
    @testSetup
    static void setup() {
        PardotSettings__c settings = new PardotSettings__c(PardotURL__c = 'https://test.pardot.com', PardotBUID__c = '1234');
        insert settings;
    }
  
    
   @isTest static void testCallout() {
        String prospectId = '12345';
        String campaignId = '001000000000001';
        String childLeadId = 'abcde';
        String sessionId = '987654321';
        String LeadID = '00q000000000002';
        String ConId = '003000000000003';
        String mockResponse = '{"nextPageToken":null,"values":[{"campaign":{"salesforceId":"001000000000001"},"details":"Download: Test Form Details","id":1,"prospectId":"12345","typeName":"Form","updatedAt":"2023-03-18T10:00:00.000Z"},{"campaign":{"salesforceId":"001000000000001"},"details":"Download: Test Form Handler Details","id":2,"prospectId":"12345","typeName":"Form Handler","updatedAt":"2023-03-18T11:00:00.000Z"}]}';
        Integer statusCode = 200;
        List<sObject> objHistories = new List<sObject>(); 
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse, statusCode));        
            ProspectActivityWrapper actualResult = new ProspectActivityWrapper();
       		ProspectActivityWrapper cachedResult = new ProspectActivityWrapper();
       		ProspectActivityWrapper cachedResultWithoutDateCheck = new ProspectActivityWrapper();
       		objHistories = ProspectActivityController.leadHistory(LeadID);
       		objHistories = ProspectActivityController.leadHistory(ConId);
            actualResult.values  = ProspectActivityController.getProspectActivity(prospectId, campaignId, childLeadId);  
       		System.assertEquals(2, actualResult.values.size(), 'prospectActivity method should return the correct number of values'); 
       		cachedResult.values  = ProspectActivityController.prospectActivityFromCache(prospectId, campaignId, '2023-03-18T09:00:00.000Z', childLeadId);
       		System.assertEquals(2, actualResult.values.size(), 'prospectActivityFromCache method should return the correct number of values');
       		cachedResultWithoutDateCheck.values = ProspectActivityController.prospectActivityFromCacheWithoutDateCheck(prospectId, campaignId, childLeadId);
       		System.assertEquals(2, actualResult.values.size(), 'prospectActivityFromCache method should return the correct number of values');
       		objHistories = ProspectActivityController.leadHistory(LeadID);
       		objHistories = ProspectActivityController.leadHistory(ConId);
        Test.stopTest();
    }
    


    @isTest static  void testProspectActivity_exception() {
        String prospectId = '000000000000001';
        String campaignId = '000000000000002';
        String childLeadId = '000000000000003';
        Integer statusCode = 500;
        String mockResponse = '{ "error": "An error occurred." }';
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse,statusCode));
            try {
                GetPardortProspectActivityWithCache.prospectActivity(prospectId, campaignId, childLeadId);
            } catch (Exception e) {
                System.assert(e.getMessage().contains('An error occurred.'), 'Unexpected exception message');
            }
        Test.stopTest();
    }
    
   
    
}