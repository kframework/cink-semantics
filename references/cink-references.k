require "../basic/cink-basic-syntax.k"
require "../basic/cink-basic-semantics.k"


/*@ \section{The New Modules} */

module CINK-REFERENCES-SYNTAX

  imports CINK-BASIC-SYNTAX

  syntax Exp ::= "&" Exp [strict, ampersand]

  syntax priorities  ampersand > assign read write greatthan lessequal

endmodule

module CINK-REFERENCES-SEMANTICS

  imports CINK-REFERENCES-SYNTAX
  imports CINK-BASIC-SEMANTICS

  /*@ Reference type: */

  syntax RefType ::= "reference" "to" Type 

  syntax Type ::= RefType

  /*@ Extend the declarations with "refrence to type" type */

  syntax Decl ::= Exp "of" RefType

  syntax Stmt ::= Exp "of" RefType "=" Exp ";"

  /*@ Desugaring the type of a declaration */
  rule T:Type & X:Exp => X of reference to T [macro]

  /*@ Declaration of an alias */

  context _:Exp of reference to _:Type; ~> &_ = HOLE;

  rule <k> X:Id of reference to _:Type; ~> & X = lval(L:Loc); => . ...</k>
       <env> Env:Map => Env[L/X] </env>

  /*@ The type of "\& L" is "pointer to the type of L" (\Cpp manual, 5.3.1),
   hence the type of "* \& L" is "type of L". L is evaluated as an
   rvalue that implies that the result is the value stored at L. */

  rule & lval(L:Loc) => L 
  
/*@
  For a formal parameter declared with the call-by-reference mechanism,
  the corresponding argument expression must be evaluated to an lvalue.
From the \Cpp manual:
\begin{quote}
a function can change the values of its non-const parameters, 
but these changes cannot affect the
values of the arguments except where a parameter is of a reference 
type (8.3.2)\ldots
\end{quote}
*/


  context evaluate(HOLE, _:Exp) to _
          following  (_:Id of reference to _:Type, _:Decls);



 /*@ For call-by-reference, the location pointed to by the lvalue is directly
      bound to the formal parameter. This is achieved by exactly one rule:
  */

  rule <k> bind((lval(L:Loc), Vs) => Vs)
           to((X:Id of reference to T:Type, Xl:Decls) => Xl); 
       ...</k>
       <env> Env:Map => Env[L/X] </env> 

endmodule
