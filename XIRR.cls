/**
 * Calculates Internal Rate of Return for a list of irregular cashflows.
 * Uses Newton's method to approximate solution to a target error level.
 *
 * Usage:
 *     XIRR myXIRR = new XIRR();
 *     myXIRR.addCashflow(Date.newInstance(2012, 1, 1), 1500.0);
 *     myXIRR.addCashflow(Date.newInstance(2012, 2, 15), -500.0);
 *     myXIRR.addCashflow(Date.newInstance(2012, 3, 7), -1000.0);
 *     try {
 *         System.debug(myXIRR.calculate());
 *     } catch(XIRR.XIRRException e) {
 *         ApexPages.addMessage(e);
 *     }
 *
 * @author:      Luke McFarlane
 * @date:        Aug 2012
 * @testclass:   TestXIRR.cls
 */
public with sharing class XIRR {

    public class XIRRException extends Exception { }

    public List<Cashflow> cashflows   { get; set; }
    public static final Integer MAX_ITERATIONS = 1000;
    public static final Decimal TARGET_ERROR = 0.0000001;

    /**
     * Construct a new XIRR instance with an empty list of cashflows.
     */
    public XIRR() {
        this.cashflows = new List<Cashflow>();
    }

    /**
     * Given a date & amount, add a new cashflow to the list of cashflows.
     * @param cashflowDate Date of the cashflow
     * @param amount       Amount as decimal. Can be negative or positive.
     */
    public void addCashflow(Date cashflowDate, Decimal amount) {
        addCashflow(new Cashflow(cashflowDate, amount));

    }

    /**
     * Add a cashflow to the list of cashflows.
     * @param c Cashflow to add
     */
    public void addCashflow(Cashflow c) {
        if(c.cashflowDate == null) throw new XIRRException('Attempted to add a cashflow that doesn\'t have a date');
        if(c.amount == null) throw new XIRRException('Attempted to add a cashflow that doesn\'t have an amount');
        this.cashflows.add(c);
    }

    /**
     * Performs a validation check on list of cashflows to ensure that they meet the criteria for calculating an
     * XIRR solution. If validation fails, throw an exception with list of failure reasons.
     */
    public void performValidation() {
        List<String> failureReasons = new List<String>();
        if(this.cashflows != null) {
            // There should be at least one positive and one negative cashflow
            Boolean hasPositive = false;
            Boolean hasNegative = false;
            for(Cashflow c : this.cashflows) {
                System.debug('## checking cashflow with amount: ' + c.amount);
                if(c.amount > 0.0) hasPositive = true;
                else if(c.amount < 0.0) hasNegative = true;
            }
            if(!(hasPositive && hasNegative)) {
                failureReasons.add('At least one positive cash flow and one negative cash flow are required');
            }
        }

        if(failureReasons.size() > 0) {
            String exceptionMsg = String.join(failureReasons, ', ');
            throw new XIRRException(exceptionMsg);
        }
    }

    /**
     * Given an initial guess, use newton's iterative method to approximate solution.
     * @param  initialGuess A decimal value between 0 & 1. Value doesn't usually make a difference to calculation, but some value is required.
     * @return              The approximated solution.
     */
    public Decimal calculate(Decimal initialGuess) {
        performValidation(); // this will throw an exception if validation fails

        Decimal current = initialGuess;
        Decimal next = 0.0;
		Decimal prevDiff = 0.0;
        Decimal diff = 100.0;

        for(Integer i = 0; diff > TARGET_ERROR; i++) {
    	    if(i == MAX_ITERATIONS) {
    	    	throw new XIRRException('Unable to find solution (maximum number of iterations reached)');
    	    }
            if(current < -1.0) {
                throw new XIRRException('Unable to find solution (next guess cannot be less than -1.0)');
            }
            Decimal f = calc_summed_f(current);
            Decimal df = calc_summed_df(current);
            System.debug('f = ' + f + ', df = ' + df);
            System.debug('current before = ' + current);
            next = current - (f/df);
    	    prevDiff = diff;
            diff = System.Math.abs(next - current);
            current = next;
            System.debug('current = ' + current + ', diff = ' + diff);
        }

        return current;
    }

    /**
     * Perform calculation with a default initial guess value.
     * @return The approximated solution.
     */
    public Decimal calculate() {
        return calculate(0.1);
    }

    /**
     * Given a rate r, evaluate and return f(r):
     * @param  r The rate, a decimal between 0.0 & 1.0
     * @return   The result of evaluating f(r).
     */
    public Decimal calc_summed_f(Decimal r) {
        Decimal result = 0.0;
        Date d1 = cashflows[0].cashflowDate;
        for(Integer i = 0; i < cashflows.size(); i++) {
            Cashflow pi = cashflows[i];
    	    if(pi.amount == null) throw new XIRRException('Found a cashflow with amount null');
            Decimal daysBetween = d1.daysBetween(pi.cashflowDate);
    	    //System.debug('pi.amount = ' + pi.amount);
    	    //System.debug('denom = ' + System.Math.pow((Double)(1.0+r), (Double)(daysBetween/365.0)));
    	    //System.debug('rate = ' + r);
    	    //System.debug('daysBetween = ' + daysBetween);
            Decimal base = 1.0+r;
            Decimal exp = daysBetween/365.0;
            Integer expInt = exp.intValue();
            /**
             *         n          P(i)
             * f(r) = SUM  -------------------
             *        i=0   r^((di - d0)/365)
             */
            result += pi.amount/System.Math.pow((Double)(1.0+r), (Double)(daysBetween/365.0));
            System.debug('Adding term: ' + pi.amount + '/(' + base.doubleValue() + ')^(' + expInt + ')');
        }
        return result;
    }

    /**
     * Given a rate r, evaluate and return f'(r) (the derivative of f(r)):
     * @param  r The rate, a decimal between 0.0 & 1.0
     * @return   The result of evaluating f'(r)
     */
    public Decimal calc_summed_df(Decimal r) {
        Decimal result = 0.0;
        Date d1 = cashflows[0].cashflowDate;
        for(Integer i = 0; i < cashflows.size(); i++) {
            Cashflow pi = cashflows[i];
            Decimal daysBetween = d1.daysBetween(pi.cashflowDate);
            /**
             *          n      1                             ((di - d0)/365) - 1
             * f'(r) = SUM   ---- (di - d0) * P(i) * (1 + r)
             *         i=0    65
             * 
             */
            result += (1.0/365.0) * daysBetween * pi.amount * System.Math.pow((Double)(1.0+r), (Double)((daysBetween/365.0) - 1.0));
        }
        return -result;
    }

    /**
     * Return list of plots generated by evaluating f(r) & f'(r) for all values of r from 0.0 to 1.0 (0.01 increments).
     * This is to be used for debugging.
     * @return List of plots
     */
    public List<Plot> getPlots() {
		List<Plot> plots = new List<Plot>();
        for(Decimal rate = 0.0; rate <= 1.0; rate += 0.01) {
	    plots.add(new Plot(rate, calc_summed_f(rate), calc_summed_df(rate)));
        }
        return plots;
    }

    /**
     * Get a google charts image URL that shows the values of f(r) plotted against r.
     * @return Image URL.
     */
	public String getValuesChart() {
		String url = 'http://chart.googleapis.com/chart?cht=lc&chs=500x300&chd=t:';
		List<Decimal> vals = new List<Decimal>();
		for(XIRR.Plot p : getPlots()) {
			vals.add(p.value.setScale(1));
		}
		url += String.join(vals, ',');
		url += '|0,0&chds=a&chxt=x,y&chco=0000bb,999999';
		return url;
	}

    /**
     * Get a google charts image URL that shows the values of f'(r) plotted against r.
     * @return Image URL.
     */
	public String getDFValuesChart() {
		String url = 'http://chart.googleapis.com/chart?cht=lc&chs=500x300&chd=t:';
		List<Decimal> fvals = new List<Decimal>();
		for(XIRR.Plot p : getPlots()) {
			fvals.add(p.fvalue.setScale(1));
		}
		url += String.join(fvals, ',');
		url += '|0,0&chds=a&chxt=x,y&chco=0000bb,999999';
		return url;
	}

    /**
     * A plot represents a f & f' value for a rate, and is to be used for debugging.
     */
    public class Plot {
    	public Decimal rate { get; set; }
    	public Decimal value { get; set; }
    	public Decimal fValue { get; set; }

    	public Plot(Decimal rate, Decimal value, Decimal fValue) {
    		this.rate = rate;
    		this.value = value;
    		this.fValue = fValue;
    	}
    }
}