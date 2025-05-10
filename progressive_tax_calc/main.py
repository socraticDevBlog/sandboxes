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

    for x in taxBrackets:
        if x.bottom <= amount and amount <= x.top:
            slice = amount - x.bottom
        elif amount < x.bottom:
            slice = 0
        elif amount < x.top:
            slice = amount - x.bottom
        else:
            slice = x.top - x.bottom
        taxes.append(slice * x.rate)

    return sum(taxes)
