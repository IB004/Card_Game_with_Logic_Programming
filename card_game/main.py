import random
import traceback
from player import CommandLinePlayer, ComputerPlayer
from util import print_file, warn
from swiplserver import PrologMQI as mqi


def print_introduce_players(players):
    print(f"Welcome our players: {', '.join([player.name for player in players])}!\n")


cards = [
            "six_spades", "seven_spades", "eight_spades", "nine_spades", "ten_spades", "jack_spades", "queen_spades", "king_spades", "ace_spades",
            "six_clubs", "seven_clubs", "eight_clubs", "nine_clubs", "ten_clubs", "jack_clubs", "queen_clubs", "king_clubs", "ace_clubs",
            "six_hearts", "seven_hearts", "eight_hearts", "nine_hearts", "ten_hearts", "jack_hearts", "queen_hearts", "king_hearts", "ace_hearts",
            "six_diamonds", "seven_diamonds", "eight_diamonds", "nine_diamonds", "ten_diamonds", "jack_diamonds", "queen_diamonds", "king_diamonds", "ace_diamonds",
        ]

random.shuffle(cards)

players = [CommandLinePlayer("Ivan"), ComputerPlayer("Compy", '[94m'),  ComputerPlayer("Mompy", '[92m')]


try:
    prolog_thread = mqi().create_thread()

    prolog_thread.query("[cards]")

    print_file("texts/welcome.txt")

    print_introduce_players(players)

    while len(players) > 1:
        for player in players:
            player.take_cards_from_pile(cards)

        first = players.pop(0)
        if first.pass_turn:
            players.append(first)
            first.pass_turn = False
            continue

        second = players.pop(0)

        print(f"Cards in a pile: {len(cards)}.")

        draw = None
        while draw is None:
            draw = first.draw_cards(prolog_thread)
        resp = None
        while resp is None:
            resp = second.response(draw, first.name, prolog_thread)

        players.insert(0, second)
        players.append(first)

        for player in players:
            if player.hand_is_empty():
                player.win()
                players.remove(player)

        print()

    for player in players:
        player.lose()

    print_file("texts/goodbye.txt")

except Exception as e:
    warn("Something went wrong!")
    warn(traceback.format_exc())

finally:
    mqi().stop()


