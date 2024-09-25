% ---------- Cards and their base properties ----------

% Card suit.
spades(six_spades).
spades(seven_spades).
spades(eight_spades).
spades(nine_spades).
spades(ten_spades).
spades(jack_spades).
spades(queen_spades).
spades(king_spades).
spades(ace_spades).

clubs(six_clubs).
clubs(seven_clubs).
clubs(eight_clubs).
clubs(nine_clubs).
clubs(ten_clubs).
clubs(jack_clubs).
clubs(queen_clubs).
clubs(king_clubs).
clubs(ace_clubs).

hearts(six_hearts).
hearts(seven_hearts).
hearts(eight_hearts).
hearts(nine_hearts).
hearts(ten_hearts).
hearts(jack_hearts).
hearts(queen_hearts).
hearts(king_hearts).
hearts(ace_hearts).

diamonds(six_diamonds).
diamonds(seven_diamonds).
diamonds(eight_diamonds).
diamonds(nine_diamonds).
diamonds(ten_diamonds).
diamonds(jack_diamonds).
diamonds(queen_diamonds).
diamonds(king_diamonds).
diamonds(ace_diamonds).


% Card type.
six(six_spades).
six(six_clubs).
six(six_hearts).
six(six_diamonds).

seven(seven_spades).
seven(seven_clubs).
seven(seven_hearts).
seven(seven_diamonds).

eight(eight_spades).
eight(eight_clubs).
eight(eight_hearts).
eight(eight_diamonds).

nine(nine_spades).
nine(nine_clubs).
nine(nine_hearts).
nine(nine_diamonds).

ten(ten_spades).
ten(ten_clubs).
ten(ten_hearts).
ten(ten_diamonds).

jack(jack_spades).
jack(jack_clubs).
jack(jack_hearts).
jack(jack_diamonds).

queen(queen_spades).
queen(queen_clubs).
queen(queen_hearts).
queen(queen_diamonds).

king(king_spades).
king(king_clubs).
king(king_hearts).
king(king_diamonds).

ace(ace_spades).
ace(ace_clubs).
ace(ace_hearts).
ace(ace_diamonds).



% ---------- Base rules ----------

% Hardcoded trumps.
trump(Card) :-
    spades(Card).


% Type power.
power(Card, 6) :- six(Card).
power(Card, 7) :- seven(Card).
power(Card, 8) :- eight(Card).
power(Card, 9) :- nine(Card).
power(Card, 10) :- ten(Card).
power(Card, 11) :- jack(Card).
power(Card, 12) :- queen(Card).
power(Card, 13) :- king(Card).
power(Card, 14) :- ace(Card).


same_suit(C1, C2) :- 	
    spades(C1), spades(C2);
    clubs(C1), clubs(C2);
    hearts(C1), hearts(C2);
    diamonds(C1), diamonds(C2).


more_powerful(C1, C2) :-
    power(C1, P1), power(C2, P2), P1 > P2.


same_power(C1, C2) :-
    power(C1, P), power(C2, P).

% Check whether every card in a list have same power.
% Helpful when validate plyer's drawn cards.
same_power_in_list([]).
same_power_in_list([_C]).
same_power_in_list([H1 | [H2 | T]]) :-
    same_power(H1, H2), same_power_in_list([H2 | T]).
       
% Can C1 beat C2?
beat(C1, C2):-
	same_suit(C1, C2), more_powerful(C1, C2);
    trump(C1), \+ trump(C2);
    trump(C1), trump(C2), more_powerful(C1, C2).

% Can list_1 beat list_2 respectively?
beat_list([], []).
beat_list([H1|T1], [H2|T2]) :-
	beat(H1, H2), beat_list(T1, T2).



% ---------- Sorting rules ----------

% Remove all cards eq to given one from a list.
take_away(Cards, C, Res) :-
    member(C, Cards), take_away_r(Cards, C, [], Res).
take_away_r([], _C, Res, Res).
take_away_r([H|T], C, Acc, Res) :-
    H == C, take_away_r(T, C, Acc, Res);
    H \= C, Acc1 = [H | Acc], take_away_r(T, C, Acc1, Res).

