
require "../../pointers/cink-pointers.k"

module CINK-ARRAYS-SYNTAX

  syntax Exp ::= Exp "[" Exp "]" [strict(1, 2(context(rvalue), result(Int))),
                                  array]
               | Exp "[]" [array] 

  syntax priorities  array > multiply read write greatthan lessequal
  syntax priority  array > ampersand assign

endmodule

module CINK-ARRAYS-SEMANTICS

  imports CINK-BASIC-SEMANTICS
  imports CINK-POINTERS-SEMANTICS
  imports CINK-ARRAYS-SYNTAX
  imports ARRAY


  /*@
    The memory model:
  */
  syntax SeqLoc ::= "seq-array" "(" Int "," Loc ")"
  syntax Loc ::= SeqLoc


  //@ Extending select over sequences of locations:

  syntax Loc ::= "select" "(" Loc "," Int ")" [smtlib(select)]

  rule lval(L:SeqLoc)[I:Int] => lval(select(L, I))

  rule select(L:Loc, I:Int) + J:Int => select(L, I +Int J)

  rule <k> $inc(L:Loc, V:Int) => . ...</k>
       <store>... L |-> select(_:Loc, (I:Int => I +Int V))...</store>
       [side-effect(inc)]

  rule <k> $dec(L:Loc, V:Int) => . ...</k>
       <store>... L |-> select(_:Loc, (I:Int => I -Int V))...</store>
       [side-effect(inc)]

  /*@
  We define array types following the notation convention from the manual. 
  We call these types \emph{explicit array types}. Note that these have a 
  recursive definition.  
  We also extend statements with declaration of variables (expressions)
  of the new type.
  */

  syntax ArrType ::= "array" "of" Int Type 
  syntax Type ::= ArrType
  syntax Stmt ::= Exp "of" ArrType ";"

  /*@
  Arrays are values:
  */
  syntax Val ::= Array

  //@ An updated array is a value:

  rule isVal(store(_,_,_)) => true

  /*@
  Array declarations are translated into declarations with explicit array
  types:
  */

  rule T:Type X:Exp[N:Int]; => X of array of N T;

  /*@
   Semantics of an array declaration:
  */
  rule <k> X:Id of array of N:Int T:Type;
           =>
           .
       ...</k>
       <env>... . => X |-> seq-array(N, L) </env>
       <br/>
       <store>... . => seq-array(N, L) |-> const-array(N, 0) ...</store>
       when fresh(L:Loc)


  /*@
   Updating an array component:
  */
 
  rule <k> $update(select(L:Loc, I:Int), V:Val) => . ...</k>
       <store>... L |-> (A:Array => store(A, I, V)) ...</store>
       [kripke(update)]

  /*@
    Reading an array component:
   */

  rule <k> $lookup(select(L:Loc, I:Int)) => select(A, I) ...</k>
       <store>... L |-> A:Array ...</store>
       [kripke(mem-lookup)]

  /*@
    Indirection to an array component:
  */

  rule <k> * select(L:Loc, I) => select(A, I) ...</k>
       <store>... L |-> A:Array ...</store>


  /*@ 
  Arrays as parameters:
  */

  context evaluate (HOLE, _:Exp) to _
          following (T _:Exp[_:Exp], _:Decls);

  context evaluate (HOLE, _:Exp) to _
          following (T _:Exp[], _:Decls);

  rule <k>
          bind((lval(L:Loc), Vs) => Vs) to((T X:Id[], Xl:Decls) => Xl); 
       ...</k>
       <env> Env:Map => Env[L/X] </env>
       [structural]

   //@ Interface with SMTLIB:

  rule K2SMTLib(seq-array(N:Int, L:Loc ))
       =>
       "const-array (" +String K2SMTLib(N) +String "," +String K2SMTLib(N)  +String ")"

endmodule

