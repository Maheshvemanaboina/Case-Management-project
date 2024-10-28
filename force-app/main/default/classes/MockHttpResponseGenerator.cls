@isTest
public class MockHttpResponseGenerator implements HttpCalloutMock {
    
    private String responseJSON;
    private Integer statusCode;
    private Map<String, String> responseHeaders;
    
    public MockHttpResponseGenerator(String responseJSON, Integer statusCode) {
        this.responseJSON = responseJSON;
        this.statusCode = statusCode;
    }
    
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(statusCode);
        response.setBody(responseJSON);
        return response;
    }
}