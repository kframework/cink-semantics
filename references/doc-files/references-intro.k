/*@


\section{References Iteration}

This iteration extend the basic iteration with references, declaration of aliases, and the call by reference mechanism.

From \Cpp manual (8.3.2):
\begin{quote}
In a declaration T D where D has either of the forms\\
\indent \& $\mathit{attribute-specifier-seq}_{\it opt}D1$\\
\indent \&\& $\mathit{attribute-specifier-seq}_{\it opt}D1$\\
and the type of the identifier in the declaration T D1 is 
“derived-declarator-type-list T,” then the type of
the identifier of D is “derived-declarator-type-list reference to T.” 
The optional attribute-specifier-seq appertains
to the reference type.\ldots\\ {}
[ Note: A reference can be thought of as a name of an object. —end note ] \\
A declarator that specifies the type “reference to cv void” is ill-formed.\\
A reference type that is declared using \& is called an lvalue reference, 
and a reference type that is declared using \&\& is called an rvalue reference. 
Lvalue references and rvalue references are distinct types. Except
where explicitly noted, they are semantically equivalent and commonly 
referred to as references.

It is unspecified whether or not a reference requires storage (3.7).
There shall be no references to references, no arrays of references, 
and no pointers to references. The declaration of a reference shall contain 
an initializer (8.5.3) except when the declaration contains an explicit
extern specifier (7.1.1), is a class member (9.2) declaration within a 
class definition, or is the declaration of a parameter or a return 
type (8.3.5); see 3.1. 
A reference shall be initialized to refer to a valid object
or function. \\ {}
[ Note: in particular, a null reference cannot exist in a 
well-defined program, because the only way to create such a reference 
would be to bind it to the “object” obtained by dereferencing a null pointer,
which causes undefined behavior. As described in 9.6, a reference cannot be 
bound directly to a bit-field.
—end note ]\\
\end{quote}

*/
