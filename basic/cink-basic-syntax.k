module CINK-BASIC-SYNTAX

  /*@ \subsection{Types}
   In this iteration we consider only a subset of the fundamental types:
  */


  syntax FundType ::= "int" | "bool" | "void" 

  syntax Type ::= FundType

  /*@ \subsection{Declarations}
    Declarations are used to introduce names for variables and function names
    together with their return types.
  */


  syntax Decl ::= Type Exp


 /*@ \subsection{Expressions} */

  /*@
    We included in \Cink a small subset of operators from \Cpp language,
    the missing ones could being easily added in a similar way.

    A major feature of the \Cpp expressions is that given by the relation
    "sequenced before", which defines a partial order over the evaluation of 
    subexpressions. This can be easily expressed in \K using the 
    \texttt{strict} attribute to specify the evaluation order for the 
    operands. Id the operands of an operator are unsequenced, then the 
    operator will have the attribute \texttt{strict}, meaning that they are
    evaluated in strict nondeterministic order. If an operand $A$ is sequenced
    before $B$ then the eavluation order is expressed as argument of the 
    \texttt{strict} attribute.
    For instance, since the operands of the binary operators are unsequenced, 
    these operators are strict in both arguments. Hence the behavior of some 
    programs could be undefined or non-determinsitic because the evaluation
    of the arguments could have side-effects. 

    The second major feature is given by the classification of the expression
    in rvalues and lvalues. For instance, the arguments of a binary
    operator are evaluated as rvalues and their result is a rvalues, too,
    whilst the argument of the prefix increment/decrement and their result are 
    lvalues. Therefore the value of the strict attribute for such operators
    is a list of two sub-attributes: a \texttt{context} sub-attribute 
    having as value the label \texttt{rvalue} and a  a \texttt{result} 
    sub-attribute having as value the result type of the argument(s).
    The expression are considered lvalues by default.
    This will be explained later in the module defining semantics, when we 
    define the values of the language.

    In contrast
    to the other examples, the function call expression is strict only in the
    first argument (the function name) because the evaluation of the arguments
    it is depending on the bindding mechanism of the corresponding argument: 
    this can be call-by-value or call-by-reference.
    In this iteration we consider
    only the former one, the latter will be implemented in a next iteration,
    together with the references.

    The primitive constructs for expressions are the variable names, which are
    identifiers, and the values modeled by the sort \texttt{Val}. 
    A subset of values, modeled by the sort \texttt{ScalVal}, is given by 
    the constants of the scalar types.
    \par
    We prefer to declare the standard input/output streams \texttt{cin} and 
    \texttt{cout} as being values; the reason for this decision will be 
    explained later.
   */


  syntax ScalVal ::= Bool | Int | String 

  syntax Val ::= "cout" | "cin" | ScalVal


  syntax Exp ::= Id | Val
               | "(" Exp ")"  [bracket]
               | Exp "(" Exps ")" [strict(1(context(rvalue))), funcall]
               | "++" Exp [strict(all(result(Val))), prefinc]
               | "--" Exp [strict(all(result(Val))), latex(\texttt{--}\,{#1}), prefdec]
               | Exp "++" [strict(all(result(Val))), postinc]
               | Exp "--" [strict(all(result(Val))), latex({#1}\,\texttt{--}), postdec]
//               | "&" Exp [strict, ampersand]
               > left:
                 Exp "*" Exp [left, strict(all(context(rvalue))), multiply]
               | Exp "/" Exp [left, strict(all(context(rvalue))), divide]
               | Exp "%" Exp [left, strict(all(context(rvalue))),
                                    latex({#1}\%{#2}), modulo] 
               >  left:
                 Exp "+" Exp [left, strict(all(context(rvalue))), plus]
               | Exp "-" Exp [left, strict(all(context(rvalue))), minus]
               > left:
                 Exp "<" Exp  [left, strict(all(context(rvalue), result(ScalVal))),
                                     lessthan]
               | Exp ">" Exp  [left, strict(all(context(rvalue), result(ScalVal))),
                                     greatthan]
               | Exp "<=" Exp [left, strict(all(context(rvalue), result(ScalVal))), 
                                     latex({#1}\leq{#2}), lessequal]
               | Exp "!=" Exp [left, strict(all(context(rvalue), result(ScalVal))), 
                                     latex({#1}\leq{#2}), notequal]
               | Exp "==" Exp [left, strict(all(context(rvalue), result(ScalVal))),
                                     equality]
               >
                 "!" Exp [strict(all(context(rvalue), result(Bool))), negation] 
               > 
                 Exp "&&" Exp [left, strict(1(context(rvalue), result(Bool))), 
                               latex({#1}\mathrel{\&\&}{#2}), conjunction]
               > 
                 Exp "||" Exp [left, strict(1(context(rvalue), result(Bool))),
                                     disjunction]
               > left:
                 Exp "<<" Exp [left, strict(1, 2(context(rvalue))),
                                     latex({#1}\mathrel{\texttt{<<}}{#2}), write]
               | Exp ">>" Exp [left, strict, latex({#1}\mathrel{\texttt{>>}}{#2}), read]
               > 
                 Exp "=" Exp [right, strict(1, 2(context(rvalue))), assign]
               >
                 "endl"
               > Exp "," Exp [right, strict(1), comma]

  /*@ \subsection{Statements}
    For now, we include in CinK only a subset of the imperative statements:
    expresion statement, bloc, sequential composition, while, and conditionals.
    Other imperative statements, like \texttt{for} or \texttt{do-until} are easy
    to define and we let them as exercises.
  */


  syntax Stmt ::= 
                 Decl ";" [klabel(declStmt)]
               > Exps ";" [strict]
               | "#include" "<iostream>" 
               | "using" "namespace" "std" ";" 
                 [latex(\texttt{using namespace std;})]
               | "{" "}"
               | "{" Stmts "}"
               | "while" "(" Exp ")" Stmt 
               | "return" Exp ";" [strict(all(context(rvalue)))]
               | Decl "(" Decls ")" "{" Stmts "}"
               | "if" "(" Exp ")" Stmt "else" Stmt [strict(1(context(rvalue)))]
               >
                 "if" "(" Exp ")" Stmt

  /*@
    A program is a sequence of statements:
  */
  syntax Pgm ::= Stmts 
  syntax Stmts ::= Stmt | Stmts Stmts [left]

  /*@ \subsection{List of Declarations} */

  /*@
    The above definitions are using lists of  
    declarations, which ais declared as follows:
  */

  syntax Decls ::= List{Decl, ","}

  /*@

  \subsection{List of Expressions}
  The definition for the list of expressions is more tricky because of the comma
  operator.
  According to the \Cpp manual (5.18), the expression lists are special comma expressions: 
\begin{quote}
In contexts where comma is given a special meaning, 
[ Example: in lists of arguments to functions (5.2.2)
and lists of initializers (8.5) -end example ] the comma operator as described 
in Clause 5 can appear only in parentheses.
\end{quote}  
  The main difference between the expression lists and comma expressions is given
  by the empty list. Therefore we have to separately define it. Mainly, the 
  following declaration says 1) the empty list \texttt{.Exps} is an expression
  list (denoted by the sort \texttt{Exps}), and 2) an expression, in particular 
  any comma expression, is an expression lists. 
  */
  syntax Exps ::= "" [onlyLabel, klabel('.Exps)]
                | Exp

  syntax Exp ::= ".Exps"

  /*@
  An expression can be converted into an expression list by a rule of the form
\begin{verbatim}
    E => append(E, .Exps)
\end{verbatim}
  */

endmodule

