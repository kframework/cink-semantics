require "builtins/model-checker.k"
require "../threads/cink-threads.k"

/*@  \section{The New Modules} */

module CINK-LTLMC-SYNTAX

  imports LTL-HOOKS
  imports MODEL-CHECKER-HOOKS
  imports CINK-BASIC-SYNTAX
  imports CINK-BASIC-SEMANTICS

  /*@
    A input program is a sequence of statements or a LTL Formula 
    (this is needed for parsing purposes)
  */
  syntax Pgm ::= LtlFormula

  /*@ We extend the language with labelled statements in order to express
   with LTL formulas when a statement is reached. 
  */

  syntax Stmt ::= Id ":" Stmt 

  /*@
    This module combines the syntax of the \Cink language with that of 
    the LTL formulas.
    The imported module \texttt{MODEL-CHECKER-HOOKS} is a \K interface
    to the Maude module defining the syntax for the model-checker. 
    In addition to this interface, we have to define the atomic propositions.
    Here we define a mall set of such propositions.
    The semantics for these proposition
    will be given in the next module.  
  */

  syntax Prop ::= Id
                | "eqToSum" "(" Id "," Id ")"
                | "eqTo" "(" Id "," Int ")"
                | "logInv" "(" Id "," Id "," Id ")"
                |  "lt" "(" Id "," Val ")" 
                |  "leq" "(" Id "," Val ")" 
                |  "gt" "(" Id "," Val ")" 
                |  "geq" "(" Id "," Val ")" 
                |  "neqTo" "(" Id "," Val ")" 
                |  "eq" "(" Id "," Id ")"

  syntax Exp ::= "step"

endmodule

module CINK-LTLMC-SEMANTICS

  imports CINK-LTLMC-SYNTAX

  /*@
    This module  combines the semantics of \Cink with the
    interface to the model-checker, given by the module \texttt{LTL-HOOKS}.
    The states of the transition system to be model-checked are given
      by the configurations of \Cink programs, which are of sort \texttt{Bag}.
   */

  /*@
    In order to give semantics to the proposition \texttt{eqTo}, we use an 
    auxiliary function \texttt{val} that returns the value of a given variable
    name in a given configuration: 
   */

  syntax Int ::= "val" "(" Bag "," Id ")" [function]

  rule val(<generatedTop>... <T>...
                 <genv>... X:Id |-> L:Loc ...</genv> 
                 <store>... L |-> I:Int ...</store> 
           ...</T> ...</generatedTop>, X)
       =>
       I

  //@ Some additional domain functions:
 
  syntax Int ::= "sumFirstN" "(" Int ")" [function]
  rule sumFirstN(0) => 0 [anywhere]
  rule sumFirstN(N:Int) => sumFirstN(N -Int 1) +Int N requires N >Int 0 [anywhere]

  syntax Int ::= "pow" "(" Int "," Int ")" [function]
  rule pow(X:Int, 0) => 1 
  rule pow(X:Int, Y:Int) => X *Int pow(X, Y -Int 1) requires Y >Int 0

  /*@
    We are ready now to give the semantics for atomic propositions, which is
    self explained:
   */

  

  rule B:Bag |=Ltl eqTo(X:Id, I:Int) => true requires val(B, X) ==K I [anywhere]

  rule B:Bag |=Ltl neqTo(X:Id, I:Int) => true requires val(B, X) =/=K I [anywhere]

  rule B:Bag |=Ltl lt(X:Id, I:Int) => true requires val(B, X) <Int I [anywhere]

  rule B:Bag |=Ltl leq(X:Id, I:Int) => true requires val(B, X) <=Int I [anywhere]

  rule B:Bag |=Ltl gt(X:Id, I:Int) => true requires val(B, X) >Int I [anywhere]

  rule B:Bag |=Ltl geq(X:Id, I:Int) => true requires val(B, X) >=Int I [anywhere]

  rule B:Bag |=Ltl eq(X:Id, Y:Id) => true requires val(B, X) ==Int val(B, Y) [anywhere]


  rule <generatedTop>...
         <T>...
           <k> L:Id : S:Stmt ...</k>
         ...</T>
       ...</generatedTop>
       |=Ltl L
       =>
       true
       [anywhere]


  rule B:Bag |=Ltl eqToSum(X:Id, Y:Id) => true
       requires val(B, X) ==Int sumFirstN(val(B, Y))
       [anywhere]

  rule B:Bag |=Ltl eqTo(X:Id, I:Int) => true
       requires val(B, X) ==Int I
       [anywhere]

  rule B:Bag |=Ltl logInv(A:Id, X:Id, K:Id) => true
       requires (val(B, X) *Int pow(2, val(B, K)) <=Int val(B, A)) 
             andBool (val(B, A) <Int (val(B, X) +Int 1) *Int pow(2, val(B, K)))
       [anywhere]


  rule [step] : step; => . [kripke, step]
endmodule

