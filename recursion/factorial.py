# Explain how to calculate n! = n × (n-1) × ... × 1 recursively.
# Product of numbers from 1 to n

class FactorialError(Exception):
    ...

class NonPositiveIntegerError(FactorialError):
    message = "Please provide a positive integer."
    def __init__(self, message=message):
        self.message = message
        super().__init__(self.message)

def factorial(n):
    if n < 0:
        raise NonPositiveIntegerError()

    if n < 1:
        return 1

    if n > 2:
        return n * factorial(n - 1)        
    
    return n


if __name__ == "__main__":
    n = 5
    fact = factorial(n)
    print(f"factorial of {n}is: {fact}")