public without sharing class RecursionHandler{
    
    //Variables
    public static Boolean isRecursiveCallInsert = false; 
    public static Boolean isRecursiveCallUpdate = false;
    public static boolean isAttachmentInsertInCaseOrExp = false;
    public static boolean isEmailSendToAccountQueue = false;
    public static boolean isQualifiedProspectSentToSAP = false;
    
    
    //Used for Case(Renamed to : Customer Request) trigger recursion handling
    public static Boolean isvisitreportAfterinsertRecursive  = false;
    
    //Used for CaseTriggerHandler
    public static boolean isAfterCaseUpdate = false;

    //Used for PurchaseOrderHandler
    public static boolean isAfterPurchaseUpdate = false;
    
    //Used for AccountRecursion Handler
    public static boolean isAfterUpdateAccountRecursive = false;
    
    //Used for AccountMirrorRecursionHandler
    public static boolean isAfterUpdateAccountMirror = false;
    
    //Used for ContactRecursionHandler
    public static boolean isAfterContactUpdate = false;
    
    //Used for AccountMirrorUpdate and recursion to again update Account
    public static boolean isAfterAccountMirrorUpdateRecursive = false;

    //Used for AccountTeamMember After update Recursion
    public static boolean isAccountTeamMemberAfterUpdateRecursive = false;
    
    //Used for Lead After update Recursion
    public static boolean isLeadAfterUpdateRecursive = false;
    
    //Used for Lead  Trigger After update Recursion
    public static boolean isLeadTrigAfterUpdateRecursive = false;
    
     //Used for Account  Trigger After update Recursion
    public static boolean isAccountTrigAfterUpdateRecursive = false;
    
      //Used for Account  Trigger After update Recursion
    public static boolean isAccountUpdateOwnerTrigAfterUpdateRecursive = false;
    
    //Used for Partner Role Trigger After update Recursion
	public static boolean inFutureContext = false;
    public static set<id> receivedPartnerRoleRecords = new set<id>();
    
    //Used for Partner Role Trigger After Update Recursion when upsert operation performed from SAP
    public static boolean isPartnerRoleRecalculationAfterUpdateRecursive = false;
    
    //Used to hold all the partner role records sent from SAP upsert operation
    public static Map<Id, Id> receivedPartnerRoleRecordsSourceAccountMap = new Map<Id, Id>();
    
    //Used to identify whether the partner role trigger after update event is running first time or not
    public static Boolean afterUpdateFirstRun = true;
}