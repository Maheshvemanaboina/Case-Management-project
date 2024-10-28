public without sharing class SCAFMessageController {
    
    @AuraEnabled
    public static List<WrapperClass> getMessageCount(String recordId){
        List<WrapperClass> abc = new List<WrapperClass>();
        List<WrapperClass> FinalList = new List<WrapperClass>();
        SCAF__c scf = [Select id,MessageCount__c,Initial_Term_of_LSD_In_Months__c,SCAF_Approval_Status__c from SCAF__c where id=:recordId];
        /*if((scf.MessageCount__c == 0 || scf.MessageCount__c == 1) && scf.Initial_Term_of_LSD_In_Months__c >= 60 && scf.Period_of_Exclusive_off_take_by_Customer__c=='Yes'){
            scf.MessageCount__c = scf.MessageCount__c + 1;
            update scf;
        }
        /*else if(scf.MessageCount__c == null && scf.Initial_Term_of_LSD_In_Months__c >= 60 && scf.Period_of_Exclusive_off_take_by_Customer__c=='Yes'){
            scf.MessageCount__c = 1;
            update scf;
        }*/
        WrapperClass ab = new WrapperClass();
        ab.msgCount = scf.MessageCount__c;
        //ab.ExclusiveOffTake = scf.Period_of_Exclusive_off_take_by_Customer__c;
        if(scf.SCAF_Approval_Status__c == 'Draft'){
            ab.isTemplateDeviation = true;
            ab.StatusValue = 'Review SCAF and Submit Approval';
            ab.TemplateDeviationMSG = 'New SCAF is created, please review it and use "Submit for Approval" button to submit it for Approval.';
        }else{
            ab.isTemplateDeviation = false;
        }
        abc.add(ab);
        System.debug('ab --> '+ab);
        if(!abc.isEmpty()){
            for(WrapperClass wr : abc){
                finallist.add(wr);
            }
        }
        return finallist;
    }
    public class WrapperClass{
        @AuraEnabled public decimal msgCount;
        
        @AuraEnabled
        public String ExclusiveOffTake;
        @AuraEnabled
        public Boolean isTemplateDeviation {get;set;}
        @AuraEnabled
        public String TemplateDeviationMSG {get;set;}
        @AuraEnabled
        public String StatusValue {get;set;}
    }
}