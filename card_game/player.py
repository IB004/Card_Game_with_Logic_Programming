from util import print_color, warn


class Player:
    def __init__(self, name, color='[0m'):
        self.hand = []
        self.name = name
        self.pass_turn = False
        self.color = color

    def hand_is_empty(self):
        return len(self.hand) == 0

    def take_cards_from_pile(self, cards):
        while len(self.hand) < 6 and len(cards) > 0:
            self.hand.append(cards.pop(0))

    def grab_cards(self, cards):
        self.hand.extend(cards)
        self.pass_turn = True

    def draw_cards(self, prolog_thread):
        raise NotImplementedError()

    def response(self, opp_cards, oppo_name, prolog_thread):
        raise NotImplementedError()

    def remove_cards_from_hand(self, cards):
        self.hand = [card for card in self.hand if card not in cards]

    def win(self):
        print(f"{self.name} win!")

    def lose(self):
        print(f"{self.name} lose!")


class CommandLinePlayer(Player):
    def draw_cards(self, prolog_thread):
        print_color(f"Your cards: {' '.join(self.hand)}.", self.color)
        inp = input("Draw cards: ").strip()
        draw = inp.split(' ')
        if len(draw) != len(list(set(draw))):
            warn("Do not use duplicates!")
            return None
        for card in draw:
            if not (card in self.hand):
                warn("Not a card in your hand!")
                return None
        query = f"same_power_in_list([{','.join(draw)}])."
        resp = prolog_thread.query(query)
        if resp == False:
            warn("Not all cards have the same power!")
            return None

        self.remove_cards_from_hand(draw)
        return draw

    def response(self, opp_cards, opp_name, prolog_thread):
        print_color(f"Your cards: {' '.join(self.hand)}.", self.color)
        inp = input("Draw cards: ").strip()
        if inp == "take":
            self.grab_cards(opp_cards)
            return []
        draw = inp.split(' ')
        if len(draw) != len(list(set(draw))):
            warn("Do not use duplicates!")
            return None
        for card in draw:
            if not (card in self.hand):
                warn("Not a card in your hand!")
                return None

        query = f"beat_list([{','.join(draw)}], [{','.join(opp_cards)}])."
        resp = prolog_thread.query(query)
        if resp == False:
            warn("Failed query: ")
            warn(query)
            warn("Can not beat cards in such a way!")
            return None

        self.remove_cards_from_hand(draw)
        return draw


class ComputerPlayer(Player):
    def draw_cards(self, prolog_thread):
        query = f"draw_cards([{','.join(self.hand)}], Draw, _)."
        resp = prolog_thread.query(query)
        draw = resp[0]["Draw"]
        print_color(f"{self.name} draw: {' '.join(draw)}.", self.color)
        self.remove_cards_from_hand(draw)
        return draw

    def response(self, opp_cards, opp_name, prolog_thread):
        query = f"response([{','.join(self.hand)}], [{','.join(opp_cards)}], Draw, _)."
        resp = prolog_thread.query(query)
        draw = resp[0]["Draw"]
        if draw == []:
            print_color(f"{self.name} take.", self.color)
            self.grab_cards(opp_cards)
            return []
        print_color(f"{self.name} response: {' '.join(draw)}.", self.color)
        self.remove_cards_from_hand(draw)
        return draw
