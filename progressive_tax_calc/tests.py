import unittest
from main import TaxBracket, taxes_owed


class TestTaxesFunction(unittest.TestCase):
    def test_taxes(self):
        # Define tax brackets
        first_bracket = TaxBracket(bottom=0, top=19999, rate=0.1)
        second_bracket = TaxBracket(bottom=20000, top=49999, rate=0.2)
        third_bracket = TaxBracket(bottom=50000, top=1000000000, rate=0.4)

        # Test case 1: Amount within the first TaxBracket
        self.assertAlmostEqual(
            taxes_owed(15000, [first_bracket, second_bracket, third_bracket]), 1500
        )

        # # Test case 2: Amount spanning two brackets
        self.assertAlmostEqual(
            taxes_owed(30000, [first_bracket, second_bracket, third_bracket]),
            4000,
            delta=0.1,
        )

        # # Test case 3: Amount spanning all brackets
        self.assertAlmostEqual(
            taxes_owed(100000, [first_bracket, second_bracket, third_bracket]),
            27999.7,
            delta=0.1,
        )

        # # Test case 4: Amount below the first TaxBracket
        self.assertAlmostEqual(
            taxes_owed(0, [first_bracket, second_bracket, third_bracket]), 0
        )

        # # Test case 5: Amount exactly at a TaxBracket boundary
        self.assertAlmostEqual(
            taxes_owed(20000, [first_bracket, second_bracket, third_bracket]),
            2000,
            delta=0.1,
        )


if __name__ == "__main__":
    unittest.main()
