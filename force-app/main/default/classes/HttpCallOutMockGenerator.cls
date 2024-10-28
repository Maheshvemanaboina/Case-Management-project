global without sharing class HttpCallOutMockGenerator implements HttpCallOutMock {
    
    private Map<String,String> httpHeader;
    private String httpBody;
    private String httpStatus;
    private Integer httpStatusCode;

    global HttpCallOutMockGenerator(Map<String,String> httpHeader,String HttpBody,String HttpStatus,Integer HttpStatusCode) {
        
        this.httpHeader = httpHeader;
        this.httpBody = httpBody;
        this.httpStatus = httpStatus;
        this.httpStatusCode = httpStatusCode;
    }

    global HttpResponse respond(HttpRequest request){
        HttpResponse res = new HttpResponse();
        //res.setHeader(key, value);
        res.setBody(httpBody);
        res.setStatusCode(httpStatusCode);
        res.setStatus(httpStatus);
        return res;
    }
}