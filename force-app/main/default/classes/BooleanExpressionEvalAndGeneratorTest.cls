/***************************************************************************************************
* Class Name   : BooleanExpressionEvalAndGeneratorTest
* Created Date : November 3, 2019
* Author       : Sibananda Bhuyan
* Description  : Test Class for BooleanExpressionEvaluation and BooleanExpressionGenerator Class
****************************************************************************************************/
@isTest
public class BooleanExpressionEvalAndGeneratorTest {
    
    @isTest
    static void eval_test() {
        System.assert(BooleanExpressionEvaluation.eval('TRUE'));
        System.assert(BooleanExpressionEvaluation.eval('TRUE OR FALSE'));
        System.assert(BooleanExpressionEvaluation.eval('TRUE OR TRUE'));
        System.assert(BooleanExpressionEvaluation.eval('TRUE OR (TRUE AND FALSE)'));
        System.assert(BooleanExpressionEvaluation.eval('TRUE OR (TRUE AND FALSE AND TRUE OR TRUE)'));
        System.assert(BooleanExpressionEvaluation.eval('TRUE OR (TRUE AND FALSE AND (TRUE OR FALSE))'));
        System.assert(BooleanExpressionEvaluation.eval('TRUE OR (TRUE OR (FALSE AND (TRUE OR FALSE)))'));
        System.assert(BooleanExpressionEvaluation.eval('(FALSE OR ((TRUE OR FALSE) AND (TRUE OR FALSE)))'));
        
        System.assert(!BooleanExpressionEvaluation.eval('FALSE'));
        System.assert(!BooleanExpressionEvaluation.eval('TRUE AND FALSE'));
        System.assert(!BooleanExpressionEvaluation.eval('FALSE AND FALSE'));
        System.assert(!BooleanExpressionEvaluation.eval('TRUE AND (TRUE AND FALSE)'));
        System.assert(!BooleanExpressionEvaluation.eval('FALSE AND (TRUE AND FALSE AND TRUE OR TRUE)'));
        System.assert(!BooleanExpressionEvaluation.eval('TRUE AND (TRUE AND FALSE AND (TRUE OR FALSE))'));
        System.assert(!BooleanExpressionEvaluation.eval('TRUE AND (TRUE AND (FALSE AND (TRUE OR FALSE)))'));
        System.assert(!BooleanExpressionEvaluation.eval('(FALSE AND ((TRUE OR FALSE) AND (TRUE OR FALSE)))'));
    }

    @isTest
    static void generatorTest(){
        String strToGenerateBooleanExpression = 'AND(Total_Net_Sales_Value__c,Standard_Liability__c,FC_Legal_Entity__c,OR(Aggregate_Liability_Cap_Amount_EUR__c,Liability_Cap_Per_Year_EUR__c))';
        String booleanExpr = BooleanExpressionGenerator.eval(strToGenerateBooleanExpression);
        System.assertEquals('(Total_Net_Sales_Value__c AND Standard_Liability__c AND FC_Legal_Entity__c AND (Aggregate_Liability_Cap_Amount_EUR__c OR Liability_Cap_Per_Year_EUR__c))', booleanExpr);
    }
}