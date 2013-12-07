
/*@ \section{Introduction}


This iteration includes the extension of the pointer iteration with 
multidimensional arrays. 

From C++ 2011 Manual (8.3.4):\\
\begin{quote}
  In a declaration T D where D has the form\\
   \indent   D1 [ constant-expressionopt] attribute-specifier-seqopt\\
   and the type of the identifier in the declaration T D1 is 
   "derived-declarator-type-list T", then the type of the identifier of D
   is an array type...\\
   Example:
   \begin{verbatim}
      typedef int A[5], AA[2][3];
      typedef const A CA; // type is "array of 5 const int"
      typedef const AA CAA; // type is "array of 2 array of 3 const int"
  \end{verbatim}
  ... 
  "An array can be constructed from one of the fundamental types (except void),
   from a pointer, from a pointer to member, from a class, from an enumeration
   type, or from another array.\\
   When several "array of" specifications are adjacent, a multidimensional array
   is created; only the first of the constant expressions that specify the 
   bounds of the arrays may be omitted. In addition to declarations in
   which an incomplete object type is allowed, an array bound may be omitted in
   some cases in the declaration of a function parameter (8.3.5). An array 
   bound may also be omitted when the declarator is followed by an
   initializer (8.5). In this case the bound is calculated from the number of 
   initial elements (say, N) supplied (8.5.1), and the type of the identifier
   of D is "array of N T.
\end{quote}

   The memory model defined for unidimensional arrays can be extended to 
   multidimensional arrays.
   A $2\times 3$ array $\{\{2, 4, 6\}, \{3, 5, 7\}\}$ is represented as:
   \begin{verbatim}
      seq-array(2, L) |-> array of 2 array of 3 int
     
      select(seq-array(2, L), 0)
      |-> 
      store(store(store(const-array(3, 0), 0, 2), 1, 4), 2, 6)

      select(seq-array(2, L), 1)
      |-> 
      store(store(store(const-array(3, 0), 0, 3), 1, 5), 2, 7)
   \end{verbatim}
  where \texttt{array of 3 int)} is replaced first by \texttt{const-array(3, 0)}
  and then component-wise updated. 

  The main idea is as follows. We assume that the array type is
  \texttt{array of} $N_k$ \texttt{array of} $N_{k-1}$ \ldots .
  The whole array is stored in a contiguous sequence
  of cells starting at a distinguished address $L$,
  denoted by $\texttt{seq-array}(N_k,L)$, where $N_k$ is the last dimension of 
  the array. The value stored at $L$ is of type of the array.
  Since the value $N_k$ can be "unknown" (e.g., represented by a
  symbolic value), we do not want to explicitly represent the array value 
  stored at $L$. 
  However, the information about the array is needed for defining the semantics
   of the language.
  Therefore the "value" stored at $L$ is the array type, meaning that at $L$ is 
  stored a value of this type. The operator \texttt{select} from the theory of 
  arrays is extended to sequences of locations.
  In fact,  $\texttt{seq-array}(N,L)$ can thaught as a sugar syntax
  for the array\\
  \centerline{
  $\texttt{store}(\ldots\texttt{store}(\texttt{const-array}(N,\bot), L[0]),\ldots,L[N-1])$.
  }\\
  The location of the $I$-th component is
  \texttt{select}(\texttt{seq-array}$(N,L)$, $I$). 
  A component is represented in the cell \texttt{store} only if it is accesed. 
  If the type of the component is a multidimensional array, then it is 
  represented in a similar way to that of the array:\\
  \centerline{
  \texttt{select}(\texttt{seq-array}$(N_k,L)$, $I$) $\mapsto$ 
  \texttt{array of $N_{k_1}$ \ldots}
  }\\
  If the component is an array of scalars, then it is stored in the same way
  to that of unidimensional arrays iteration.

  If all components of an array are represented in the cell \texttt{store},
  then its complete value can be built in a bottom-up manner.

  The pointer arithmetic can be extended with\\
   $L[0][0] + N*I + J 
     = \texttt{select}(\texttt{select}(\texttt{seq-array}(N, L),I), J)$
   if $L[0] \mapsto \texttt{array of } N\ldots$.
  
*/
