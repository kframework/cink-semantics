require "../pointers/cink-pointers.k"

module CINK-ARRAYS-SYNTAX

/*@ 
The syntax consists of the syntax of basic constructs together with the syntax
of arrays: 
*/

  syntax Exp ::= Exp "[" Exp "]" [strict(1, 2(context(rvalue), result(Int))),
                                  array]
               | Exp "[]" [array] 

  syntax priorities  array > ampersand multiply read write greatthan lessequal
  syntax priority  array > assign

  //@ Extend TypeSpec with arrays

  syntax TypeSpec ::= TypeSpec "[" Exp "]" 

endmodule

module CINK-ARRAYS-SEMANTICS

/*@ 
The semantics consists of the semantics of basic constructs together with the
that of arrays and the definition of the whole configuration: 
*/

  imports CINK-ARRAYS-SYNTAX
  imports CINK-BASIC-SEMANTICS
  imports CINK-POINTERS-SEMANTICS
  imports ARRAY

  /*@

   The memory model defined for unidimensional arrays can be extended to 
   multidimensional arrays.
   A $2\times 3$ array $\{\{2, 4, 6\}, \{3, 5, 7\}\}$ is represented as:
   \begin{verbatim}
      seq-array(2, L) |-> array of 2 array of 3 int
     
      select(seq-array(2, L), 0)
      |-> 
      store(store(store(const-array(3, 0), 0, 2), 1, 4), 2, 6)

      select(seq-array(2, L), 1)
      |-> 
      store(store(store(const-array(3, 0), 0, 3), 1, 5), 2, 7)
   \end{verbatim}
  where \texttt{array of 3 int)} is replaced first by \texttt{const-array(3, 0)}
  and then component-wise updated.

  The arrays can be converted to pointers.
  From the \Cpp manual:
  \begin{quote}
  An lvalue or rvalue of type “array of N T” or “array of unknown bound of T”
  can be converted to a prvalue of type “pointer to T”. 
  The result is a pointer to the first element of the array.
  \end{quote}
  Therefore the pointer arithmetic is extended over array locations:

   $L[I] + V = \texttt{select}(\texttt{seq-array}(N, L),I+V)$,\\
   $++ L[I] = \texttt{select}(\texttt{seq-array}(N, L),I+1)$,\\
   $-- L[I] = \texttt{select}(\texttt{seq-array}(N, L),I-1)$\\
   $L[0][0] + N*I + J 
     = \texttt{select}(\texttt{select}(\texttt{seq-array}(N, L),I), J)$

   We do not consider yet conversions of the form L -> L[0][0]; we discuss
  later, when we introduce type system and casting.
  */


  syntax SeqLoc ::= "seq-array" "(" Int "," Loc ")"
  syntax Loc ::= SeqLoc

  //@ Extend select over sequences of locations


  syntax Loc ::= "select" "(" Loc "," Int ")" [smtlib(select)]

  rule lval(L:SeqLoc)[I:Int] => lval(select(L, I))

  rule select(L:Loc, I:Int) + J:Int => select(L, I +Int J)

  rule <k> $inc(L:Loc, V:Int) => . ...</k>
       <store>... L |-> select(_:Loc, (I:Int => I +Int V))...</store>
       [side-effect(inc)]

  rule <k> $dec(L:Loc, V:Int) => . ...</k>
       <store>... L |-> select(_:Loc, (I:Int => I -Int V))...</store>
       [side-effect(inc)]

  rule select(L:Loc, I:Int) <= select(L, J:Int) => I <=Int J
  rule select(L:Loc, I:Int) < select(L, J:Int) => I <Int J
  rule select(L:Loc, I:Int) > select(L, J:Int) => I >Int J

  /*@
  We define array types following the the notation convention from the manual. 
  We call these type \emph{explicit array types}. Note that these have a 
  recursive definition.  
  We also extends statements with declaration of variable (expression)
  of the new type.
  */

  syntax ArrType ::= "array" "of" Int Type 
  syntax Type ::= ArrType
  syntax Stmt ::= Exp "of" ArrType ";"

  /*@
  The array declaration are translated into declaration with explicit array
  types.
  */

  context _:Type _:Exp[(HOLE => rvalue(HOLE))]; [result(Int)]

  rule T:Type X:Exp[N:Int]; => X of array of N T;

  rule X:Exp[N:Int] of AT:ArrType; => X of array of N AT;

  /*@
  The arrays are values:
  */
//  syntax Val ::= Array

  syntax Exp ::= Array

  //@ An updated array is a value:

  rule isVal(store(_,_,_)) => true

  /*@
   Declaration of a multidimensional array:
  */
  rule <k> X:Id of array of N:Int T:Type;
           =>
           .
       ...</k>
       <env>... . => X |-> seq-array(N, L) </env>
       <br/>
       <store>...
          . => seq-array(N, L) |-> array of N T 
       ...</store>
       requires fresh(L:Loc)

  //@ Arrays of scalar type are zero-initialized, so they are well defined:

  rule  <store>... _ |-> (array of N:Int T:ScalType => const-array(N, 0)) ...</store>


  //@ The case of a component of a  multimensional array, the first access:

  rule <k> lval(select(L:Loc, I:Int))[J:Int] => lval(select(select(L, I), J)) ...</k>
       <store>
          ST:Map  L |-> array of N:Int T:Type
          (. => select(L, I) |-> T)
       ...</store>
       requires notBool select(L, I) in keys(ST)
 //     [transition]  // it must be here for now

  //@ \ldots and the case when the component is already allocated:

  rule <k> lval(select(L:Loc, I:Int))[J:Int] => lval(select(select(L, I), J)) ...</k>
       <store>... select(L, I) |-> _ ...</store>


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

//  rule <k> * select(L:Loc, I) => select(A, I) ...</k>
//       <store>... L |-> A:Array ...</store>

  /*@ 
  Arrays as parameters:
  */

  context evaluate (HOLE, _:Exp) to _
          following (T _:Exp[], _:Decls); [result(Val)]

  context evaluate (HOLE, _:Exp) to _
          following (T _:Exp[_:Exp], _:Decls);

  rule <k>
       bind((lval(L:Loc), Vs) => Vs) to((T X:Id[], Xl:Decls) => Xl); 
       ...</k>
       <env> Env:Map => Env[L/X] </env>
       [structural]

  rule bind(lval(L:Loc), Vs) to (T X:Exp[_:Exp], Xl:Decls); 
       =>
       bind(lval(L), Vs) to (T X, Xl:Decls); 
       [structural]

  rule bind(lval(L:Loc), Vs) to (T X:Exp[][], Xl:Decls); 
       =>
       bind(lval(L), Vs) to (T X[], Xl:Decls); 
       [structural]

   //@ Interface with SMTLIB:

  rule K2SMTLib(seq-array(N:Int, L:Loc ))
       =>
       "const-array (" +String K2SMTLib(N) +String "," +String K2SMTLib(N)  +String ")"


endmodule

