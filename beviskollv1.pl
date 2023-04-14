

clone1(X,X).

verify(InputFileName) :- see(InputFileName),
  read(Prems), read(Goal), read(Proof),
  seen, valid_proof(Prems, Goal, Proof).

/**
Check if the last line of the proof is the same as the goal.
Checks that the proof is correct.
*/
valid_proof(Prems, Goal, Proof):-
  check_goal(Goal, Proof), iterate_proof(Prems, Proof, []).

/**
Check that the goal is the same as the last line.
*/

check_goal(Goal, Proof) :-
    last(Proof, ProofLine),         %% Gets the last line of proof.
    nth0(1, ProofLine, GoalMatch),  %% Extracts the middle part of the line.
    Goal = GoalMatch,               %% Checks if Goal matches the last line of proof.
    nth0(2, ProofLine, NotAssumption),
    NotAssumption \= 'assumption',
    !.


iterate_proof(Prems, [], _).
iterate_proof(Prems, [H|T], ValidProof):-
    check_lines(Prems, H, ValidProof),
    append(ValidProof,[H], NewValidProof),
    iterate_proof(Prems, T, NewValidProof).

check_lines(Prems, [_, A, premise], _):-
    member(A, Prems), !.

check_lines(_, [_, A, andel1(LineNr)], ValidProof):-
    member([LineNr, and(A, _), _], ValidProof), !.

check_lines(_, [_, A, andel2(LineNr)], ValidProof):-
    member([LineNr, and(_, A), _], ValidProof), !.

check_lines(_, [_, A, copy(LineNr)], ValidProof):-
    member([LineNr, A, _], ValidProof), !.

check_lines(_, [_, and(X, Y), andint(LineNr1, LineNr2)], ValidProof):-
   member([LineNr1, X, _], ValidProof), member([LineNr2, Y, _], ValidProof),!.

check_lines(_, [_, or(X, _), orint1(LineNr)], ValidProof):-
    member([LineNr, X, _], ValidProof), !.

check_lines(_, [_, or(_, Y), orint2(LineNr)], ValidProof):-
    member([LineNr, Y, _], ValidProof), !.

check_lines(_, [_, A, impel(LineNr1, LineNr2)], ValidProof):-
    member([LineNr1, A1, _], ValidProof),!, member([LineNr2, imp(A1, A), _], ValidProof),!.

check_lines(_, [_, neg(neg(A)), negnegint(LineNr)], ValidProof):-
    member([LineNr, A, _], ValidProof), !.

check_lines(_, [_, A, negnegel(LineNr)], ValidProof):-
    member([LineNr, neg(neg(A)), _], ValidProof),!.

check_lines(_, [_, neg(A), mt(LineNr1, LineNr2)], ValidProof):-
    member([LineNr1, imp(A, B), _], ValidProof), !, member([LineNr2, neg(B), _], ValidProof), !.

check_lines(_, [_, or(A, neg(A)), lem], ValidProof):-
    true, !.

check_lines(_, [_, A, contel(LineNr)], ValidProof):-
    member([LineNr, cont, _], ValidProof), !.

check_lines(_, [_, cont, negel(LineNr1, LineNr2)], ValidProof):-
    member([LineNr1, A, _], ValidProof), member([LineNr2, neg(A), _], ValidProof), !.

/**
Stuff regarding boxes:
*/

check_lines(_, [[LineNr, A, assumption]|Restofbox], ValidProof):-
   clone1(ValidProof, X),
   append(X, [[LineNr, A, assumption]], TempValidProof),
   check_box(Restofbox, TempValidProof), !. /** Confirm all lines in box*/

check_lines(_, [_, imp(A, B), impint(LineNr1, LineNr2)], ValidProof):-
  find_box(ValidProof, [LineNr1, A, assumption], [LineNr2, B, _]),!.

check_lines(_, [_, A, pbc(LineNr1, LineNr2)], ValidProof):-
  find_box(ValidProof, [LineNr1, neg(B), assumption], [LineNr2, cont, _]), !.

check_lines(_, [_, neg(A), pbc(LineNr1, LineNr2)], ValidProof):-
  find_box(ValidProof, [LineNr1, A, assumption], [LineNr2, cont, _]), !.

check_lines(_, [_, X, orel(LineNr1, LineNr2, LineNr3, LineNr4, LineNr5)], ValidProof):-
  member([LineNr1, or(A, B), _], ValidProof),
  find_box(ValidProof, [LineNr2, A, assumption], [LineNr3, X, _]),
  find_box(ValidProof, [LineNr4, B, assumption], [LineNr5, X, _]), !.

check_lines(_, [_, neg(A), negint(LineNr1, LineNr2)], ValidProof):-
  find_box(ValidProof, [LineNr1, A, assumption], [LineNr2, cont, _]), !.


/**
Check each line of the box.
*/
check_box([], TempValidProof):- true.
check_box([H|[]], TempValidProof).

check_box([H|RestofBox], TempValidProof):-
   check_lines(_, H, TempValidProof),
   append(TempValidProof, [H], NewValidProof), %% Add checked line of the box to the checked proof
   check_box(RestofBox, NewValidProof), !.

/**
Find box from which the conclusion is drawn
*/
find_box([H|T], Firstline, Lastline):- !,
   \+ find_boxIteration([H|T], Firstline, Lastline).

find_boxIteration([], Firstline, Lastline).
find_boxIteration([H|T], Firstline, Lastline) :-
   \+ checkIfBox(H, Firstline, Lastline),!,
   find_boxIteration(T, Firstline, Lastline).

checkIfBox(Box, Firstline, Lastline) :-
   member(Firstline, Box),
   member(Lastline, Box).
