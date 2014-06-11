/**
 * A cashflow consists of a date & decimal amount value, and can be sorted.
 *
 * @author  Luke
 * @date    Aug 2012
 */
global class Cashflow implements Comparable {

    public Date cashflowDate { get; set; }
    public Decimal amount { get; set; }

    /**
     * Create a new cashflow instance given a date and amount.
     * @param  d Date
     * @param  a Amount as a decimal
     */
    public Cashflow(Date d, Decimal a) {
        cashflowDate = d;
        amount = a;
    }

    /**
     * Implement the compareTo method
     * @param  compareTo The cashflow to compare to
     * @return           -1, 0, or 1 depending on whether the date of cashflow comparing to is before, the same, or after this cashflow date (respectively).
     */
    global Integer compareTo(Object compareTo) {
        Cashflow compareToEmp = (Cashflow)compareTo;
        if (cashflowDate == compareToEmp.cashflowDate) return 0;
        if (cashflowDate > compareToEmp.cashflowDate) return 1;
        return -1;        
    }
}