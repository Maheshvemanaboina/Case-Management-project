/* Created By : KVP- Surya Priya.S
* Name : DataSharingWrapper
* Created on : 18 Feb 2021
* Modified on: 25 June 2021
* Description : Test class to send data to the COE Multi Org.
*/
@isTest
public class DataSharingWithMultiOrgTest {
    @isTest
    public static void getData(){
        
       RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/OrgData';
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        DataSharingWithMultiOrg.fetchOrgData();
        Test.stopTest();
       
    }
    
}