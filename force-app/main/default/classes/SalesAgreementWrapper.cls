public with sharing class SalesAgreementWrapper {
    public RecordDetails RecordSet {get;set;}

    public class RecordDetails {
        public List<SADetails> Request {get;set;}

        public RecordDetails(List<SADetails> Request) {
            this.Request = Request;
        }
    }

    public class SADetails {
        public String SAPOrderNumber {get;set;}
        public String SAPItemNumber {get;set;}
        public String DocumentCategory {get;set;}

        public SADetails(String SAPOrderNumber, String SAPItemNumber, String DocumentCategory) {
            this.SAPOrderNumber = SAPOrderNumber;
            this.SAPItemNumber = SAPItemNumber;
            this.DocumentCategory = DocumentCategory;
        }
    }
}