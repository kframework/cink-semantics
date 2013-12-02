//require "../basic/cink-basic-syntax.k"
//require "../basic/cink-basic-semantics.k"
require "../references/cink-references.k"

/*@ \section{The New Modules} */

module CINK-POINTERS-SYNTAX

  imports CINK-REFERENCES-SYNTAX

  syntax Exp ::= "*" Exp [strict(all(context(rvalue), result(Val))), indirect]

  syntax priorities  indirect  > assign read write greatthan lessequal

  //@Extend syntax wit type specifiers needed for the new operator

  syntax TypeSpec ::= FundType
                    | TypeSpec "*"

  //@ The new operator

  syntax Exp ::= "new" TypeSpec [new]
               | "delete" Exp [strict, delete]

  syntax priorities  new  > assign read write greatthan lessequal

endmodule

module CINK-POINTERS-SEMANTICS

  imports CINK-POINTERS-SYNTAX
  imports CINK-REFERENCES-SEMANTICS

  //@ Extension of the getName function:

  rule getName(* E:Exp) => getName(E) 

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

  //@ lvalue case

  rule <k>  * lval(L:Loc) => lval(V) ...</k> 
       <store>... L |-> V ...</store>

  //@ rvalue case
  rule <k>  * L:Loc => V ...</k> 
       <store>... L |-> V ...</store>

  /*@ 
  Pointers as parameters:
  */

  context evaluate (HOLE, _:Exp) to _
          following (T *_:Exp, _:Decls);

  rule <k>
          bind((lval(L:Loc), Vs) => Vs) to((T * E:Exp, Xl:Decls) => Xl); 
       ...</k>
       <env> Env:Map => Env[L/getName(E)] </env>
       [structural]

  //@ We consider a simplified form of the new operator:

  rule <k> new T:FundType => L ...</k>
       <store>... . => (L:Loc |->  0) ...</store>
       when fresh(L) 

  rule <k> new T:FundType *  => L ...</k>
       <store>... . => (L:Loc |->  0) ...</store>
       when fresh(L) 

  //@ The same for delete:
  rule <k> delete lval(L) => noVal ...</k>
       <store>... (L |->  _) => . ...</store>

endmodule
