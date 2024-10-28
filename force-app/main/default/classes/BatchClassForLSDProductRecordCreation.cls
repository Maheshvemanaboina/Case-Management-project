/***************************************************************************************************
* Class Name   : BatchClassForLSDProductRecordCreation
* Created Date : August 6, 2020
* Author       : Sheshadri Pattar Srinivas
* Description  : Class to create LSD Product (Product Mirror) records for Existing Product Records
****************************************************************************************************/
global without sharing class BatchClassForLSDProductRecordCreation implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query=queryConstructor();
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<SObject> records){
        List<Product2> productList = (List<Product2>)records;
        List<LSD_Products_New__c> lsdProductList = new List<LSD_Products_New__c>();
        for(Product2 prod : productList){
            LSD_Products_New__c lsdPro = new LSD_Products_New__c();
            lsdPro.Parent_Product__c = prod.Id;
            lsdPro.Active__c = prod.IsActive;
                if(prod.DisplayUrl != null){
                    lsdPro.Display_URL__c = prod.DisplayUrl;
                }
                if(prod.ExternalId != null){
                    lsdPro.External_ID__c = prod.ExternalId;
                }
                if(prod.NumberOfQuantityInstallments != null){
                    lsdPro.Number_Of_Quantity_Installments__c = prod.NumberOfQuantityInstallments;
                }
                if(prod.ProductCode != null){
                    lsdPro.Product_Code__c = prod.ProductCode;
                }
                if(prod.CurrencyIsoCode != null){
                    lsdPro.CurrencyIsoCode = prod.CurrencyIsoCode;
                }
                if(prod.Description != null){
                    lsdPro.Product_Description__c = prod.Description;
                }
                if(prod.Name != null){
                    lsdPro.Name = prod.Name;
                }
                if(prod.StockKeepingUnit != null){
                    lsdPro.Product_SKU__c = prod.StockKeepingUnit;
                }
                if(prod.Application__c != null){
                    lsdPro.Application__c = prod.Application__c;
                }
                if(prod.Base_Unit_of_Measure__c != null){
                    lsdPro.Base_Unit_of_Measure__c = prod.Base_Unit_of_Measure__c;
                }
                if(prod.Brand_Segment_1__c != null){
                    lsdPro.Brand_Segment_1__c = prod.Brand_Segment_1__c;
                }
                if(prod.Brand_Segment_2__c != null){
                    lsdPro.Brand_Segment_2__c = prod.Brand_Segment_2__c;
                }
                if(prod.Brand_Segment_3__c != null){
                    lsdPro.Brand_Segment_3__c = prod.Brand_Segment_3__c;
                }
                if(prod.Business_Segment_Non_Restricted__c != null){
                    lsdPro.Business_Segment__c = prod.Business_Segment_Non_Restricted__c;
                }
                if(prod.Competitor__c != null){
                    lsdPro.Competitor__c = prod.Competitor__c;
                }
                if(prod.Expected_Close_Date__c != null){
                    lsdPro.Expected_Close_Date__c = prod.Expected_Close_Date__c;
                }
                if(prod.Expected_Completion_Date__c != null){
                    lsdPro.Expected_Completion_Date__c = prod.Expected_Completion_Date__c;
                }
                if(prod.Hierarchy_1__c != null){
                    lsdPro.Hierarchy_1__c = prod.Hierarchy_1__c;
                    if(prod.Hierarchy_2__c != null){
                        lsdPro.Hierarchy_2__c = prod.Hierarchy_2__c;
                        if(prod.Hierarchy_3__c != null){
                            lsdPro.Hierarchy_3__c = prod.Hierarchy_3__c;
                        }
                    }
                }
                if(prod.Hierarchy_4__c != null){
                    lsdPro.Hierarchy_4__c = prod.Hierarchy_4__c;
                }
                if(prod.Hierarchy_5__c != null){
                    lsdPro.Hierarchy_5__c = prod.Hierarchy_5__c;
                }
                if(prod.Hierarchy_6__c != null){
                    lsdPro.Hierarchy_6__c = prod.Hierarchy_6__c;
                }
                if(prod.Lead_Time__c != null){
                    lsdPro.Lead_Time__c = prod.Lead_Time__c;
                }
                if(prod.Market_Segment__c != null){
                    lsdPro.Market_Segment__c = prod.Market_Segment__c;
                }
                if(prod.Min_Remaining_Shelf_Live__c != null){
                    lsdPro.Min_Remaining_Shelf_Live__c = prod.Min_Remaining_Shelf_Live__c;
                }
                if(prod.Operating_Company_Non_Restricted__c != null){
                    lsdPro.Operating_Company__c = prod.Operating_Company_Non_Restricted__c;
                }
                if(prod.Pincipal_Toolbox__c != null){
                    lsdPro.Pincipal_Toolbox__c = prod.Pincipal_Toolbox__c;
                }
                if(prod.Principal_Toolbox_Name__c != null){
                    lsdPro.Principal_Toolbox_Name__c = prod.Principal_Toolbox_Name__c;
                }
                if(prod.Product_Code__c != null){
                    lsdPro.Product_Code1__c = prod.Product_Code__c;
                }
                if(prod.Product_Group__c != null){
                    lsdPro.Product_Group_OLD__c = prod.Product_Group__c;
                }
                if(prod.Product_Hierarchy_Code__c != null){
                    lsdPro.Product_Hierarchy_Code__c = prod.Product_Hierarchy_Code__c;
                }
                if(prod.Production_Location__c != null){
                    lsdPro.Production_Location__c = prod.Production_Location__c;
                }
                if(prod.Production_Plants__c != null){
                    lsdPro.Production_Plant_s__c = prod.Production_Plants__c;
                }
                if(prod.Product_Lead_Time__c != null){
                    lsdPro.Product_Lead_Time__c = prod.Product_Lead_Time__c;
                }
                if(prod.Product_Segment_1__c != null){
                    lsdPro.Product_Segment_1__c = prod.Product_Segment_1__c;
                }
                if(prod.Product_Segment_2__c != null){
                    lsdPro.Product_Segment_2__c = prod.Product_Segment_2__c;
                }
                if(prod.Product_Segment_3__c != null){
                    lsdPro.Product_Segment_3__c = prod.Product_Segment_3__c;
                }
                if(prod.Product_Segment_4__c != null){
                    lsdPro.Product_Segment_4__c = prod.Product_Segment_4__c;
                }
                if(prod.Project_Type__c != null){
                    lsdPro.Project_Type__c = prod.Project_Type__c;
                }
                if(prod.Region__c != null){
                    lsdPro.Region__c = prod.Region__c;
                }
                if(prod.Sales_Organization_Number__c != null){
                    lsdPro.Sales_Organization_Number__c = prod.Sales_Organization_Number__c;
                }
                if(prod.Sub_Segment__c != null){
                    lsdPro.Sub_Segment__c = prod.Sub_Segment__c;
                }
                if(prod.Total_Shelf_Live__c != null){
                    lsdPro.Total_Shelf_Live__c = prod.Total_Shelf_Live__c;
                }
                lsdProductList.add(lsdPro);
            
        }
        /*for(LSD_Products_New__c lsdPro : lsdProductList){
system.debug(lsdPro);
}*/
       if(lsdProductList.size()>0){
            insert lsdProductList;
        }
      
    }    
    global void finish(Database.BatchableContext bc){
        system.debug('finish');
    }    
    global static String queryConstructor(){
        List<String> productFiledList = new List<String>();
        String queryString = 'SELECT ';
        Map <String, Schema.SObjectType> schemaMapofAllSobject = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> MapofdesiredObject = schemaMapofAllSobject.get('Product2').getDescribe().fields.getMap();
        for(Schema.SObjectField sObjectfield : MapofdesiredObject.Values())
        {
            schema.describefieldresult dfield = sObjectfield.getDescribe();
            //system.debug('API Name : '  + dfield.getname());
            productFiledList.add(dfield.getname());
        }
        boolean firstField = true;
        for(String filedName : productFiledList){
            if(firstField){
                queryString = queryString + filedName;
                firstField = false;
            }
            else{
                queryString = queryString + ',' + filedName;
            }
            
        }
        queryString = queryString + ' FROM Product2 WHERE RecordType.Name=\'Product Group\'';
        return queryString;
        
    }
}