% Remove all trumps from a list.
without_trumps(Cards, Res) :-
    without_trumps_r(Cards, [], ResRev), !, reverse(ResRev, Res).
without_trumps_r([], Res, Res).
without_trumps_r([H | T], Acc, Res) :-
	\+ trump(H), Acc1 = [H | Acc], without_trumps_r(T, Acc1, Res);
    trump(H), without_trumps_r(T, Acc, Res).

% Get card with min 'number' or 'power'.
min_power_card(Cards, Res) :-
    min_power_card_r(Cards, Res), member(Res, Cards), !.
min_power_card_r([], _Res).
min_power_card_r([H|T], Res) :-
    power(H, HP), power(Res, RP), RP =< HP,  min_power_card_r(T, Res).

% Get min card, but not trump.
min_power_card_without_trumps(Cards, Res) :-
    without_trumps(Cards, CardsWithoutTrumps), min_power_card(CardsWithoutTrumps, Res).

% If you have only trumps -- get min trump card.
% Otherwise -- get min non-trump card.
min_power_card_smart(Cards, Res) :-
    min_power_card_without_trumps(Cards, Res), !;
    min_power_card(Cards, Res), !.

% Place first non-trump cards in a sorted way.
% Then place all trump cards in a sorted way.
smart_power_sort_cards(Cards, Res) :-
    smart_power_sort_cards_r(Cards, [], ResRev), reverse(ResRev, Res), !.
smart_power_sort_cards_r([], Res, Res).
smart_power_sort_cards_r(Cards, Acc, Res) :-
    min_power_card_smart(Cards, C), take_away(Cards, C, CardsRest), 
    smart_power_sort_cards_r(CardsRest, [C|Acc], Res).



% ---------- Decision rules ----------

% Get the 'smallest' opponent card.
choose_opponent_card_to_beat(Cards, Res) :-
    smart_power_sort_cards(Cards, [Res|_T]), !.

% Res is the 'smallest' card from your Cards, that beats Opp.
choose_your_card_to_beat(Cards, Opp, Res) :-
    smart_power_sort_cards(Cards, Sorted), can_beat(Sorted, Opp, Res).


% Check if you have a Card in your Cards to beat Opp.
can_beat([H|_T], Opp, H) :- 
    beat(H, Opp).
can_beat([_H|T], Opp, Res) :- 
    can_beat(T, Opp, Res).


choose_and_beat(Cards, OppCards, Opp, Beat) :-
    choose_opponent_card_to_beat(OppCards, Opp),
    choose_your_card_to_beat(Cards, Opp, Beat).

% Decide what cards to draw in deffend to OppCards and what cards rest. 
% If you can't beat OppCards  then take it.
response(Cards, OppCards, BeatCards, RestCards) :-
    response_r(OppCards, [], BeatCardsRev, Cards, RestCards), reverse(BeatCardsRev, BeatCards);
    BeatCards = [], append(Cards, OppCards, RestCards).
response_r([], BeatCards, BeatCards, RestCards, RestCards).
response_r(OppCards, BeatCardsAcc, BeatCards, RestCardsAcc, RestCards) :-
    choose_and_beat(RestCardsAcc, OppCards, Opp, Beat),
    take_away(OppCards, Opp, RestOpp),
    take_away(RestCardsAcc, Beat, RestCardsAccNew),
    response_r(RestOpp, [Beat|BeatCardsAcc], BeatCards, RestCardsAccNew, RestCards), !.


% Draw all 'smallest' cards with the same power.
draw_cards([], [], []).
draw_cards([C], [C], []).
draw_cards(Cards, Draw, Rest) :-
    smart_power_sort_cards(Cards, Sorted),
    draw_cards_r(Sorted, [], Draw, Rest).

draw_cards_r([], Draw, Draw, []).
draw_cards_r([H|T], [], Draw, Rest) :-
    draw_cards_r(T, [H], Draw, Rest).
draw_cards_r([H1|T1], [H2|T2], Draw, Rest) :-
    same_power(H1, H2), draw_cards_r(T1, [H1 | [H2 | T2]], Draw, Rest).
draw_cards_r([H1|T1], [H2|T2], Draw, Rest) :-
    \+ same_power(H1, H2), Draw = [H2|T2], Rest = [H1|T1].
    
    