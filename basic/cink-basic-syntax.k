module CINK-BASIC-SYNTAX

  /*@ \subsection{Types}
   In this iteration we consider only a subset of the fundamental types:
  */


  syntax FundType ::= "int" | "bool" | "void" 

  syntax Type ::= FundType

  /*@ \subsection{Declarations}
    The declarations are used to introduce names for variables and function names
    together with their return types.
  */


  syntax Decl ::= Type Exp


 /*@ \subsection{Expressions} */

  /*@
    We included in \Cink a small subset of operators from \Cpp language,
    the missing ones could being easily added in a similar way.
    Recall that the most important (from
    the semantic point of view) thing we have to mention for operators is the
    attribute \texttt{strict}, that specifies the evaluation order of the 
    operands. 
      \par

    The binary 
    operators are strict in both arguments, hence the behavior of some 
    programs could be undefined or non-determinsitic because the evaluation
    of the arguments could have side-effects. The arguments of a binary
    operator are evaluated as rvalues and their result values could be integers,
    booleans, locations \ldots. Therefore the value of the strict
    attribute is a list of two sub-attributes: a \texttt{context} sub-attribute 
    having as value the label \texttt{rvalue} and a  a \texttt{result} 
    sub-attribute having as value the result type of the arguments.
    This will be explained later in the module defining semantics, when we 
    define the values of the language.\\ 
    In contrast
    to the other examples, the function call expression is strict only in the
    first argument (the function name) because the evaluation of the arguments
    it is depending on the bindding mechanism of the corresponding argument: 
    this can be call-by-value or call-by-reference. These two mechansims will
    be explained later.
    \par

    The constants of the builtin types are primitive constructs for expressions 
    and therefore they are values.  
    The sort \texttt{Val} for values will be extended in the module describing
    the semantics.
    The subsort \texttt{ScalVal} is for values of the scalar types.
    \par
    We prefer to declare \texttt{cin} and \texttt{cout} as values rather 
    than identifiers; the reason for this decision will be explained later.
   */


  syntax ScalVal ::= Bool | Int | String 

  syntax Val ::= "cout" | "cin" | ScalVal


  syntax Exp ::= Id | Val
               | "(" Exp ")"  [bracket]
               | Exp "(" Exps ")" [strict(1(context(rvalue))), funcall]
               | "++" Exp [strict(all(result(Val))), prefinc]
               | "--" Exp [strict(all(result(Val))), prefdec]
               | Exp "++" [strict(all(result(Val))), postinc]
               | Exp "--" [strict(all(result(Val))), postdec]
//               | "&" Exp [strict, ampersand]
               > left:
                 Exp "*" Exp [left, strict(all(context(rvalue))), multiply]
               | Exp "/" Exp [left, strict(all(context(rvalue))), divide]
               | Exp "%" Exp [left, strict(all(context(rvalue))), latex({#1}\%{#2}), modulo] 
               >  left:
                 Exp "+" Exp [left, strict(all(context(rvalue))), plus]
               | Exp "-" Exp [left, strict(all(context(rvalue))), minus]
               > left:
                 Exp "<" Exp  [left, strict(all(context(rvalue), result(ScalVal))), lessthan]
               | Exp ">" Exp  [left, strict(all(context(rvalue), result(ScalVal))), greatthan]
               | Exp "<=" Exp [left, strict(all(context(rvalue), result(ScalVal))), 
                                     latex({#1}\leq{#2}), lessequal]
               | Exp "==" Exp [left, equality, strict(all(context(rvalue), result(Val)))]
               >
                 "!" Exp [strict(all(context(rvalue), result(Bool))), negation] 
               > 
                 Exp "&&" Exp [left, strict(1(context(rvalue), result(Bool))), 
                               latex({#1}\mathrel{\&\&}{#2}), conjunction]
               > 
                 Exp "||" Exp [left, strict(1(context(rvalue), result(Bool))), disjunction]
               > left:
                 Exp "<<" Exp [left, strict(1, 2(context(rvalue))),
                                     latex({#1}\mathrel{\tt <<}{#2}), write]
               | Exp ">>" Exp [left, strict, latex({#1}\mathrel{\tt >>}{#2}), read]
               > 
                 Exp "=" Exp [right, strict(1, 2(context(rvalue))), assign]
               >
                 "endl"
               > Exp "," Exp [left, strict(1), comma]

  /*@ \subsection{Statements}
    For now, we include in CinK only (a subset) of the imperative statements:
    expresion statement, bloc, sequential composition, while, and conditionals.
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
and lists of initializers (8.5) —end example ] the comma operator as described 
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

