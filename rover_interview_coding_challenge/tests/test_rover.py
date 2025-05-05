import pytest
from rover import Rover


def test_initialization():
    rover = Rover()
    assert rover.x == 0
    assert rover.y == 0
    assert rover.direction == "N"


def test_move_forward():
    rover = Rover()
    rover.move_forward()
    assert rover.x == 0
    assert rover.y == 1


def test_turn_left():
    rover = Rover()
    rover.turn_left()
    assert rover.direction == "W"
    rover.turn_left()
    assert rover.direction == "S"
    rover.turn_left()
    assert rover.direction == "E"
    rover.turn_left()
    assert rover.direction == "N"


def test_turn_right():
    rover = Rover()
    rover.turn_right()
    assert rover.direction == "E"
    rover.turn_right()
    assert rover.direction == "S"
    rover.turn_right()
    assert rover.direction == "W"
    rover.turn_right()
    assert rover.direction == "N"
