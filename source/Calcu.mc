//Prefix and postfix notations are evaluated with stack machine.

using Toybox.Lang;
using Toybox.System;
using Toybox.Math;


class Calc {
	// returns if character is a digit
	function isDigit(token) {
		return token.equals("0") or token.equals("1") or token.equals("2") or
		       token.equals("3") or token.equals("4") or token.equals("5") or
		       token.equals("6") or token.equals("7") or token.equals("8") or token.equals("9");
	}
	
	
	// same as isDigit but includes "." too
	function isDigitPlus(token) {
		return Calc.isDigit(token) or token.equals(".") or token.equals("-");
	}
	function formatNumber(str) {
		if (str.equals(".")) { return "0.0"; }
		if (str.substring(0,1).equals(".")) { return "0" + str; }
		return str;
	}
	function isBinaryOPExceptMinus(token) {
		return token.equals("+") or token.equals("*") or token.equals("/")
		     or token.equals("^") or token.equals("log");
	}
	function isUnaryOPExceptMinus(token) {
		return token.equals("sqrt") or token.equals("sin") or token.equals("cos")
		     or token.equals("tan") or token.equals("asin") or token.equals("acos")
		     or token.equals("atan") or token.equals("ln") or token.equals("lg")
		     or token.equals("raddeg") or token.equals("degrad");
	}
	
	
	// evaluates prefix notation expression
	function eval(tokens) {
		var stack = [];
		for (var i = 0; i < tokens.size(); i += 1){
		    var token = tokens[tokens.size() - i - 1];
		    
		    // binary operators
		    if (Calc.isBinaryOPExceptMinus(token) or token.equals("-")) {
		        if (stack.size() < 2) { return "-"; }
		    	var pop = stack[stack.size()-1];
		    	
			    if (token.equals("+")) {
			        stack[stack.size()-2] = stack[stack.size()-2] + pop;
			    }
			    if (token.equals("-")) {
			        stack[stack.size()-2] = pop - stack[stack.size()-2];
			    }
			    if (token.equals("*")) {
			        stack[stack.size()-2] = stack[stack.size()-2] * pop;
			    }
			    if (token.equals("/")) {
			    	if (stack[stack.size()-2] == 0) {
		        		stack[stack.size()-2] = NaN;
		        	} else {
		        		stack[stack.size()-2] = (1.0 * pop) / stack[stack.size()-2];
		            }
			    }
			    if (token.equals("^")) {
			        stack[stack.size()-2] = Math.pow(pop, stack[stack.size()-2]);
			    }
			    if (token.equals("log")) {
			        stack[stack.size()-2] = Math.log(stack[stack.size()-2], pop);
			    }
			    
		        stack = stack.slice(null, stack.size() - 1);
		        continue;
			}
			
			// unary operators
		    if (Calc.isUnaryOPExceptMinus(token) or token.equals("(-)")) {
		        if (stack.size() < 1) { return "-"; }
			    if (token.equals("(-)")) {
			        stack[stack.size()-1] *= -1;}
			    if (token.equals("sqrt")) {
			        stack[stack.size()-1] = Math.sqrt(stack[stack.size()-1]);}
			    if (token.equals("sin")) {
			        stack[stack.size()-1] = Math.sin(stack[stack.size()-1]);}
			    if (token.equals("cos")) {
			        stack[stack.size()-1] = Math.cos(stack[stack.size()-1]);}
			    if (token.equals("tan")) {
			        stack[stack.size()-1] = Math.tan(stack[stack.size()-1]);}
			    if (token.equals("asin")) {
			        stack[stack.size()-1] = Math.asin(stack[stack.size()-1]);}
			    if (token.equals("acos")) {
			        stack[stack.size()-1] = Math.acos(stack[stack.size()-1]);}
			    if (token.equals("atan")) {
			        stack[stack.size()-1] = Math.atan(stack[stack.size()-1]);}
			    if (token.equals("ln")) {
			        stack[stack.size()-1] = Math.log(stack[stack.size()-1], 2.71828);}
			    if (token.equals("lg")) {
			        stack[stack.size()-1] = Math.log(stack[stack.size()-1], 10);}
			    if (token.equals("raddeg")) {
			        stack[stack.size()-1] = stack[stack.size()-1] / (2 * 3.141565) * 360;}
			    if (token.equals("degrad")) {
			        stack[stack.size()-1] = stack[stack.size()-1] * (2 * 3.141565) / 360;}
			    continue;
			}
		
		    if (token.equals("e")) {
		    	var e = 2.71828;
		        stack.add(e);
		        continue;
		    }
		    if (token.equals("pi")) {
		    	var pi = 3.141565;
		        stack.add(pi);
		        continue;
		    }
		
		    var integer = null;
		    var real = null;
		    var pureInteger = true;
		    
			for (var j = 0; j < token.length(); j += 1) {
				if (token.substring(j, j+1).equals(".")) {
					pureInteger = false;
				}
			}
			if (Calc.isDigitPlus(token.substring(0,1))) {
				if (pureInteger) {
			    	var apiVersion = System.getDeviceSettings().monkeyVersion;
			    	// from API level 3.1.0 is the toLong supported
					if (apiVersion[0] >= 3 and apiVersion[1] >= 1) {
						integer = token.toLong(); // 64 bit
					} else {
						integer = token.toNumber().toLong(); // 32 bit
					}
					stack.add(integer);
				} else {
					var formattedToken = Calc.formatNumber(token);
					real = formattedToken.toFloat();
					stack.add(real);
				}
			}			
		}
		
		if (stack.size() == 1) {
			if (stack[0] > Math.pow(10, 12) or stack[0] < -Math.pow(10, 12)) {
				return stack[0].format("%.7E");
			} else {
				return stack[0].toString();
			}
		} else {
			return "-";
		}
	}
	
	
	// evaluates postfix notation expression
	function evalPost(tokens) {
		var stack = [];
		if (tokens.size() == 0) {
			return "-";
		}
		for (var i = 0; i < tokens.size(); i += 1){
		    var token = tokens[i];
		    
		    // binary operators
		    if (Calc.isBinaryOPExceptMinus(token) or token.equals("-")) {
		        if (stack.size() < 2) { return "-"; }
		    	var pop = stack[stack.size()-1];
		    	
			    if (token.equals("+")) {
			        stack[stack.size()-2] = stack[stack.size()-2] + pop;
			    }
			    if (token.equals("-")) {
			        stack[stack.size()-2] = stack[stack.size()-2] - pop;
			    }
			    if (token.equals("*")) {
			        stack[stack.size()-2] = stack[stack.size()-2] * pop;
			    }
			    if (token.equals("/")) {
			    	if (stack[stack.size()-1] == 0) {
		        		stack[stack.size()-2] = NaN;
		        	} else {
		        		stack[stack.size()-2] = (1.0 * stack[stack.size()-2]) / pop;
		            }
			    }
			    if (token.equals("^")) {
			        stack[stack.size()-2] = Math.pow(stack[stack.size()-2], pop);
			    }
			    if (token.equals("log")) {
			        stack[stack.size()-2] = Math.log(pop, stack[stack.size()-2]);
			    }
			    
		        stack = stack.slice(null, stack.size() - 1);
		        continue;
			}
			
			// unary operators
		    if (Calc.isUnaryOPExceptMinus(token) or token.equals("(-)")) {
		        if (stack.size() < 1) { return "-"; }
			    if (token.equals("(-)")) {
			        stack[stack.size()-1] *= -1;}
			    if (token.equals("sqrt")) {
			        stack[stack.size()-1] = Math.sqrt(stack[stack.size()-1]);}
			    if (token.equals("sin")) {
			        stack[stack.size()-1] = Math.sin(stack[stack.size()-1]);}
			    if (token.equals("cos")) {
			        stack[stack.size()-1] = Math.cos(stack[stack.size()-1]);}
			    if (token.equals("tan")) {
			        stack[stack.size()-1] = Math.tan(stack[stack.size()-1]);}
			    if (token.equals("asin")) {
			        stack[stack.size()-1] = Math.asin(stack[stack.size()-1]);}
			    if (token.equals("acos")) {
			        stack[stack.size()-1] = Math.acos(stack[stack.size()-1]);}
			    if (token.equals("atan")) {
			        stack[stack.size()-1] = Math.atan(stack[stack.size()-1]);}
			    if (token.equals("ln")) {
			        stack[stack.size()-1] = Math.log(stack[stack.size()-1], 2.71828);}
			    if (token.equals("lg")) {
			        stack[stack.size()-1] = Math.log(stack[stack.size()-1], 10);}
			    if (token.equals("raddeg")) {
			        stack[stack.size()-1] = stack[stack.size()-1] / (2 * 3.141565) * 360;}
			    if (token.equals("degrad")) {
			        stack[stack.size()-1] = stack[stack.size()-1] * (2 * 3.141565) / 360;}
			    continue;
			}
		
		    if (token.equals("e")) {
		    	var e = 2.71828;
		        stack.add(e);
		        continue;
		    }
		    if (token.equals("pi")) {
		    	var pi = 3.141565;
		        stack.add(pi);
		        continue;
		    }

		    var integer = null;
		    var real = null;
		    var pureInteger = true;
			for (var j = 0; j < token.length(); j += 1) {
				if (token.substring(j, j+1).equals(".")) {
					pureInteger = false;
				}
			}
			if (Calc.isDigitPlus(token.substring(0,1))) {
				if (pureInteger) {
			    	var apiVersion = System.getDeviceSettings().monkeyVersion;
			    	// from API level 3.1.0 is the toLong supported
					if (apiVersion[0] >= 3 and apiVersion[1] >= 1) {
						integer = token.toLong(); // 64 bit
					} else {
						integer = token.toNumber().toLong(); // 32 bit
					}
					stack.add(integer);
				} else {
					var formattedToken = Calc.formatNumber(token);
					real = formattedToken.toFloat();
					stack.add(real);
				}
			}			
		}
		
		if (stack.size() == 1) {
			if (stack[0] > Math.pow(10, 12) or stack[0] < -Math.pow(10, 12)) {
				return stack[0].format("%.7E");
			} else {
				return stack[0].toString();
			}
		} else {
			return "-";
		}
	}
	
