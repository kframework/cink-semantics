/*@

\section{Basic Iteration}

This definition includes the starting iteration, 
where the basic constructions of \Cink are defined.

\noindent The main implemented features include:
\begin{itemize}
\item \texttt{bool} and \texttt{int} types
\item aritmetical and boolean expressions, including increment and decrement
 operators, comma operator, function call
\item lvalues and rvalues expressions
\item sequence points
\item imperative statements
\item function definitions
\item local and global variables
\item call-by-value mechanism for binding the function call arguments
\end{itemize}


\noindent Limitations:
\begin{itemize}
\item the local variables can be declared only in the main body of 
the function. The support for local variables defined inside a bloc 
will be added later. The main reason we did not it here is because 
we want to use the LTL model checker for program analysis in a
next iteration. 
The use of the local variables in blocks could be a source of 
a infinite state space.
\end{itemize}

Besides some usual programs,  the examples include:
\begin{itemize}
\item[] \texttt{nondet.cink} - a defined program with non-determinsitic 
behavior
\item[] \texttt{undefined.cink} - a program with  undefined behavior
\item[] \texttt{sumn.cink} - a program that is executed with simbolic 
input values
\end{itemize}

*/

