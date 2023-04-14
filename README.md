# Natural Deduction Proof Checker

An implementation of an algorithm that checks whether a proof written
in natural deduction is correct or not. The input to the program is a sequent and a proof,
and the program responds with "yes" if the given proof is correct and shows that the given sequent is valid, and "no" otherwise.

The approach to creating a proof checker for natural deduction proofs involved the following steps:

1. Read the input data file using the verify predicate. The input data file format consists of Prolog terms.

2. Parse the input data into three variables: *Prems*, *Goal*, and *Proof*. These variables are then passed to the *valid_proof* predicate.

3. The *valid_proof* predicate checks if the last line of *Proof* matches *Goal* using the *check_goal* predicate, and verifies the correctness of the proof using the *iterate_proof* predicate with *Proof* and *Prems* as arguments.

4. The *check_goal* predicate extracts the last line of *Proof* and the middle term of the last line, which represents the goal. It then tries to unify this term with the given term in *Goal* and ensures that the last line is not an assumption.

5. The *iterate_proof* predicate iterates through each element (line or box) in *Proof* and verifies each line using the *check_lines* predicate. For each verified line, it appends it to the *ValidProof* list.

6. The *check_lines* predicate takes an element from *Proof*, the list *Prems*, and the *ValidProof* containing verified lines. It verifies that the conditions for applying the rule exist in the previously verified lines of *Proof* that are in *ValidProof*.

## Box Handling

For boxes, the element that comes in from our Proof list is treated as a separate list. A box is identified through unification in the *check_lines* predicate. A copy of ValidProof is created and the first line of the box is appended to create the *TempValidProof* list. Then *TempValidProof* is used to check all lines in the box.

The *check_box* predicate iterates through all lines in the box and checks each line against the *TempValidProof* list using the *check_lines* predicate. Once the entire box is checked, it is added to the *ValidProof* list.

When a line in the proof is a conclusion drawn from one or more boxes, we need to find the box(es) that contain the first and last line that meets the logical rule's requirements. *find_box* predicate is used for this purpose.

### Input Data

Each input data file consists of three Prolog terms:

1. A list of premises (left part of a sequent)
2. A proof goal (right part of a sequent)
3. A proof in natural deduction
