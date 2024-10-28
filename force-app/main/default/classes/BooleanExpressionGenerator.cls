/***************************************************************************************************
* Class Name   : BooleanExpressionGenerator
* Created Date : November 2, 2019
* Author       : Sibananda Bhuyan
* Description  : Class to generate a boolean expression in AND OR Format
****************************************************************************************************/
public without sharing class BooleanExpressionGenerator {

    //start = $ and end = @
    public static String eval(String expression){
        While(expression.contains('(')){
            String comparisionOperator = expression.substringBeforeLast('(').right(3).trim();
            expression = returnExprVal(comparisionOperator,expression);
        }
        expression = expression.replace('$', '(');
        expression = expression.replace('@', ')');
        System.debug('expresssion --> '+expression);
        return expression;
    }
    
    private static String returnExprVal(String comparisionOperator,String expression){
        String intermittentexpr = '';
        if(comparisionOperator.contains('OR')){
            String exprORStr = expression.substringAfterLast('(').substringBefore(')');
            String strToReplace = 'OR' + '(' + exprORStr + ')';
            List<String> exprORStrList = exprORStr.split(',');
            intermittentexpr = intermittentexpr + '$';
            for(String str : exprORStrList){
                intermittentexpr = intermittentexpr + str + ' OR ';
            }
            intermittentexpr = intermittentexpr.substringBeforeLast('OR').trim() + '@';
            expression = expression.replace(strToReplace, intermittentexpr);
            intermittentexpr = '';
        }
        else if(comparisionOperator.contains('AND')){
            String exprORStr = expression.substringAfterLast('(').substringBefore(')');
            String strToReplace = 'AND' + '(' + exprORStr + ')';
            List<String> exprORStrList = exprORStr.split(',');
            intermittentexpr = intermittentexpr + '$';
            for(String str : exprORStrList){
                intermittentexpr = intermittentexpr + str + ' AND ';
            }
            intermittentexpr = intermittentexpr.substringBeforeLast('AND').trim() + '@';
            expression = expression.replace(strToReplace, intermittentexpr);
            intermittentexpr = '';
        }
        else{
            expression = expression.replace('(', '$');
            expression = expression.replace(')', '@');
        }
        return expression;
    }
}