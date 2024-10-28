public without sharing class projectPlanningController {
    
    Public List<Project__c> listOfProj{get;set;}
    public  id proid{get;set;}
    public Project__c pro{get;set;}
    Public boolean editmode{get;set;}
    

    public projectPlanningController(ApexPages.StandardController controller) {
         this.pro=(Project__c)controller.getrecord();
         proid = ApexPages.currentPage().getParameters().get('id');
         listOfProj  = new List<Project__c>();       

         
         fetchMydtpList();
    }
    
    public void fetchMydtpList(){
        listOfProj = new List<Project__c>([SELECT id, Name, Original_Plan_start_date__c,Original_Plan_Viability_Gate__c,Original_Plan_Feasibility_Gate__c,Original_Plan_Launch_gate__c,Original_Plan_Launch_Date__c,Original_Plan_Project_Closure__c,
                                            Project_Start_Date_from_Gantt__c,Viability_gate_from_gantt__c,Feasibility_Gate_from_Gantt__c,Launch_Gate_from_gantt__c,Project_Closure_date_from_gantt__c,
                                            Realised_and_Actual_Plan_Start_date__c, Realised_and_Actual_Viability_Gate__c, Realised_and_actual_plan_feasibilty_gate__c, Realised_and_actual_launch_gate__c, Realised_and_actual_plan_launch_date__c,Realised_and_actual_Project_closure__c, 
                                            Start_Date_Gate_Decision_approved__c, Gate_Decision_approved_in_Viability_Gate__c, Feasibilty_gate_decision_approved__c,Launch_gate_decision_approved__c,Launch_Date_Decision_approved__c , Project_closure_decision_approved__c,
                                            Start_Date_decision_approved__c, Gate_decision_approval_date_VG__c, Feasibilty_gate_decision_approval_date__c, Launch_gate_decision_approval_date__c, Launch_Date_decision_approval_date__c, Project_closure_decision_approval_date__c,Commercial_launch_date_from_Gantt__c,
                                           Commercial_launch_date_from_R_A_Project__c,Commercial_launch_date_from_Gate_Decison__c,Commercial_Launch_Gate_Decision_Approval__c,Commercial_Launch_Date__c
                                           FROM Project__c WHERE Id =: proid]);

        
        }
        
    public void save(){
        editmode = true;
        update pro;
    }  

}