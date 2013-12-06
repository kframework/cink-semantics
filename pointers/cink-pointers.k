require "../references/cink-references.k"

module CINK-POINTERS-SYNTAX

  imports CINK-REFERENCES-SYNTAX

  /*@
  The only operand of the indirect operator is an rvalue.
  */

  syntax Exp ::= "*" Exp [strict(all(result(Val))), indirect]

  syntax priorities  indirect  > assign read write greatthan lessequal equality plus multiply

  //@Extend syntax wit type specifiers needed for the new operator:

  syntax TypeSpec ::= FundType
                    | TypeSpec "*"

  //@ The new and delete operators:

  syntax Exp ::= "new" TypeSpec [new]
               | "delete" Exp [strict, delete]

  syntax priorities  new  > assign read write greatthan lessequal
  syntax priorities  delete  > assign read write greatthan lessequal

endmodule

module CINK-POINTERS-SEMANTICS

  imports CINK-POINTERS-SYNTAX
  imports CINK-REFERENCES-SEMANTICS

  //@ Extension of the getName function:

  rule getName(* E:Exp) => getName(E) 

  /*@ Pointer type: */

  syntax PtrType ::= "pointer" "to" Type 

  syntax ScalType ::= PtrType

  /*@ Extend the declarations with "pointer to type" type: */

  syntax Stmt ::= Exp "of" PtrType ";"


  /*@ Desugaring the type of a declaration: */
  rule T:Type * X:Exp; => X of pointer to T; [macro]

  rule *X:Exp of PT:PtrType; => X of pointer to PT; [macro]

  /*@ Declaration of a pointer variable: */

  rule <k> X:Id of T:PtrType; => .  ...</k>      
       <env> Env:Map => Env[L/X] </env>
       <store>... . => (L |-> 0) ...</store>
  when fresh(L:ScalLoc)
       [ptr-decl, structural]




  /*@ The indirect operator */

  //@ -- lvalue case:

  rule <k>  * lval(L:ScalLoc) => lval(V) ...</k> 
       <store>... L |-> V ...</store>

  //@ -- rvalue case:
  rule <k>  * L:ScalLoc => V ...</k> 
       <store>... L |-> V ...</store>

  /*@ 
  Pointers as parameters:
  */

  context evaluate (HOLE, _:Exp) to _
          following (T *_:Exp, _:Decls);

  rule <k> bind((V:ScalVal, Vs) => Vs)
           to((T * E:Id, Xl:Decls) => Xl); 
       ...</k>
       <env> Env:Map => Env[L/getName(E)] </env>
       <store>... . => L |-> V ...</store>
       requires fresh(L:ScalLoc)
 
  //@ We consider a simplified form of the new operator:

  rule <k> new T:FundType => L ...</k>
       <store>... . => (L:ScalLoc |->  0) ...</store>
       when fresh(L) 

  rule <k> new T:FundType *  => L ...</k>
       <store>... . => (L:ScalLoc |->  0) ...</store>
       when fresh(L) 

  //@ The same for delete:
  rule <k> delete lval(L:ScalLoc) => noVal ...</k>
       <store>... (L |->  _) => . ...</store>

endmodule
