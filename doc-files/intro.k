

/*@ \section{Introduction}

\Cink is a kernel of the \Cpp language we used to experiment with \K.
The language is used as an working example for teaching classes and 
is refered in several research papers.

We assume the reader is already familiar with the \K Framework and the 
\KTool; we here share our experiece in defining a languages with some
specific features, such as \Cpp. In giving semantics to the language we 
keep as close as possible to the \Cpp manual (version 2011). Therefore, for
many constructs, the semantics rules are preceded by a quoted text including
the semantics description given in the manual.

\Cink is defined in several iterations, each iteration adding an incremental 
contribution.


\section{C++ Concepts}

In this section we briefly present some \Cpp concepts that are essential in
defining the semantics of \Cink. Some of them are quite challenging for the 
formal semantics.

\subsection{Memory Model}

From \Cpp manual (1.7):
\begin{quote}
The fundamental storage unit in the C++ memory model is the byte. 
A \emph{byte} is at least large enough to contain
any member of the basic execution character set (2.3) and the eight-bit code 
units of the Unicode UTF-8 encoding form and is composed of a contiguous 
sequence of bits, the number of which is implementation defined.
The least significant bit is called the low-order bit; 
the most significant bit is called the high-order bit. 
The memory available to a C++ program consists of one or more sequences of 
contiguous bytes. Every byte has a unique address.
[ Note: The representation of types is described in 3.9. --end note ]\\
A \emph{memory location} is either an object of scalar type or a maximal 
sequence of adjacent bit-fields all having non-zero width. 
[ Note: Various features of the language, such as references and virtual 
functions, might involve additional memory locations that are not accessible 
to programs but are managed by the implementation. --end note ]\\
Two or more threads of execution (1.10) can update and access separate memory
locations without interfering with each other.
\end{quote}

Our formal semantics uses a more abstract memory model consisting of symbolic 
cells, each location being either a scalar, or a function definition, or an 
object, \ldots. The memory locations are defined in the basic iteration and 
then extended in the iteration defining arrays.

\subsection{Object Model}

From \Cpp manual (1.8):
\begin{quote}
The constructs in a C++ program create, destroy, refer to, access, and 
manipulate objects. An \emph{object} is a region of storage. 
[ Note: A function is not an object, regardless of whether or not it occupies 
storage in the way that objects do. --end note ] An object is created by a 
definition (3.1), by a new-expression (5.3.4) or by the implementation (12.2)
when needed. The properties of an object are determined when the object
is created. 
An object can have a \emph{name} (Clause 3). 
An object has a \emph{storage duration} (3.7) which influences 
its \emph{lifetime} (3.8). 
An object has a \emph{type} (3.9). 
The term \emph{object type} refers to the type with which the object
is created. 
Some objects are \emph{polymorphic} (10.3); the implementation generates 
information associated with each such object that makes it possible to determine
that object's type during program execution. For other objects, 
the interpretation of the values found therein is determined by the type of 
the expressions (Clause 5) used to access them.\\
Objects can contain other objects, called subobjects. 
A subobject can be a member subobject (9.2), a base class subobject (Clause 10), 
or an array element. An object that is not a subobject of any other object is
called a complete object.\\
For every object x, there is some object called the complete object of x, 
determined as follows:
\begin{itemize}
\item If x is a complete object, then x is the complete object of x.
\item Otherwise, the complete object of x is the complete object of the 
(unique) object that contains x.
\end{itemize}
\end{quote}

The objects will be defined in the iteration specifying the semantics of 
the classes.


\subsection{Side Effects}

Side effects are very important in giving semantics to \Cpp constructs,
e.g., expressions, and therefore it is necessary to know exactly what a
side effect means. Here is the definition from the \Cpp manual:
 
\begin{quote}
Accessing an object designated by a volatile glvalue (3.10), modifying an 
object, calling a library I/O
function, or calling a function that does any of those operations are all 
\emph{side effects}, which are changes in the
state of the execution environment. Evaluation of an expression 
(or a sub-expression) in general includes
both value computations (including determining the identity of an object for 
glvalue evaluation and fetching
a value previously assigned to an object for prvalue evaluation) and 
initiation of side effects. When a call
to a library I/O function returns or an access to a volatile object is 
evaluated the side effect is considered
complete, even though some external actions implied by the call 
(such as the I/O itself) or by the volatile
access may not have completed yet.
\end{quote}


\subsection{Sequenced before}

    "Sequenced before" is specific to languages where the evaluation of the
    expressions has side effects. Obviously, this is the case for C and \Cpp
    languages. 
    "Sequenced before" defines a partial order relation over the evaluation
    of the subexpressions and over the side effects generated by these 
    evaluations. 
    Here is the definition for sequenced before from the \Cpp manual (1.9):

\begin{quote}
  \emph{Sequenced before} is an asymmetric, transitive, pair-wise relation 
  between evaluations executed by a single
   thread (1.10), which induces a partial order among those evaluations.
   Given any two evaluations A and B, if
   A is sequenced before B, then the execution of A shall precede the execution
   of B. If A is not sequenced before
   B and B is not sequenced before A, then A and B are unsequenced.
  [ Note: The execution of unsequenced
   evaluations can overlap. --end note ] Evaluations A and B are 
  indeterminately sequenced when either A
   is sequenced before B or B is sequenced before A, but it is unspecified 
  which.
  [ Note: Indeterminately
   sequenced evaluations cannot overlap, but either could be executed first.
    --end note ]\\
  Every value computation and side effect associated with a full-expression
  is sequenced before every value
  computation and side effect associated with the next full-expression
  to be evaluated.\\
  Except where noted, evaluations of operands of individual operators and of 
  subexpressions of individual expressions are unsequenced.\\
  {}[Note: In an expression that is evaluated more than once during the execution
  of a program, unsequenced and indeterminately sequenced evaluations of its 
  subexpressions need not be performed consistently in different evaluations.
  --end note]\\
  The value computations of the operands of an operator are sequenced before
  the value computation of the result of the operator. If a side effect on a
  scalar object is unsequenced relative to either another side effect on the
  same scalar object or a value computation using the value of the same scalar
  object, the behavior is undefined.
\end{quote}

Sources for the side effects in C++ are are the assignment operators, postfix 
increment and decrement operators. Sequenced before is eesential in defining
the behavior of programs.


\subsection{Types}
From the \Cpp manual (3.9):

\begin{quote}
[ Note: 3.9 and the subclauses thereof impose requirements on 
implementations regarding the representation of types. 
There are two kinds of types: fundamental types and compound types. 
Types describe objects (1.8), references (8.3.2), or functions (8.3.5).
 --end note ]\\
\ldots\\
The object representation of an object of type T is the sequence of 
N unsigned char objects taken up by the object of type T, 
where N equals sizeof(T). The value representation of an object is 
the set of bits that hold the value of type T.\\
\ldots
Arithmetic types (3.9.1), enumeration types, pointer types, 
pointer to member types (3.9.2), std::nullptr\_-t, and cv-qualified 
versions of these types (3.9.3) are collectively called 
\emph{scalar types.}\\
\dots\\
\end{quote}

\subsubsection{Fundamental types}
\begin{quote}
Objects declared as \emph{characters (char)} shall be large enough 
to store any member of the implementation's basic character set.
\ldots\\
There are five standard signed \emph{integer types}: "signed char", 
"short int", "int", "long int", and "long long int".
\ldots\\
Values of type \emph{bool} are either true or false.\\
\ldots\\
There are three \emph{floating point} types: float, double, and long double. 
The type double provides at least as much precision as float, and the type 
long double provides at least as much precision as double.
The set of values of the type float is a subset of the set of values of the 
type double; the set of values of the type double is a subset of the set of 
values of the type long double. The value representation of
floating-point types is implementation-defined. 
Integral and floating types are collectively called arithmetic types. 
\ldots\\
The \emph{void} type has an empty set of values. 
The void type is an incomplete type that cannot be completed. It
is used as the return type for functions that do not return a value. 
Any expression can be explicitly converted to type cv void (5.4). 
An expression of type void shall be used only as an expression statement (6.2),
as an operand of a comma expression (5.18), as a second or third operand of 
?: (5.16), as the operand of typeid or decltype, as the expression in a return 
statement (6.6.3) for a function with the return type void, or as
the operand of an explicit conversion to type cv void.\\
\end{quote}

\subsubsection{Compound types}

\begin{quote}
Compound types can be constructed in the following ways:
\begin{itemize}
\item \emph{arrays} of objects of a given type, 8.3.4;
\item \emph{functions}, which have parameters of given types and return void or 
references or objects of a given type, 8.3.5;
\item \emph{pointers} to void or objects or functions 
(including static members of classes) of a given type, 8.3.1;
\item \emph{references} to objects or functions of a given type, 8.3.2. 
There are two types of references:
\begin{itemize}
\item lvalue reference
\item rvalue reference
\end{itemize}
\item \emph{classes} containing a sequence of objects of various types (Clause 9),
a set of types, enumerations and functions for manipulating these objects (9.3), 
and a set of restrictions on the access to these entities(Clause 11);
\item \emph{unions}, which are classes capable of containing objects of different 
types at different times, 9.5;
\item \emph{enumerations}, which comprise a set of named constant values. 
Each distinct enumeration constitutes a different enumerated type, 7.2;
\item \emph{pointers} to non-static class members, which identify members of a 
given type within objects of a given class, 8.3.3.
\end{itemize}
\end{quote}

In \Cink we consider only a part of the above types, but we try to keep
the taxonomy and terminology.



\subsection{Lvalues and Rvalues}

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

From the \Cpp manual (3.10):
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
of an lvalue expression is different from a rvalue one.

*/
