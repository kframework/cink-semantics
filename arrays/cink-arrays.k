require "../pointers/cink-pointers.k"

module CINK-ARRAYS-SYNTAX

/*@ 
The syntax consists of the syntax of basic constructs together with the syntax
of arrays: 
*/

  syntax Exp ::= Exp "[" Exp "]" [strict(1, 2(context(rvalue), result(Int))),
                                  array]
               | Exp "[]" [array] 

  syntax priorities  array > multiply read write greatthan lessequal
  syntax priority  array > assign

endmodule

module CINK-ARRAYS-SEMANTICS

/*@ \section{Semantics}
The semantics consists of the semantics of basic constructs together with the
that of arrays and the definition of the whole configuration: 
*/

  imports CINK-ARRAYS-SYNTAX
  imports CINK-BASIC-SEMANTICS
  imports CINK-POINTERS-SEMANTICS
  imports ARRAY

  /*@
  First we define array types following the the notation convention from
  the manual. 
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

  rule T:Type X:Exp[N:Int]; => X of array of N T;

  rule X:Exp[N:Int] of AT:ArrType; => X of array of N AT;

  /*@
  The arrays are expressions
  */
  syntax Exp ::= Array

  /*@
  An array \texttt{a[2][3]} will be represented as follows:
  \begin{verbatim}
  <env>
    a[0] |-> #symLoc(2)[0]
    a[1] |-> #symLoc(2)[1]
    a |-> #symLoc(2)
  </env>
  <store>
    #symLoc(2) |-> store(store(const-array(3, undefined),
                               0, #symLoc(2)[0]),
                               1, #symLoc(2)[1])
        #symLoc(2)[0] |-> store(store(store(const-array(3, undefined),
                               0, #symLoc(2)[0][0]),
                               0, #symLoc(2)[0][1]),
                               1, #symLoc(2)[0][2])
        #symLoc(2)[0][0] |-> 0
        #symLoc(2)[0][1] |-> 0
        #symLoc(2)[0][2] |-> 0
        #symLoc(2)[1] |-> store(store(store(const-array(3, undefined),
                               0, #symLoc(2)[1][0]),
                               0, #symLoc(2)[1][1]),
                               1, #symLoc(2)[1][2])
        #symLoc(2)[1][0] |-> 0
        #symLoc(2)[1][1] |-> 0
        #symLoc(2)[1][2] |-> 0
    </store>
  \end{verbatim}
  Since the definition of the multidimensional array is recursive, the 
  allocation is described by a recursive function:
  */
  syntax K ::= "alloc" "(" Stmt "," Int ")" 

  /*@
  The initial call:
  */
  rule <k> X:Id of array of N:Int T:Type;
           =>
           alloc(X of array of N T;, 0)
       ...</k>
       <env>... . => X |-> L </env>
       <store>... . => L |-> const-array(N, 0) </store>
       when fresh(L:Loc)

  /*@
  The recursive case, when $X$ denotes a $N$-dimensional array with $N\ge 2$:
  */
  syntax Loc ::= Loc "[" Int "]"

  rule lval(L:Loc)[I:Int] => lval(L[I])

  rule L:Loc[I:Int] + J:Int => L[I +Int J]

  rule [side-effect] :
       <k> $inc(L:Loc) => . ...</k>
       <store>... L |-> (L':Loc[I:Int] => L'[I +Int 1]) ...</store>
       [side-effect(inc)]


  rule [side-effect] :
       <k> $dec(L:Loc) => . ...</k>
       <store>... L |-> (L':Loc[I:Int] => L'[I -Int 1]) ...</store>
       [side-effect(dec)]

  rule <k> alloc(X:Exp of array of N:Int array of N':Int T:Type;, I:Int)
           =>
           alloc(X[I] of array of N' T;, 0) ~>
           alloc(X of array of N array of N':Int T;, I +Int 1)
       ...</k>
       <env>... X |-> L:Loc (. => X[I] |-> L[I]) </env>
       <store>...
              (L:Loc |-> (A:Array => store(A, I, L[I])))
              (. =>  L[I] |-> const-array(N', 0))
       ...</store>
       when (I <Int N)

  /*@
   The base case when all components given by the current index
  are allocated:
  */ 
  rule alloc(X:Exp of array of N:Int AT:ArrType;, I:Int) => .
       when (I >=Int N)

  /*@
   The base case when X denotes a unidimensional array:
  */ 

  rule <k> alloc(X:Exp of array of N:Int T:Type;, I:Int)
           =>
           alloc(X of array of N T;, I +Int 1)
       ...</k>
       <env>... X |-> L (. => X[I] |-> L[I]) </env>
       <store>...
              (L:Loc |-> (A:Array => store(A, I, L[I])))
              (. =>  L[I] |-> 0)
       ...</store>
       when (isArrType(T) =/=K true) andBool (I <Int N)

  /*@
   The base case when all components of the current unidimensional array 
  are allocated:
  */ 

  rule <k> alloc(X:Exp of array of N:Int T:Type;, I:Int)
           =>
           .
       ...</k>
       when (I >=Int N) andBool isArrType(T) =/=K true


  /*@
  The evaluation of an array component as a lvalue:
  */

  rule A:Array [I:Int] => A + I    // for conformance

  rule A:Array + I:Int => select(A, I) 


  /*@ 
  Arrays as parameters:
  */

  context evaluate (HOLE, _:Exp) to _
          following (T _:Exp[], _:Decls);

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

endmodule

