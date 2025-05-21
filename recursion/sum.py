# recursion
#
# adding up numbers from a list


def sum(numbers, total=0) -> int:
    if len(numbers) == 0:
        return total

    try:
        total += numbers.pop(0) + numbers.pop(1)
    except:
        total += numbers.pop(0)

    return sum(numbers=numbers, total=total)


numbers = [i for i in range(10)]

print(f"sum of these numbers {numbers} is: {sum(numbers=numbers)}")
