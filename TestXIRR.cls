/*
 * Unit tests for XIRR class.
 *
 * @author  Luke
 * @date    Sep 2012
 */
public with sharing class TestXIRR {
    @IsTest
    static void positiveTest1() {
        XIRR xirr = new XIRR();
        // Capital Calls:
        xirr.addCashflow(Date.newInstance(2003, 09, 15), -460000);
        xirr.addCashflow(Date.newInstance(2004, 05, 18), -552000);
        xirr.addCashflow(Date.newInstance(2004, 09, 20), -506000);
        xirr.addCashflow(Date.newInstance(2005, 01, 17), -276000);
        xirr.addCashflow(Date.newInstance(2005, 04, 1), -414000);
        xirr.addCashflow(Date.newInstance(2005, 09, 7), -690000);
        xirr.addCashflow(Date.newInstance(2005, 10, 15), -313425);
        xirr.addCashflow(Date.newInstance(2006, 07, 10), -690000);
        xirr.addCashflow(Date.newInstance(2007, 03, 1), -698575);

        // Distributions:
        xirr.addCashflow(Date.newInstance(2005, 10, 15), 313425);
        xirr.addCashflow(Date.newInstance(2008, 4, 24), 1533331);
        xirr.addCashflow(Date.newInstance(2009, 3 ,5), 230000);
        xirr.addCashflow(Date.newInstance(2009, 12, 1), 184000); 
        xirr.addCashflow(Date.newInstance(2012, 6, 30), 9710000); 

        Decimal result = xirr.calculate(0.15);
        System.assertEquals(0.1734, result.setScale(4));
    }

    @IsTest
    static void positiveTest2() {
        XIRR xirr = new XIRR();

        xirr.addCashflow(Date.newInstance(2010, 12, 1), -350000);
        xirr.addCashflow(Date.newInstance(2011, 2, 1), -80000);
        xirr.addCashflow(Date.newInstance(2011, 3, 1), -350000);
        xirr.addCashflow(Date.newInstance(2011, 4, 1), -90000);
        xirr.addCashflow(Date.newInstance(2011, 5, 1), -10000);
        xirr.addCashflow(Date.newInstance(2011, 6, 1), -110000);
        xirr.addCashflow(Date.newInstance(2011, 7, 1), -200000);
        xirr.addCashflow(Date.newInstance(2011, 8, 1), -1435000);
        xirr.addCashflow(Date.newInstance(2011, 9, 1), -200500);
        xirr.addCashflow(Date.newInstance(2012, 1, 1), -1424975);
        xirr.addCashflow(Date.newInstance(2012, 2, 1), -110000);
        xirr.addCashflow(Date.newInstance(2012, 3, 25), -583091);
        xirr.addCashflow(Date.newInstance(2012, 4, 16), -1382000);
        xirr.addCashflow(Date.newInstance(2012, 4, 16), 672882);
        xirr.addCashflow(Date.newInstance(2012, 5, 1), -257525);
        xirr.addCashflow(Date.newInstance(2012, 6, 1), -125000);
        xirr.addCashflow(Date.newInstance(2012, 10, 1), -5389875);
        xirr.addCashflow(Date.newInstance(2012, 12, 30), 11725424);

        Decimal result = xirr.calculate(0.15);
        //System.assertEquals(0.1885, result.setScale(4));
        System.assertEquals(0.0352, result.setScale(4)); // 3/28 - updated expected value to match result from XIRR function in Excel spreadsheet
    }

    @IsTest
    static void positiveTest3() {
        XIRR xirr = new XIRR();

        xirr.addCashflow(Date.newInstance(2008, 1, 1), -10000);
        xirr.addCashflow(Date.newInstance(2008, 3, 1), 2750);
        xirr.addCashflow(Date.newInstance(2008, 10, 30), 4250);
        xirr.addCashflow(Date.newInstance(2009, 2, 15), 3250);
        xirr.addCashflow(Date.newInstance(2009, 4, 1), 2750);

        Decimal result = xirr.calculate(0.15);
        System.assertEquals(0.3734, result.setScale(4));
    }

    /**
     * Test case where result is negative.
     * NOTE: currently not supported, as will try a guess of less than -1.0 
     */
    @isTest static void positiveTest4() {
        XIRR xirr = new XIRR();

        xirr.addCashflow(Date.newInstance(2012, 08, 13), -2000000);
        xirr.addCashflow(Date.newInstance(2012, 10, 24), -2000000);
        xirr.addCashflow(Date.newInstance(2013, 01, 21), -2000000);
        xirr.addCashflow(Date.newInstance(2013, 03, 31), 2540000);

        // System.assertEquals(-0.9, result.setScale(2), 'Incorrect XIRR value'); <-- TODO: handle this in future
        try {
            Decimal result = xirr.calculate(0.15);
        } catch(XIRR.XIRRException e) {
            String exceptionMsg = e.getMessage();
            System.assertEquals('Unable to find solution (next guess cannot be less than -1.0)', exceptionMsg, 'Incorrect error message');
        }
    }

    /**
     * Test case where there are no positive cashflows.
     */
    @isTest static void negativeTest1() {
        XIRR xirr = new XIRR();

        xirr.addCashflow(Date.newInstance(2012, 08, 12), -10000);
        xirr.addCashflow(Date.newInstance(2012, 10, 12), -10000);
        xirr.addCashflow(Date.newInstance(2013, 01, 13), -10000);

        try {
            Decimal result = xirr.calculate(0.15);
        } catch(XIRR.XIRRException e) {
            String exceptionMsg = e.getMessage();
            System.assertEquals('At least one positive cash flow and one negative cash flow are required', exceptionMsg, 'Incorrect error message');
        }
    }
}