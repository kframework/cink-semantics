module CINK-BASIC-SYNTAX

  /*@ \subsection{Declarations}
    The declarations are used for declaring variables and function names
    together with their return types.
    We consider only integer and boolean variables. A return type of a function
    could be an integer, a boolean, or \texttt{void}. These are called 
    \emph{primitive types} (or \emph{builtin types}) and their sort is \texttt{PrimType}.
    The sort \texttt{Type} will be enriched later with array types, pointer types,
    ans so on.
  */

  syntax PrimType ::= "int" | "bool" | "void" 

  syntax Type ::= PrimType

  syntax Decl ::= Type Exp

  /*@ \subsection{Values} */

  /*@ The constants of the builtin types are primitive constructs and therefore
      they should be values.  
      The sort \texttt{Val} for values will be extended in the module describing
      the semantics.
      \par
      We prefer to declare \texttt{cin} and \texttt{cout} as values rather 
      than identifiers; the reason for this decision will be explained later.
   */


 
 /*@ \subsection{Expressions} */

  /*@
    We included in \Cink a small subset of \Cpp language, the missing operators
    can be easily added in a similar way. Recall that the most important (from
    the semantic point of view) thing we have to mention for operators is the
    attribute \texttt{strict}, that specifies the evaluation order of the 
    operands. 
      \par
      In \Cpp the expressions are splitted in several categories:\\
\begin{verbatim}
                       expression
                        /        \
                 glvalue         rvalue
                /       \      /      \
          lvalue         xvalue        prvalue
\end{verbatim}
\begin{quote}
-- An lvalue (so called, historically, because lvalues could appear on the 
left-hand side of an assignment expression) designates a function or an object.
[ Example: If E is an expression of pointer type, then
*E is an lvalue expression referring to the object or function to which E 
points. As another example, the result of calling a function whose return type
is an lvalue reference is an lvalue. --end example ]\\
-- An xvalue (an "eXpiring" value) also refers to an object, usually near
the end of its lifetime (so that its resources may be moved, for example). 
An xvalue is the result of certain kinds of expressions involving
rvalue references (8.3.2). [ Example: The result of calling a function whose 
return type is an rvalue reference is an xvalue. --end example ]\\
-- A glvalue ("generalized" lvalue) is an lvalue or an xvalue.\\
-- An rvalue (so called, historically, because rvalues could appear on the 
right-hand side of an assignment expression) is an xvalue, a temporary object 
(12.2) or subobject thereof, or a value that is not associated with an object.\\
-- A prvalue ("pure" rvalue) is an rvalue that is not an xvalue. 
[ Example: The result of calling a function whose return type is not a 
reference is a prvalue. The value of a literal such as 12, 7.3e5, or true is
also a prvalue. --end example ]
\end{quote}
      In order to keep the definition as simple as possible, we consider only two
      of these categories: \emph{lvalues} and \emph{rvalues}. This classification
      of expressions is essential in defining their semantics since the evaluation
      of an lvalues pression is different from a rvalue one.

    The arithmetic binary 
    operators are strict in both arguments, hence the behavior of some 
    programs could be undefined or non-determinsitic because the evaluation
    of the arguments could have side-effects. The arguments of a binary aritmetic
    operator are evaluated as rvalues and this specified by the wrapper component 
    of the strict attribute. The result value of a binary operator is also a rvalue
    and this is expressed by the result component of the strict attribute.\\
\textcolor{red}{TBD: update it with the new syntax.}\\ 
    In contrast
    to the other examples, the function call expression is strict only in the
    first argument (the function name) because the evaluation of the arguments
    it is depending on the bindding mechanism of the corresponding argument: 
    this can be call-by-value or call-by-reference. These two mechansims will
    be explained later. \\
    \textcolor{red}{TBD: explain the mechanisms with the "specific value type"
    and"wrapping".}

    We also consider a subsort \texttt{LVal} for lvalues, which should always refer 
    memory locations. This subsort will be defined later, in the module giving the 
    semantics.
   */


  syntax RVal ::= Bool | Int | String 

  syntax Val ::= "cout" | "cin" | RVal


  syntax Exp ::= Id | Val
               | "(" Exp ")"  [bracket]
               | Exp "(" Exp ")" [strict(1), context(rvalue), result(RVal)]
               | Exp "(" ")" 
               > left:
                 Exp "*" Exp [left, multiply, strict, context(rvalue), result(RVal)]
               | Exp "/" Exp [left, divide, strict, context(rvalue), result(RVal)]
               | Exp "%" Exp [left, latex({#1}\%{#2}), modulo, strict, context(rvalue), result(RVal)] 
               >  left:
                 Exp "+" Exp [left, plus, strict, context(rvalue), result(RVal)]
               | Exp "-" Exp [left, minus, strict, context(rvalue), result(RVal)]
               > left:
                 Exp "<" Exp  [left, lessthan, strict, context(rvalue), result(RVal)]
               | Exp ">" Exp  [left, greatthan, strict, context(rvalue), result(RVal)]
               | Exp "<=" Exp [left, latex({#1}\leq{#2}), lessequal, strict, context(rvalue), result(RVal)]
               | Exp "==" Exp [left, equality, strict, context(rvalue), result(RVal)]
               >
                 "!" Exp [strict, negation, strict, context(rvalue), result(Bool)] 
               > 
                 Exp "&&" Exp [left, strict(1), context(rvalue), result(Bool), latex({#1}\mathrel{\&\&}{#2}), conjunction]
               > 
                 Exp "||" Exp [left, strict(1), context(rvalue), result(Bool), disjunction]
               > left:
                 Exp "<<" Exp [left, strict(2), context(rvalue), result(RVal), latex({#1}\mathrel{\tt <<}{#2}), write]
               | Exp ">>" Exp [left, strict, latex({#1}\mathrel{\tt >>}{#2}), read]
               > 
                 Exp "=" Exp [right, strict(2), context(rvalue), result(RVal), assign]
               >
                 "endl"
               > Exp "," Exp [left, strict(1), comma]

  /*@ \subsection{Statements}
    For now, we include in CinK only (a subset) of the imperative statements:
    expresion statement, bloc, sequential composition, while, and conditionals.
   */


  syntax Stmt ::= 
                 Decl ";" [klabel(declStmt)]
               > Exp ";" [strict]
               | "#include" "<iostream>" 
               | "using" "namespace" "std" ";" 
                 [latex(\texttt{using namespace std;})]
               | "{" "}"
               | "{" Stmts "}"
               | "while" "(" Exp ")" Stmt 
               | "return" Exp ";" [strict, context(rvalue), result(RVal)]
               | Decl "(" Decls ")" "{" Stmts "}"
               | "if" "(" Exp ")" Stmt "else" Stmt [strict(1), context(rvalue), result(Bool)]
               >
                 "if" "(" Exp ")" Stmt

  /*@
    A program is a sequence of statements:
  */
  syntax Pgm ::= Stmts 
  syntax Stmts ::= Stmt | Stmts Stmts [left]

  /*@ \subsection{Lists} */

  /*@
    The above definitions are using lists of expressions and lists of 
    declarations, which are declared as follows:
  */

  syntax Decls ::= List{Decl, ","}
 
endmodule
