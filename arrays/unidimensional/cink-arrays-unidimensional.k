
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
   We extend the memory model with contiguous sequences of locations. Such
   sequnces are represented by using the theory of arrays.
   We assume the reader familiar with this theory. 
   Here is its definition included in 
   \texttt{include/builtins/array.k}:
   \begin{asciik}
     syntax Array ::= "store"       "(" Array "," Int "," K ")" 
                    | "const-array" "(" Int "," K ")" 
		 
     syntax K ::= "select" "(" Array "," Int ")" 
     syntax Int ::= "size-of-array" "(" Array ")"

    rule select(store(_:Array, I:Int, V:K), J:Int) => V 
         requires I ==Int J

    rule select(store(A:Array, I:Int, _:K), J:Int) => select(A, J)
         requires I =/=Int J 

    rule select(const-array(Size:Int, V:K), I:Int) => V
         requires (0 <=Int I) andBool (I <Int Size) 
   \end{asciik}

   We explain the main idea by means of an example showing how a sequence of 
   three locations storing the sequence of integers (5,3, 8) is represented 
   by the map:
   \begin{verbatim}
      seq-array(3, L)
      |-> 
      store(store(store(const-array(3, 0), 0, 5), 1, 3), 2, 8)
    \end{verbatim}
   where \texttt{seq-array(3, L)} is a sugar syntax for\\
   \texttt{store(store(store(const-array(5, 0), 0, L[0]), 1, L[1]), 2, L[2])}.

   Moreover, we have a piece of pointer arithmetic over these locations:\\
   $L[I] + V = \texttt{select}(\texttt{seq-array}(N, L),I+V)$,\\
   $++ L[I] = \texttt{select}(\texttt{seq-array}(N, L),I+1)$,\\
   $-- L[I] = \texttt{select}(\texttt{seq-array}(N, L),I-1)$.

   The lvalue of $L[I]$ is $\texttt{select}(\texttt{seq-array}(N, L),I)$, 
   and the rvalue of $L[I]$ is $\texttt{select}(A,I)$, where
   $\texttt{seq-array}(N, L),I)\texttt{ |-> } A$\texttt{:Array}.

  */
  syntax SeqLoc ::= "seq-array" "(" Int "," Loc ")"
  syntax Loc ::= SeqLoc


  // a "seq-array" is in fact a "const-array" special (this should be done in 
  //  K2SMTLIB)
//  rule isSeqLoc(const-array(_:Int, _:Loc)) => true 
//  rule seq-array(N:Int, L:Loc) => const-array(N, L) [anywhere]


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

