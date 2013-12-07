/*@

\chapter{Basic Iteration}

This definition includes the starting iteration, 
where the basic constructs of \Cink are defined.
\noindent The main implemented features include:
\begin{itemize}
\item \texttt{bool} and \texttt{int} types
\item aritmetic and Boolean expressions, including increment and decrement
 operators, the comma operator, function call
\item lvalues and rvalues expressions
\item sequence points
\item imperative statements
\item function definitions
\item local and global variables
\item a call-by-value mechanism for binding the function call arguments
\end{itemize}


\noindent Restrictions comparing with \Cpp:
\begin{itemize}
\item local variables can be declared only in the main body of 
the function. The support for local variables defined inside a block 
will be added later. The main reason we did not it here is because 
we want to use the LTL model checker for program analysis in a
subsequent iteration. 
The use of the local variables in blocks could lead to an infinite state space.
\item 
\end{itemize}

Among the examples included with this definition we mention:
\begin{itemize}
\item[] \texttt{nondet.cink} - a defined program with non-determinsitic 
behavior
\item[] \texttt{undefined.cink} - a program with  undefined behavior
\item[] \texttt{sumn.cink} - a program with simbolic input
\end{itemize}

The programs in the subfolder \texttt{tests} are only for testing purposes.
*/

