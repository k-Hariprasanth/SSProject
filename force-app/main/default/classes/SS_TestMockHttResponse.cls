@istest
public class SS_TestMockHttResponse  implements HttpCalloutMock{
    
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        response.setStatus('Ok');
        
        response.setBody('{"example":"test"}');
        return response; 
    }
}