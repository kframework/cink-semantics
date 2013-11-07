require "cink-basic-syntax.k"

module CINK-BASIC-SEMANTICS
  imports CINK-BASIC-SYNTAX

  /*@ \subsection{Values.} 
    The values are a very important syntactic category in the definition
    of any language; with them, we are able to know when the evaluation
    of an expression is finished. This piece of information is crucial, e.g.,
    for the heating and cooling rules. 
    We already defined the subset of values that is part of the syntax, 
    namely the values given by the primitive types. Here we estend the set
    o values with intermediate constructs needed to execute programs. 
    Such a value is\texttt{noVal}, which "paradoxally" denotes in fact 
    "no value". The lambda abstractions are used for storing the
    functions. Similar to other \K examples (IMP, IMPPP, SIMPLE), the 
    functions are stored similar to variables and therefore their definitions
    are seen as values.
    As usual, all values must be subsorted to the \texttt{KResult} sort.
   */


  syntax RVal ::= "noVal" 
               | "lambda" "(" Decls "@" Stmts ")" 
                 [latex(\lambda\,{#1}\mathrel{\bullet}{#2})]

  syntax Val ::= lval(Ref)

  syntax Vals ::= List{Val,","}

  syntax KResult ::= Val

  /*@
    \subsection{Lvalues and Rvalues}
    We first deal only with lvalues and prvalues. In order to keep the definition
    as simple as possible, we let the the lvalue as the default category for 
    expressions and we make explicitly only the category of prvalue expressions:
  */
  
  syntax Exp ::= "rvalue" "(" Exp ")" [strict, klabel(rvalue)]

  /*@
    As its definition says, the main operator emphasiszing the two categories is
    the assignment. We use a context declaration to say that the left-hand side 
    of the assignemnt is a lvalue (by default):
  */

  context HOLE = _:Exp


  //@ When an l-value is in an r-value context, evaluate it
  rule <k> rvalue(lval(L:Ref) => V) ...</k>
       <store>... L |-> V:RVal ...</store>

 /*@ \subsection{Seqpoints}

  /*@
    Sequence points are specific to languages where the evaluation of the
    expressions has side effects. Obviously, this is the case for C and \Cpp
    languages. Here is the definition for sequenced before from \Cpp manual:

\begin{quote}
  \emph{Sequenced before} is an asymmetric, transitive, pair-wise relation 
  between evaluations executed by a single
   thread (1.10), which induces a partial order among those evaluations.
   Given any two evaluations A and B, if
   A is sequenced before B, then the execution of A shall precede the execution
   of B. If A is not sequenced before
   B and B is not sequenced before A, then A and B are unsequenced.
  [ Note: The execution of unsequenced
   evaluations can overlap. — end note ] Evaluations A and B are 
  indeterminately sequenced when either A
   is sequenced before B or B is sequenced before A, but it is unspecified 
  which.
  [ Note: Indeterminately
   sequenced evaluations cannot overlap, but either could be executed first.
   — end note ]\\
  Every value computation and side effect associated with a full-expression
  is sequenced before every value
  computation and side effect associated with the next full-expression
  to be evaluated.\\
  Except where noted, evaluations of operands of individual operators and of 
  subexpressions of individual expressions are unsequenced.\\
  [Note: In an expression that is evaluated more than once during the execution
  of a program, unsequenced and indeterminately sequenced evaluations of its 
  subexpressions need not be performed consistently in different evaluations.
  —end note]\\
  The value computations of the operands of an operator are sequenced before
  the value computation of the result of the operator. If a side effect on a
  scalar object is unsequenced relative to either another side effect on the
  same scalar object or a value computation using the value of the same scalar
  object, the behavior is undefined.
\end{quote}
    In this iteration we define a minimal support for the sequent points.
    The semantics of a sequence point (when a full-expression is sequenced):
    the sequence of the side effects is moved from the its cell to the top of
    the k cell. The side-effects are executed in the reverse order they were
    evaluated.
  */

  syntax K ::= "seqpoint"

  rule <k> seqpoint => SE ...</k>
       <sideEffects> SE => . </sideEffects>

  //@ textcolor{red}{TDB: explain "undefined" expression.}

  syntax Exp ::= "undefined"


  /*@ \subsection{Memory Locations}
   We use (automatically generated) symbolic values for locations.
   These are of sort \texttt{Loc}. The locations are by definition lvalues.
   */


  syntax Loc ::= "noLoc"
  syntax Ref ::= Loc 


  /*@ \subsection{Auxiliary constructs.} */


  /*@
    \texttt{execute} is used to start the computation of a program; and
    \texttt{noname} for the initial name of a thread.
  */
  syntax K ::= "execute"

 /*@
   The next two constructors are used for storing the enavironment and the
   rest of the computation in the call stack (\texttt{fstack}). 
 */

  syntax ListItem ::= "(" List "," K ")"
                    | "[" Map "]"

 /*@ \subsection{Configuration.} 
   Since \Cink is developed in iterations, each such iteration will have its
   own configuration. In order to have a modular definition, each module 
   adding semantics for several feature will include a minimal configuration
   needed to define these features.
   The following cells are used to give semantics for the basic constructs:
  */

/*
  configuration   <k color="green"> ($PGM:Pgm ~> execute) </k>
                  <env color="LightSkyBlue"> .Map </env>
                  <fstack color="orange"> .List </fstack>
                  <br/>
                  <genv color="SkyBlue"> .Map </genv>
                  <store color="white"> .Map </store>
                  <in color="magenta" stream="stdin"> .List </in>
                  <out color="Orchid" stream="stdout"> .List </out>

*/

  /*@
    In order to have a minimal set of rules, some syntactic constructs
    are desugared. The desugaring can be done using the structural rules.
   */

  /*@ The desugaring rule for the if-then statement: */
  rule if(B:Exp) St:Stmt => if(B) St else {}  [macro]
  
  /*@
    The desugaring rule for statements declaring multiple variables.
   */

  rule T:Type E:Exp, E':Exp, Es:Exps ; => T E; T E'; T Es; [macro]

 /*@
    Desugaring rule for variable declarations with initialization.
    The alias declarations are defined later, together with the pointers.
  */

   rule T:Type E1:Exp = E2:Exp ; => T E1; E1 = E2;
        when isAliasExp(E1) =/=K true
        [macro]


  /*@ \subsection{Declarations.} */

  /*@
    Function declaration: a function is a stored similar to a variable,
    where the value stored in the associated location is the lambda
    abstraction of the function. 
   */


  rule <k>  (Decl:Decl (Xl:Decls) {Sts:Stmts})::Stmt  => .  ...</k> 
       <env>... . =>  (getName(Decl) |-> L) ...</env>
       <store>... . => (L |-> lambda(Xl @ Sts)) ...</store>
       when fresh(L:Loc)
       [fun-decl, structural]

  /*@
    The rules for variable declarations:
   */

  rule [var-decl] :
       <k> T:PrimType X:Id; => .  ...</k>      
       <env> Env:Map => Env[L/X] </env>
       <store>... . => (L |-> undefined) ...</store>
  when fresh(L:Loc)
       [structural]

  rule T:Type .Exps; => . [structural]


  /*@ The following two constructs have no semantics yet;
      they are used now only  for having a full compatibility with \Cpp,
      e.g., the \Cink programs can be 
      compiled with a \Cpp compiler. */
  rule #include <iostream> => . 
       [include, structural]

  rule using namespace std;=> .
       [using, structural]

  /*@ 
    The auxiliary construct \texttt{execute} is used to initialize the 
    execution of a program, which for the case of \Cink consists of the call
    of the main function.
  */

  rule <k> execute => String2Id("main")(.Vals); </k>
       <env> Env:Map </env>
       <genv> . => Env:Map </genv>
       [main, structural]
  
  /*@ \subsection{Expressions Evaluation.} */

  /*@
   The following expressions are strict. 
  */
  rule I1:Int + I2:Int => I1 +Int I2 [plus]

  rule I1:Int - I2:Int => I1 -Int I2 

  rule I1:Int * I2:Int => I1 *Int I2

  rule I1:Int / I2:Int => I1 /Int I2 when I2 =/=Int 0
 
  rule I1:Int % I2:Int => I1 %Int I2 when I2 =/=Int 0

  rule I1:Int < I2:Int => (I1 <Int I2)

  rule I1:Int > I2:Int => (I1 >Int I2)

  rule I1:Int <= I2:Int => (I1 <=Int I2)

  rule I1:Int == I2:Int => (I1 ==Int I2)
 
  rule true && B:Exp => B
  rule false && B:Exp => false
  rule true || B:Exp => true
  rule false || B:Exp => B 
  rule ! false  => true
  rule ! true => false 

  rule endl => "\n" [structural]


  /*@ \subsection{Memmory operations.} */


  /*@
    The evaluation of a variable name as an lvalue:
  */
  rule <k> X:Id => lval(L) ...</k>
       <env>... X |-> L:Loc ...</env>
       [kripke(mem-lookup)]

  /*@
    The memory update is given by the assignment operator.
    An assignemnt, after the reduction of the arguments, has in the lef-hand
    side a location ($=$ the lvalue designated by the lhs.) and in the 
    right-hand side an rvalue.
    From \Cpp manual:
\begin{quote}
The assignment operator (=) and the compound assignment operators all group
 right-to-left. All require a modifiable lvalue as their left operand and 
return an lvalue referring to the left operand. The result in all
cases is a bit-field if the left operand is a bit-field. In all cases,
 the assignment is sequenced after the value computation of the right and 
left operands, and before the value computation of the assignment expression.
With respect to an indeterminately-sequenced function call, the operation of
 a compound assignment is a single evaluation.\\
[ Note: Therefore, a function call shall not intervene between the 
lvalue-to-rvalue conversion and the side effect associated with any single 
compound assignment operator. —end note ]
\end{quote}
  */

  syntax K ::= "update" "(" Ref "," Val ")"

  rule lval(L:Ref) = V:Val => seqpoint ~> update(L, V)

  rule [update] : <k> update(L:Loc, V:Val)  => lval(L) ...</k>
       <store>... L |-> (_ => V) ...</store>
       [update, kripke]

  /*@


  /* \subsection{Control Statements.} */

  /*@
    As usual, the \texttt{while} statement is desugared using the 
    \texttt{if-then-else} statement.
  */
  rule while(B:Exp) St:Stmt => if (B) {St while(B) St} else {}
       [while, structural]

  /*@
    Since \texttt{if} is strict in the first argument, which is a boolean
    expression, proceed by case-analysis on the result values:
  */
  rule if(false) _ else St:Stmt => St [if-false]
  rule if(true) St:Stmt else _ => St [if-true]


  /*@
    The semantics of the expression statement consists of removing the
    value obtained by evaluating the expression. Recall that the statement
    is strict.
   */
  rule <k> (V:Val; ~> K:K) => K </k> 
       when K =/=K .K
       [instr-expr]
  /*@
    Block. Note that in this iteration we assume that the blocks do not include
    variable declarations. This will be added in a future iteration.\\
      -- the case of non-empty block
  */
  rule { Sts:Stmts } => Sts
       [block, structural]

  /*@ -- the case of the empty block: */
  rule {} => .  [block-empty, structural]

  //@ The sequential composition is just a sequence of computations:
  rule (Sts:Stmts Sts':Stmts) => (Sts ~> Sts')
       [seq-comp, structural] 

//  rule .Stmts => .K

  /*@ \subsection{Input/Output Statements.} */

  /*@ Writting in the the standard stream \texttt{cout}: */

  context cout << (HOLE => rvalue(HOLE)) [result(RVal)] 

// these should be the rules for the above context declaration (we have to add the default result sort for rvalue):
/* 
  rule cout << E:Exp => rvalue(E) ~> cout << HOLE [heat]

  rule rvalue(V:RVal) ~> cout << HOLE => cout << V [cool]
*/
  rule <k> cout << V:RVal => cout  ...</k>  
       <out>... . => (ListItem(V) ListItem(" ")) </out>
       [print-stream, print]

  /*@
   In order to read from the standard stream \texttt{cin}, the expression
   from the right-hand side must be evaluated to an l-value:
  */
  context cin >> HOLE

  rule <k> cin >> lval(L:Loc) => cin  ...</k>
       <store>... L |-> (_ => V)  ...</store>
       <in> (ListItem(V:Int) => .)  ...</in>
       [read-stream]


  /*@
    \subsection{The function call expression}
    The function name is evaluated to its value, which is a lambda 
    abstraction: $\it Xl$ is the list of parameters, $\it Sts$ is body of
    the function. The {\sc function-call} rule pushes the calling context,
    i.e., the remainder of the computation $K$ and environment stack 
    (including the current environment) on top of the function stack, 
    while the {\sc return} rule uses the information there to restore 
    the environment and computation of the caller.
    Since the evaluation strategy for the second argument is depending on
    the binding specification in the function signature, the function call
    expression is declared strict only in its first argument.
    Note that in this iteration we consider only the call-by-value 
    binding mechanism. The call-by-reference mechanism will be considered
    in a future iteration.
  /*

/*@
From the \Cpp manual:
\begin{quote}
When a function is called, each parameter (8.3.5) shall be initialized 
(8.5, 12.8, 12.1) with its corresponding
argument. [ Note: Such initializations are indeterminately sequenced with 
respect to each other (1.9) - end note ] \ldots\\  
When a function is called, the parameters that have object 
type shall have completely-defined
object type. \ldots \\
During the initialization of a parameter, an implementation may avoid the 
construction of extra temporaries by
combining the conversions on the associated argument and/or the construction
of temporaries with thevinitialization of the parameter (see 12.2). 
The lifetime of a parameter ends when the function in which it
is defined returns. The initialization and destruction of each parameter 
occurs within the context of the calling function.
\ldots\\{}
[ Note: a function can change the values of its non-const parameters, 
but these changes cannot affect the
values of the arguments except where a parameter is of a reference 
type (8.3.2)\ldots
\end{quote}
*/

  /*@
    The rule defining the evaluation of a function call expression evaluates
    first the actual parameters, and then binds the 
    values to the formal parameters and executes the body, while saving the
    calling context in case of an abrupt return. This is done by mimic the
    heating-cooling mechanism (the first rule is a heating-like one, and the
    second a cooling-like one).
   */

  rule <k> lambda(Xl:Decls @ Sts:Stmts)(El:Exps)
           =>
           evaluate El to .Vals following Xl; ~>
           lambda(Xl:Decls @ Sts:Stmts)(HOLE)
       ...</k> 

  rule <k> (Vl:Vals ~> lambda(Xl:Decls @ Sts:Stmts)(HOLE) ~> K:K)
           => 
           (bind Vl to Xl; ~> Sts ~> return noVal;)
       </k>
       <br/>
       <genv> GEnv:Map </genv>
       <env> Env:Map => GEnv </env>
       <fstack> . => ([Env], K) ...</fstack>
       [fun-call]

  /*@
    To evaluate actual parameters according to their declared strategy we will
    make use of the power of \K evaluation contexts. 
    The actual parameters must be evaluated using 
    the $\terminalNoSpace{evaluate}$ construct and $\terminalNoSpace{following}$ 
    the list of formal parameters.
  */

  syntax Exps ::= "evaluate" Exps "to" Vals "following" Decls ";"

  /*@
    For a formal parameter declared with the call-by-value mechanism,
    the corresponding argument expression must be evaluated to an rvalue as
    specified by by the following contextual declaration:
  */

  context evaluate (HOLE, _:Exps) to _:Vals following (T X:Id, _:Decls);


  /*@
    \noindent This second context uses again the special type of context used
    above for $\terminalNoSpace{evaluate}$, by requesting that the expression
    on position $\khole{}$ be evaluated as an lvalue.
    \par
    The following two rules, together with the strict evaluation strategy for
    lists of expressions complete the semantics of $\terminalNoSpace{evaluate}$
    by recursing into the lists:
  */


  rule evaluate(V:Val, El:Exps => El) to (Vl:Vals => append(Vl, V))
         following (Dec:Decl, Xl:Decls => Xl);
       [structural]
   
  rule evaluate .Exps to Vl:Vals following .Decls; => Vl [structural]

   /*@
     \subsubsection{Binding mechanisms}
     Similarly to the evaluation rules, the binding rules are also different 
     for the two parameter passing styles.
     As we have already seen, the binding is performed using an auxiliary 
     construction:
   */

  syntax K ::= "bind" Vals "to" Decls ";"  

  /*@
  For call-by-value, the passed value $V$ is stored into a new memory location
  which is bound to the formal parameter:
  */
 
  rule <k> bind((V:Val, Vs:Vals) => Vs)
           to((T X:Id, Xl:Decls) => Xl); 
       ...</k>
       <env> Env:Map => Env[L/X] </env>
       <store>... . => L |-> V ...</store>
  when fresh(L:Loc)
       [structural]

  /*@
    Finally, once all parameters have been bound, the binding construct 
    dissolves:
   */
  rule bind .Vals to .Decls; => . [ structural ]

  /*@
    \subsection{Function Return.}
    Similar to \Cpp, the argument of a return statement is a list of
    expressions (note that Cink does not have yet a distinguished
    definition for the comma operator). 
  */

  /*@
    Similar to the comma operator, the evaluation of the return argument
    is given from left to right. Since the expression lists are strict,
    we get this feature for free provided the declaration for return is
    strict. Remains oly to write rules keeping the last value from the list.
  */

  rule return _:RVal, V:RVal, Vs:Vals ; => return V, Vs ; 
       [return]

  rule <k> (return V:RVal; ~> _) => (V ~> K) </k>
       <env> _ => Env </env>
       <fstack> ([Env:Map], K:K) => . ...</fstack>
       [return]

  /*@
    \subsection{Auxiliary Functions and Rules.}
    Here we winclude the semantics for the auxiliary constructs, used to give
    semnatics for \Cink.\\
    The "alias" are used for declaring aliases for the variables; their semantics 
    is given in the iteration that adds the pointers. 
  */

  syntax Bool ::= "isAliasExp" "(" Exp ")" [function]

  /*@
    The next operator returns the variable name from an expression occurring
    in a declaration:
  */
  syntax  Id ::= "getName" "(" K ")" [function]

  rule getName(X:Id) => X
  rule getName(T:Type E:Exp) => getName(E)
  rule getName(E1:Exp = E2:Exp) => getName(E1)

  //@ Append function:

  syntax Vals ::= "append" "(" Vals "," Val ")" [function]
  rule append(.Vals, V:Val) => V, .Vals
  rule append((V':Val, Vl:Vals), V:Val) => V', append(Vl, V)

endmodule
