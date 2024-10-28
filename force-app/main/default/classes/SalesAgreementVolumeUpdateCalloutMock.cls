global class SalesAgreementVolumeUpdateCalloutMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest request) {

        String strResponse = '{\n' +
                '    "RecordSet": {\n' +
                '        "APIRuntimeResponse": "Success",\n' +
                '        "APIRuntimeResponseDesc": "Success",\n' +
                '        "Response": [\n' +
                '            {\n' +
                '                "SAPResponse": "Success",\n' +
                '                "SAPResponseDesc": "Sales order exists",\n' +
                '                "SAPOrderNumber": "000123",\n' +
                '                "HeaderStatus": "READY FOR TRANSPORT",\n' +
                '                "HeaderEstimatedDeliveryDate": "2018/01/05",\n' +
                '                "Item": [\n' +
                '                    {\n' +
                '                        "ItemNumber": "000010",\n' +
                '                        "ItemStatus": "READY FOR TRANSPORT",\n' +
                '                        "ItemEstimatedDeliveryDate": "2018/01/05",\n' +
                '                        "ItemDeliveryQty": "8"\n' +
                '                    },\n' +
                '                    {\n' +
                '                        "ItemNumber": "000020",\n' +
                '                        "ItemStatus": "READY FOR TRANSPORT",\n' +
                '                        "ItemEstimatedDeliveryDate": "2018/01/05",\n' +
                '                        "ItemDeliveryQty": "8"\n' +
                '                    }\n' +
                '                ]\n' +
                '            }\n' +
                '        ]\n' +
                '    }\n' +
                '}';

        HttpResponse response = new HttpResponse();

        response.setHeader('Content-Type', 'application/json');
        response.setBody(strResponse);
        response.setStatusCode(200);
        return response;
    }

}