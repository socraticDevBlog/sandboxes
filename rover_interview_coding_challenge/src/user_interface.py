from rover import Rover


def prompt(message: str) -> str:
    """
    Prompt the user for input and return the response.

    Args:
        message (str): The message to display to the user.

    Returns:
        str: The user's input.
    """
    return input(message)


print("Welcome to the Rover app!")
print("This app allows you to control a rover on a grid.")
print("")
print("You can use the following commands:")
print("1. Move forward (f)")
print("2. Turn left (l)")
print("3. Turn right (r)")
print("4. Get help (h)")
print("5. Quit (q)")

user_input = ""
rover = Rover()

while user_input.lower() != "q":
    user_input = prompt("Enter a command: ")

    if user_input.lower() == "f":
        rover.move_forward()
        print(f"Rover moved forward to position: {rover}")
    elif user_input.lower() == "l":
        rover.turn_left()
        print(f"Rover turned left. New direction: {rover.direction}")
    elif user_input.lower() == "r":
        rover.turn_right()
        print(f"Rover turned right. New direction: {rover.direction}")
    elif user_input.lower() == "h":
        print(
            "Help: Use 'f' to move forward, 'l' to turn left, 'r' to turn right, and 'q' to quit."
        )
    elif user_input.lower() == "q":
        print("Quitting the app...")
    else:
        print("Invalid command. Please try again.")
