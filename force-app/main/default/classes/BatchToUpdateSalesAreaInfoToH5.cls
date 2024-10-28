/*       
@Name                  BatchToUpdateSalesAreaInfoToH5
@Author                vijay vardan reddy
@Version               1
@CreatedDate           21-04-2021
@UsedBy                
@Description        
@Changes
UserId           | Author-Email                         | Date                | Comment
================ |======================================|=====================|=========
*/

global without sharing class BatchToUpdateSalesAreaInfoToH5 implements Database.Batchable<sObject>,Schedulable  {
    
    public static map<string,map<string,string>> picklistEntryMap;
    global void execute(SchedulableContext sc) {
        BatchToUpdateSalesAreaInfoToH5 executeSalesAreaToAccount = new BatchToUpdateSalesAreaInfoToH5(); 
        database.executebatch(executeSalesAreaToAccount);
    }
    //Start method in the batch class
    global Database.QueryLocator start(Database.BatchableContext bc) {
        string H5RecType = system.label.Customer_H5_RecorType;
        //Query all the sales area with Business Segment is "Industry" and that are active 
        String query = 'SELECT id,Name,Sub_Segment__c,Active__c,Channel__c,Application_Group__c,Sales_Unit__c,';
        query = query+ '(SELECT Id,Business_Segment__c,Active__c,Customer_Name__c,Customer_Group__c, Customer_Group_1__c, Customer_Group_2__c, Sales_Group__c FROM Sales_Areas__r WHERE  Business_Segment__c = \'Industry\')';
        query = query+' FROM Account WHERE Active__c = true AND recordtype.developerName =: H5RecType';
        System.debug('******query******'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Account> batchrecords){
        
        system.debug('********records*********'+batchrecords);
        List<String> subSegmentValues = new List<String>();
        List<String> ApplicationGroupValues = new List<String>();
        List<String> ChannelValues = new List<String>();
        picklistEntryMap = new map<string,map<string,string>>();
        fieldToMap(subSegmentValues,'Sub_Segment__c','Account');
        fieldToMap(ApplicationGroupValues,'Application_Group__c','Account');
        fieldToMap(ChannelValues,'Channel__c','Account');
        list<account> acclist = new list<account>();
        for(Account acc:batchrecords){
            system.debug('acc'+acc);
            account newAcc = new account(id=acc.id,Sub_Segment__c=acc.Sub_Segment__c,Application_Group__c=acc.Application_Group__c,channel__c=acc.channel__c,Sales_Unit__c=acc.Sales_Unit__c);
            if(acc.Sales_Areas__r!=null){
                set<string> activeSubSeg = new set<string>();
                set<string> activeApplicationGroup = new set<string>();
                set<string> activechannels = new set<string>();
                set<string> activeUnits = new set<string>();
                    
                for(Sales_Area__c sa:acc.Sales_Areas__r){ 
                    system.debug('sa'+sa);
                    if(sa.Active__c){
                        System.debug('*****subSegmentValues******'+subSegmentValues);
                        System.debug('*****sa.Customer_Group_2__c******'+sa.Customer_Group_2__c);
                        
                          string cgrp2;
                          if(String.isNotBlank(sa.Customer_Group_2__c)){
                            cgrp2 = sa.Customer_Group_2__c;
                        }
                       /*   string cgrp2 = sa.Customer_Group_2__c;
                        if(String.isNotBlank(cgrp2)){
                            Integer result = cgrp2.indexOf(' ', 0);
                            integer slen = cgrp2.length();
                            cgrp2=cgrp2.substring(result+1,slen);
                        } */
                        if(String.isNotBlank(cgrp2) && 
                           picklistEntryMap.get('Sub_Segment__c')!=null &&
                           picklistEntryMap.get('Sub_Segment__c').get(cgrp2)!=null &&
                           subSegmentValues.contains(picklistEntryMap.get('Sub_Segment__c').get(cgrp2))){
                            activeSubSeg.add(sa.Customer_Group_2__c);
                            if(String.isBlank(newAcc.Sub_Segment__c)){
                                newAcc.Sub_Segment__c = picklistEntryMap.get('Sub_Segment__c').get(cgrp2);
                            } else if(!newAcc.Sub_Segment__c.contains(picklistEntryMap.get('Sub_Segment__c').get(cgrp2))){
                                newAcc.Sub_Segment__c = newAcc.Sub_Segment__c+';'+picklistEntryMap.get('Sub_Segment__c').get(cgrp2);
                            }  
                        }
                        
                         string cgrp1;
                          if(String.isNotBlank(sa.Customer_Group_1__c)){
                            cgrp1 = sa.Customer_Group_1__c;
                        }
                        /*string cgrp1 = sa.Customer_Group_1__c;
                        if(String.isNotBlank(cgrp1)){
                            Integer result = cgrp1.indexOf(' ', 0);
                            integer slen = cgrp1.length();
                            cgrp1=cgrp1.substring(result+1,slen); 
                        } */
                        if(String.isNotBlank(sa.Customer_Group_1__c) && 
                           picklistEntryMap.get('Application_Group__c')!=null &&
                           picklistEntryMap.get('Application_Group__c').get(cgrp1)!=null &&                           
                           ApplicationGroupValues.contains(picklistEntryMap.get('Application_Group__c').get(cgrp1))){
                               
                            activeApplicationGroup.add(sa.Customer_Group_1__c);
                            if(String.isBlank(newAcc.Application_Group__c)){
                                newAcc.Application_Group__c = picklistEntryMap.get('Application_Group__c').get(cgrp1);
                            } else if(!newAcc.Application_Group__c.contains(picklistEntryMap.get('Application_Group__c').get(cgrp1))){
                                newAcc.Application_Group__c = newAcc.Application_Group__c+';'+picklistEntryMap.get('Application_Group__c').get(cgrp1);
                            }  
                        }
                    
                          string cgrp;
                           if(String.isNotBlank(sa.Customer_Group__c)){
                            cgrp = sa.Customer_Group__c;
                        }
                       /* String cgrp = sa.Customer_Group__c;
                        if(String.isNotBlank(cgrp)){
                            Integer result = cgrp.indexOf(' ', 0);
                            integer slen = cgrp.length();
                            cgrp=cgrp.substring(result+1,slen); 
                        } */
                        if(String.isNotBlank(sa.Customer_Group__c) && 
                           picklistEntryMap.get('Channel__c')!=null &&
                           picklistEntryMap.get('Channel__c').get(cgrp)!=null &&
                           ChannelValues.contains(picklistEntryMap.get('Channel__c').get(cgrp))){
                            activechannels.add(sa.Customer_Group__c);
                            if(String.isBlank(newAcc.channel__c)){
                                newAcc.channel__c = picklistEntryMap.get('Channel__c').get(cgrp);
                            } else if(!newAcc.channel__c.contains(picklistEntryMap.get('Channel__c').get(cgrp))){
                                newAcc.channel__c = newAcc.channel__c+';'+picklistEntryMap.get('Channel__c').get(cgrp);
                            }  
                        }
                        
                        
                        if(String.isNotBlank(sa.Sales_Group__c)){
                            activeUnits.add(sa.Sales_Group__c);
                            if(string.isBlank(newAcc.Sales_Unit__c)){
                                newAcc.Sales_Unit__c=sa.Sales_Group__c;
                            } else if(!newAcc.Sales_Unit__c.contains(sa.Sales_Group__c)){
                                newAcc.Sales_Unit__c = newAcc.Sales_Unit__c+';'+sa.Sales_Group__c;
                            }
                        }
                        
                        
                        
                    } else{
                        
                        if(string.isNotBlank(sa.Sales_Group__c) && newAcc.Sales_Unit__c!=null &&!activeUnits.contains(sa.Sales_Group__c)&&  newAcc.Sales_Unit__c.contains(sa.Sales_Group__c) ){
                            list<string> subSegList = newAcc.Sales_Unit__c.split(';');
                            subSegList.remove(subSegList.indexOf(sa.Sales_Group__c));
                            newAcc.Sales_Unit__c = String.join(subSegList,';');
                        }
                        System.debug('******activechannels****'+activechannels);
                        System.debug('**********'+newAcc.Channel__c);
                         if(String.isNotBlank(sa.Customer_Group__c)){
                            sa.Customer_Group__c=sa.Customer_Group__c;
                        }
                       /* if(String.isNotBlank(sa.Customer_Group__c)){
                            Integer result = sa.Customer_Group__c.indexOf(' ', 0);
                            integer slen = sa.Customer_Group__c.length();
                            sa.Customer_Group__c=sa.Customer_Group__c.substring(result+1,slen);
                        } */
                        if(string.isNotBlank(sa.Customer_Group__c) && newAcc.Channel__c!=null && !activechannels.contains(sa.Customer_Group__c)&&  newAcc.Channel__c.contains(sa.Customer_Group__c) ){
                            string cgrp = sa.Customer_Group__c;
                            if(picklistEntryMap.get('Channel__c')!=null && picklistEntryMap.get('Channel__c').get(cgrp)!=null){
                                list<string> subSegList = newAcc.Channel__c.split(';');
                                subSegList.remove(subSegList.indexOf(picklistEntryMap.get('Channel__c').get(cgrp)));
                                System.debug('***subSegList****'+subSegList);
                                newAcc.Channel__c = String.join(subSegList,';');
                            }
                        }
                        System.debug('******newAcc.Channel__c*****'+newAcc.Channel__c);
                         if(String.isNotBlank(sa.Customer_Group_2__c)){
                            sa.Customer_Group_2__c=sa.Customer_Group_2__c;
                        }
                       /* if(String.isNotBlank(sa.Customer_Group_2__c)){
                            Integer result = sa.Customer_Group_2__c.indexOf(' ', 0);
                            integer slen = sa.Customer_Group_2__c.length();
                            sa.Customer_Group_2__c=sa.Customer_Group_2__c.substring(result+1,slen);
                        } */
                        if(string.isNotBlank(sa.Customer_Group_2__c) && newAcc.Sub_Segment__c!=null && !activeSubSeg.contains(sa.Customer_Group_2__c) && newAcc.Sub_Segment__c.contains(sa.Customer_Group_2__c)){
                            string cgrp2 = sa.Customer_Group_2__c;
                            if(picklistEntryMap.get('Sub_Segment__c')!=null && picklistEntryMap.get('Sub_Segment__c').get(cgrp2)!=null){
                                list<string> subSegList = newAcc.Sub_Segment__c.split(';');
                                System.debug('*******subSegList*******'+subSegList);
                                System.debug('*******sa.Customer_Group_2__c********'+sa.Customer_Group_2__c);
                                System.debug('*******subSegList.indexOf(sa.Customer_Group_2__c)*******'+subSegList.indexOf(picklistEntryMap.get('Sub_Segment__c').get(cgrp2)));
                                subSegList.remove(subSegList.indexOf(picklistEntryMap.get('Sub_Segment__c').get(cgrp2)));
                                newAcc.Sub_Segment__c = String.join(subSegList,';');
                            }
                        }
                         if(String.isNotBlank(sa.Customer_Group_1__c)){
                            sa.Customer_Group_1__c=sa.Customer_Group_1__c;
                        }
                       /* if(String.isNotBlank(sa.Customer_Group_1__c)){
                            Integer result = sa.Customer_Group_1__c.indexOf(' ', 0);
                            integer slen = sa.Customer_Group_1__c.length();
                            sa.Customer_Group_1__c=sa.Customer_Group_1__c.substring(result+1,slen);
                        } */
                         if(string.isNotBlank(sa.Customer_Group_1__c) && !activeApplicationGroup.contains(sa.Customer_Group_1__c) &&  newAcc.Application_Group__c!=null && newAcc.Application_Group__c.contains(sa.Customer_Group_1__c)){
                            
                            string cgrp3 = sa.Customer_Group_1__c;
                             System.debug('********cgrp3*******'+cgrp3);
                             System.debug('*****app group val***'+picklistEntryMap.get('Application_Group__c').get(cgrp3)); 
                            if(picklistEntryMap.get('Application_Group__c')!=null && picklistEntryMap.get('Application_Group__c').get(cgrp3)!=null){
                                list<string> subSegList = newAcc.Application_Group__c.split(';');
                                subSegList.remove(subSegList.indexOf(picklistEntryMap.get('Application_Group__c').get(cgrp3)));
                                newAcc.Application_Group__c = String.join(subSegList,';');
                            }
                             
                            
                        }
                    }
                    
                }
                system.debug('newAcc'+newAcc);
                System.debug('******new channel*******'+newAcc.channel__c);
                System.debug('******old channel*******'+Acc.channel__c);
                if(newAcc.Sub_Segment__c != acc.Sub_Segment__c||newAcc.Application_Group__c != acc.Application_Group__c || newAcc.channel__c != acc.Channel__c||newAcc.Sales_Unit__c != acc.Sales_Unit__c){
                      
                    acclist.add(newAcc);    
                }
            }
        }
        System.debug('acclist'+acclist);
        if(!acclist.isEmpty()){
            update acclist;
        }
    
    }
    
    global void finish(Database.BatchableContext bc){
    } 
    
    
    private void fieldToMap(List<String> listOfString , String fieldApiName,String ObjectApiName){
        Schema.SObjectType s = Schema.getGlobalDescribe().get(ObjectApiName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldApiName).getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : picklistValues){
            string sval = pickListVal.getValue();
            string slab = pickListVal.getLabel();
            listOfString.add(sval);
            
            if(picklistEntryMap.get(fieldApiName)!=null ){
                map<string,string> tempMap = picklistEntryMap.get(fieldApiName);
                tempMap.put(slab,sval);
                picklistEntryMap.put(fieldApiName,tempMap);
            } else{
                picklistEntryMap.put(fieldApiName,new map<string,string>{slab=>sval});
            }
        } 
    }
}