from dataclasses import dataclass


@dataclass
class TaxBracket:
    bottom: float
    top: float
    rate: float


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

    calculate_tax = (
        lambda bracket: max(0, min(amount, bracket.top) - bracket.bottom) * bracket.rate
    )
    taxes = map(calculate_tax, taxBrackets)

    return sum(taxes)
