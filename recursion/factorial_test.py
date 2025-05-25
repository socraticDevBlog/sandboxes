import unittest
from factorial import factorial, NonPositiveIntegerError

class TestFactorial(unittest.TestCase):
    def test_factorial_of_negative_integer_raises(self):
        with self.assertRaises(NonPositiveIntegerError) as context:
            factorial(-1)
        self.assertEqual(str(context.exception), NonPositiveIntegerError.message)

    def test_factorial_of_1(self):
        self.assertEqual(factorial(1), 1)

    def test_factorial_of_2(self):
        self.assertEqual(factorial(2), 2)

    def test_factorial_of_3(self):
        self.assertEqual(factorial(3), 6)

    def test_factorial_of_5(self):
        self.assertEqual(factorial(5), 120)

    def test_factorial_of_0(self):
        # Depending on implementation, may raise or return 1
        self.assertEqual(factorial(0), 1)

if __name__ == "__main__":
    unittest.main()
