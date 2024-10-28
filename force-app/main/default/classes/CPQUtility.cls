/*------------------------------------------------------------
Author:        Author
Company:       Waeg
Description:   Helper methods for CPQ Project

History
2018-09-17     Michal Kwika   Created class
------------------------------------------------------------*/
public with sharing class CPQUtility {



    // CONSTANTS //
    public static final String  SHIP_TO = 'Ship To';
    public static final String  SOLD_TO = 'Sold To';
    public static final String  AGENT = 'Agent';

    public static final String  PRODUCT_RULE_NAME                		= 'Filter to Show Only Services';
    public static final String  PRODUCT_FEATURE_NAME             		= 'Services';
    public static final Integer PRODUCT_FEATURE_NUMBER           		= 999;
    public static final String  PRODUCT_FEATURE_CATEGORY         		= 'Services'; //'Transport';
    public static final String  PRODUCT_FEATURE_SELECTION_METHOD 		= 'Dynamic';
    public static final String  PRODUCT_FEATURE_SELECTION_METHOD_CLICK 	= 'Click';



    // METHODS //
    public static Map<Id, Partner_Role__c> getMapPartnerRolesByRelationNameIds(String relationName){
        Map<Id, Partner_Role__c> mPartnerRolesByIds = new Map<Id, Partner_Role__c>([SELECT Target_Account__c, External_Key__c, Source_Account__c
                                                                                    FROM Partner_Role__c
                                                                                    WHERE Relation_Name__c=:relationName]);
        return mPartnerRolesByIds;
    }

    public static Map<Id, Partner_Role__c> getMapPartnerRolesByRelationNameAndSourceIds(Set<Id> sSoldToIds, String relationName){
        Map<Id, Partner_Role__c> mPartnerRolesByIds = new Map<Id, Partner_Role__c>([SELECT Target_Account__c, External_Key__c, Source_Account__c
                                                                                    FROM Partner_Role__c
                                                                                    WHERE Relation_Name__c=:relationName
                                                                                    AND Source_Account__c IN :sSoldToIds]);
        return mPartnerRolesByIds;
    }

    public static Set<Id> getSetOfAllSoldTosForQuoteLineGroups(List<SBQQ__QuoteLineGroup__c> listQuoteLineGroups){
        Set<Id> sSoldToIds = new Set<Id>();
        if (listQuoteLineGroups!=null && listQuoteLineGroups.size()>0) {
            for(SBQQ__QuoteLineGroup__c qg: listQuoteLineGroups){
                sSoldToIds.add(qg.SBQQ__Account__c);
            }
        }

        return  sSoldToIds;
    }

	// Hugo Costa 2019/11/05 add generic map for metadata
	/*public static final Map<String,BatchSetting__mdt> DEFAULT_BATCH_SETTING;
	static {
            if (DEFAULT_BATCH_SETTING == null) {
                 List<BatchSetting__mdt> thisMetadataSettings = [Select	Id, 
																		DeveloperName,
																		BatchSize__c, 
																		BypassBatchApexErrorEventTrigger__c, 
																		Statuses__c, 
																		EmailTo__c, 
																		EmailCc__c, 
																		EmailBcc__c, 
																		EmailReplyTo__c,
																		DoNotSendEmail__c,
																		SendEmailOnErrorOnly__c, 
																		SendEmailAllOrNone__c, 
																		MaxErrorCount__c, 
																		MaxErrorCountEmail__c
																	FROM
																		BatchSetting__mdt];
                
				DEFAULT_BATCH_SETTING = new Map<String,BatchSetting__mdt>();

                for(BatchSetting__mdt thisMetadata : thisMetadataSettings){
                    DEFAULT_BATCH_SETTING.put(thisMetadata.DeveloperName,thisMetadata);
                }
		}
	}*/



}