public with sharing class VolumeResponseWrapper {
    public RecordDetails RecordSet {get;set;}

    public class RecordDetails {
        public String APIRuntimeResponse {get;set;}
        public String APIRuntimeResponseDesc {get;set;}
        public List<ResponseDetails> Response {get;set;}

//        public RecordDetails(List<SADetails> Response) {
//            this.Response = Response;
//        }
    }

    public class ResponseDetails {
        public String SAPResponse {get;set;}
        public String SAPResponseDesc {get;set;}
        public String SAPOrderNumber {get;set;}
        public String HeaderStatus {get;set;}
        public String HeaderEstimatedDeliveryDate {get;set;}
        public String ContractHeaderStatus {get;set;}
        public List<ItemDetails> Item {get;set;}
    }

    public class ItemDetails {
        public String ItemNumber {get;set;}
        public String ItemStatus {get;set;}
        public String ItemEstimatedDeliveryDate {get;set;}
        public String ItemDeliveryQty {get;set;}
        public String ItemOrderedQty {get;set;}
    }
}