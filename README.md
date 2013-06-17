XIRR Calculator
===============

Calculates Internal Rate of Return for a list of irregular cashflows.
Uses Newton's method to approximate solution to a target error level.
  
Usage:
XIRR myXIRR = new XIRR();
myXIRR.addCashflow(Date.newInstance(2012, 1, 1), 1500.0);
myXIRR.addCashflow(Date.newInstance(2012, 2, 15), -500.0);
myXIRR.addCashflow(Date.newInstance(2012, 3, 7), -1000.0);
try {
	System.debug(myXIRR.calculate());
} catch(XIRR.XIRRException e) {
	ApexPages.addMessage(e);
}

Reference
---------

[http://en.wikipedia.org/wiki/Internal_rate_of_return]
