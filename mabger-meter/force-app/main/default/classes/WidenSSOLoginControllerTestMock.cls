@IsTest
global class WidenSSOLoginControllerTestMock implements HttpCalloutMock {
    
    global HttpResponse respond (HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(302);
        response.setHeader('Location', '/dam/dashboard');

        return response;
    }

}