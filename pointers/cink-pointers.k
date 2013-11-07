require "../basic/cink-basic-syntax.k"
require "../basic/cink-basic-semantics.k"


/*@ \section{The New Modules} */

module CINK-POINTERS-SYNTAX

  imports CINK-BASIC-SYNTAX

  syntax Exp ::= "*" Exp [strict, context(rvalue), result(Ref), indirect]
               | "&" Exp [strict, ampersand]

  syntax priorities  indirect  > assign read write greatthan lessequal
  syntax priorities  ampersand > assign read write greatthan lessequal

endmodule

module CINK-POINTERS-SEMANTICS

  imports CINK-POINTERS-SYNTAX
  imports CINK-BASIC-SEMANTICS

  /*@ Pointer type: */

  syntax PtrType ::= "pointer" "to" Type 

  syntax Type ::= PtrType

  /*@ Extend the declarations with "pointer to type" type */

  syntax Stmt ::= Exp "of" PtrType ";"


  /*@ Desugaring the type of a declaration */
  rule T:Type * X:Exp; => X of pointer to T; [macro]

  rule *X:Exp of PT:PtrType; => X of pointer to PT; [macro]

  /*@ Declaration of a pointer variable */
  rule <k> X:Id of T:PtrType; => .  ...</k>      
       <env> Env:Map => Env[L/X] </env>
       <store>... . => (L |-> undefined) ...</store>
  when fresh(L:Loc)
       [ptr-decl, structural]

  /*@
  Declaration of an alias:
  */

  rule isAliasExp(& E:Exp) => true

  context _:PrimType & _:Id = HOLE;

  rule <k> T:PrimType & X:Id = lval(L:Loc); => . ...</k>
       <env> Env:Map => Env[L/X] </env>


  /*@ The indirect operator */

  rule * L:Ref => lval(L)

  /*@ The type of "\& L" is "pointer to the type of L",
   hence the type of "* \& L" is "type of L". L is evaluated as an
   rvalue that implies that the result is the value stored at L. */

  rule & lval(L:Ref) => L 
  
endmodule
