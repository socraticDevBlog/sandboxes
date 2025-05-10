class TaxBracket:
    def __init__(self, bottom, top, rate):
        self.bottom = bottom
        self.top = top
        self.rate = rate


def taxes_owed(amount, taxBrackets):
    """
    taxes_owed

    returns the taxes owed based on a progressive taxation scheme

    input:
    - amount: integer
    - TaxBrackets: an array of TaxBracket objects

    returns:
    - a decimal number: taxes owed for the amount inputed based on the various
    tax TaxBrackets
    """
    taxes = []

    for bracket in taxBrackets:
        taxable_income = max(0, min(amount, bracket.top) - bracket.bottom)
        taxes.append(taxable_income * bracket.rate)

    return sum(taxes)
