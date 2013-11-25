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


 /*@ \subsection{Expressions} */

  /*@
    We included in \Cink a small subset of operators from \Cpp language,
    the missing ones
    could being easily added in a similar way. Recall that the most important (from
    the semantic point of view) thing we have to mention for operators is the
    attribute \texttt{strict}, that specifies the evaluation order of the 
    operands. 
      \par
      In \Cpp the expressions are splitted in several categories:


\begin{tikzpicture}[node distance=-1.5cm, auto]

\tikzset{
    mynode/.style={rectangle, draw=none, thick, fill=none,
      text width=18em, text centered, minimum height=1em},
    myarrow/.style={-, >=latex', shorten >=1pt, thick}
}  

\node[mynode] (exp) {expression};  
\node[below=1cm of exp] (dummy) {}; 
\node[mynode, left=of dummy] (glval) {glvalue};  
\node[mynode, right=of dummy] (rval) {rvalue};
\node[below=1cm of dummy] (xval) {xvalue};  
\node[below=1cm of glval] (dummy1) {};
\node[mynode, left=of dummy1] (lval) {lvalue};  
\node[below=1cm of rval] (dummy2) {}; 
\node[mynode, right=of dummy2] (prval) {prvalue};

\draw[myarrow] (exp.south) -- (glval.north);
\draw[myarrow] (exp.south) -- (rval.north);
\draw[myarrow] (glval.south) -- (lval.north);
\draw[myarrow] (glval.south) -- (xval.north);
\draw[myarrow] (rval.south) -- (xval.north);
\draw[myarrow] (rval.south) -- (prval.north);

\end{tikzpicture}

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
      of an lvalues expression is different from a rvalue one.

    The arithmetic binary 
    operators are strict in both arguments, hence the behavior of some 
    programs could be undefined or non-determinsitic because the evaluation
    of the arguments could have side-effects. The arguments of a binary aritmetic
    operator are evaluated as rvalues and their result values could be integers,
    booleans, references (locations) \ldots Therefore the value of the strict
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
    The subsort \texttt{RVal} is for values that could bet rvalues expressions.
    \par
    We prefer to declare \texttt{cin} and \texttt{cout} as values rather 
    than identifiers; the reason for this decision will be explained later.
   */


  syntax RVal ::= Bool | Int | String 

  syntax Val ::= "cout" | "cin" | RVal


  syntax Exp ::= Id | Val
               | "(" Exp ")"  [bracket]
               | Exp "(" Exps ")" [strict(1), context(rvalue), result(RVal)]
               |"++" Exp [strict, result(Val), prefinc]
               | Exp "++" [strict, result(Val), postinc]
               | "&" Exp [strict, ampersand]
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
               > Exps ";" [strict]
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

  /*@
  The definition for the list of expressions is more tricky because of the comma
  operator.
  According to the \Cpp manual, the expression lists are special comma expressions: 
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
  A comma expression can be converted into an expression list by a rule of the form
\begin{verbatim}
    E => append(E, .Exps)
\end{verbatim}
  */

endmodule

