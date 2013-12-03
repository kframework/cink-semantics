require "../basic/cink-basic-syntax.k"
require "../basic/cink-basic-semantics.k"

module CINK-REFERENCES-SYNTAX

  imports CINK-BASIC-SYNTAX

  /*@ From the \Cpp manual (5.3.1):\\
  \begin{quote}
    The result of the unary \& operator is a pointer to its operand. 
    The operand shall be an lvalue or a qualifiedid.
    If the operand is a qualified-id naming a non-static member m of some class 
    C with type T, the result has type “pointer to member of class C of type T” 
    and is a prvalue designating C::m. Otherwise, if the type of
    the expression is T, the result has type “pointer to T” and is a prvalue 
    that is the address of the designated object (1.7) or a pointer to
    the designated function.
  \end{quote}
  So, the \texttt{strict} is just what we need for the ampersand operator:
  */

  syntax Exp ::= "&" Exp [strict, ampersand]

  syntax priorities  ampersand > assign read write greatthan lessequal

endmodule

module CINK-REFERENCES-SEMANTICS

  imports CINK-REFERENCES-SYNTAX
  imports CINK-BASIC-SEMANTICS

  //@ Extension of the getName function:

  rule getName(& E:Exp) => getName(E) 

  /*@ Reference type: */

  syntax RefType ::= "reference" "to" Type 

  syntax Type ::= RefType

  /*@ Extend the declarations with "reference to type" type: */

  syntax Decl ::= Exp "of" RefType

  syntax Stmt ::= Exp "of" RefType "=" Exp ";"

  /*@ Desugaring the type of a declaration: */

  rule T:Type & X:Exp => X of reference to T [macro]

  /*@ Declaration of an alias: */

  context _ of reference to _:Type; ~> _ = HOLE;

  rule <k> X:Id of reference to _:Type; ~> X = lval(L:Loc); => . ...</k>
       <env> Env:Map => Env[L/X] </env>

  /*@ The evaluation of the ampersand operator returns the lvalue computed
    by the heating/cooling rules.
   */

  rule & lval(L:Loc) => L 
  
/*@

  \subsection{Call by Reference}
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