	function dealWithUnaryMinus(tokens) {
		var result = tokens;
		var tmp;
		if (tokens[0].equals("-")) {
			tmp = ["0"];
			tmp.addAll(result);
			result = tmp;
		}
		var length;
		while (true) {
			length = result.size();
			for (var i = 1; i < result.size(); i += 1){
				if (result[i-1].equals("(") and result[i].equals("-")) {
					tmp = result.slice(0, i);
					tmp.add("0");
					tmp.addAll(result.slice(i, null));
					result = tmp;
				}
				if (Calc.isBinaryOPExceptMinus(result[i-1]) and result[i].equals("-")) {
					tmp = result.slice(0, i);
					tmp.add("0");
					tmp.addAll(result.slice(i, null));
					result = tmp;
				}
				
			}
			if (result.size() == length) {
				return result;
			}
		}
	}
	
//	function bracketPairCriterium(tokens) {
//		leftBr = 0;
//		rightBr = 0;
//		for (var i=0; i<tokens.size(); i += 1) {
//			if tokens.equals(")") {
//				add
//			}
//		}
//	}
	
	function evalInfix(tokens) {
		if (tokens.size() == 0) {
			return "-";
		}
		var op_stack = [];
		var out_queue = [];
		var pop = "";
		var PRECEDENCE = { "+" => 1, "-" => 1, "*" => 2, "/" => 2, "^" => 3, "log" => 4, "(" => -1, ")" => -1 };
		tokens = Calc.dealWithUnaryMinus(tokens);
		for (var i = 0; i < tokens.size(); i += 1){
		    var token = tokens[i];
		    
		    if (Calc.isUnaryOPExceptMinus(token)) {
		    	op_stack.add(token);
		    }
		    else if (Calc.isBinaryOPExceptMinus(token) or token.equals("-")) {
		    	while (op_stack.size() > 0 and !Calc.isUnaryOPExceptMinus(op_stack[op_stack.size()-1]) and PRECEDENCE[op_stack[op_stack.size()-1]] >= PRECEDENCE[token]) {
		    		pop = op_stack[op_stack.size()-1];
		    		op_stack = op_stack.slice(0, op_stack.size()-1);
		    		out_queue.add(pop);
		    	}
		    	op_stack.add(token);
		    }
		    else if (token.equals("(")) {
		    	op_stack.add(token);
		    }
		    else if (token.equals(")")) {
	    		if (op_stack.size() == 0) {
	    			return "-";
	    		}
		    	while (!op_stack[op_stack.size()-1].equals("(")) {
		    		pop = op_stack[op_stack.size()-1];
		    		op_stack = op_stack.slice(0, op_stack.size()-1);
		    		out_queue.add(pop);
		    		if (op_stack.size() == 0) {
		    			break;
		    		}
		    	}
	    		op_stack = op_stack.slice(0, op_stack.size()-1); // pop left parenthesis
		    	if (op_stack.size() > 0 and Calc.isUnaryOPExceptMinus(op_stack[op_stack.size()-1])) {
		    		pop = op_stack[op_stack.size()-1];
		    		op_stack = op_stack.slice(0, op_stack.size()-1);
		    		out_queue.add(pop);
		    	}
		    }
		    else if (Calc.isDigitPlus(token.substring(0,1)) or token.equals("e") or token.equals("pi")) {
					out_queue.add(token);
		    }
		}
		
		while (op_stack.size() > 0) {
    		pop = op_stack[op_stack.size()-1];
    		op_stack = op_stack.slice(0, op_stack.size()-1);
		
			if (pop.equals("(")) {
		    	return "-";
		    }
		    if (!pop.equals(")")) {
	    		out_queue.add(pop);
	    	}
			
		}
		return Calc.evalPost(out_queue);
	}
	
	function evalRpnStack(tokens) {
		var returnList = [];
		returnList.addAll(tokens);
		if (tokens.size() < 2) {
			return returnList;
		}
		for (var i=2; i <= 3; i++) {
			if (i == 3 and tokens.size() < 3){
				return returnList;
			}
			var tokenSlice = tokens.slice(tokens.size()-i, tokens.size());
			var evalEnd = Calc.evalPost(tokenSlice);
			if (!evalEnd.equals("-")) {
				returnList = tokens.slice(0, tokens.size()-i+1);
				returnList[returnList.size()-1] = evalEnd;
				System.println(returnList);
				return returnList;
			}
		}
		return returnList;
	}
}





