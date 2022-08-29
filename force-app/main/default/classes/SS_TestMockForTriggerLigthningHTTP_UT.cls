@isTest
public class SS_TestMockForTriggerLigthningHTTP_UT implements HttpCalloutMock{
    
    public HTTPResponse respond(HTTPRequest request){
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setStatus('Ok');
        response.setHeader('Content-Type', 'application/json');
        
        
        response.setBody('{"surveys":[{"id":588,"name":"Bitorder-testing NPS - 6","archived":false,"surveyType":"NPS","user_id":99,"updated_at":"2022-06-10T07:00:42.006Z"},{"id":379,"name":"Customer Satisfaction Survey","archived":false,"surveyType":"ClassicForm","user_id":99,"updated_at":"2022-06-07T15:15:34.670Z"},{"id":542,"name":"Customer Satisfaction Survey","archived":false,"surveyType":"ClassicForm","user_id":99,"updated_at":"2022-03-04T04:27:37.438Z"},{"id":724,"name":"Account Rating","archived":false,"surveyType":"ClassicForm","user_id":99,"updated_at":"2022-02-15T08:57:47.252Z"},{"id":763,"name":"New BOT Test","archived":false,"surveyType":"Conversational","user_id":99,"updated_at":"2022-02-11T11:51:41.620Z"},{"id":527,"name":"Bitorder-testing NPS - 4","archived":false,"surveyType":"NPS","user_id":99,"updated_at":"2022-02-09T08:48:18.599Z"},{"id":486,"name":"EmailSurvey","archived":false,"surveyType":"ClassicForm","user_id":99,"updated_at":"2022-02-09T08:48:14.763Z"}],"hasNextPage":false}');
        
        
        
        
        return response; 
    }
}