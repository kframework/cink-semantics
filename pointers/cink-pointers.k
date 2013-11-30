//require "../basic/cink-basic-syntax.k"
//require "../basic/cink-basic-semantics.k"
require "../references/cink-references.k"

/*@ \section{The New Modules} */

module CINK-POINTERS-SYNTAX

  imports CINK-REFERENCES-SYNTAX

  syntax Exp ::= "*" Exp [strict(all(context(rvalue), result(Val))), indirect]

  syntax priorities  indirect  > assign read write greatthan lessequal

endmodule

module CINK-POINTERS-SEMANTICS

  imports CINK-POINTERS-SYNTAX
  imports CINK-REFERENCES-SEMANTICS

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
       <store>... . => (L |-> 0) ...</store>
  when fresh(L:Loc)
       [ptr-decl, structural]


  /*@ The indirect operator */

  rule <k>  * lval(L:Loc) => lval(L') ...</k> 
       <store>... L |-> L':Loc ...</store>


endmodule
