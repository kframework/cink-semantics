/*@ \section{Unidimensional Arrays Iteration}

This file extends the starting iteration with unidimensional arrays.

   From C++ 2011 Manual:
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
  \ldots\\
   An array can be constructed from one of the fundamental types (except void),
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

   We extend the memory model with contiguous sequences of locations. Such
   sequences are represented by using the theory of arrays.
   We assume the reader familiar with this theory. 
   Here is its definition included in 
   \texttt{include/builtins/array.k}:
   \begin{asciik}
     syntax Array ::= "store"       "(" Array "," Int "," K ")" 
                    | "const-array" "(" Int "," K ")" 
		 
     syntax K ::= "select" "(" Array "," Int ")" 
     syntax Int ::= "size-of-array" "(" Array ")"

    rule select(store(_:Array, I:Int, V:K), J:Int) => V 
         requires I ==Int J

    rule select(store(A:Array, I:Int, _:K), J:Int) => select(A, J)
         requires I =/=Int J 

    rule select(const-array(Size:Int, V:K), I:Int) => V
         requires (0 <=Int I) andBool (I <Int Size) 
   \end{asciik}

   We explain the main idea by means of an example showing how a sequence of 
   three locations storing the sequence of integers (5,3, 8) is represented 
   by the map:
   \begin{verbatim}
      seq-array(3, L)
      |-> 
      store(store(store(const-array(3, 0), 0, 5), 1, 3), 2, 8)
    \end{verbatim}
   where \texttt{seq-array(3, L)} is a sugar syntax for\\
   \texttt{store(store(store(const-array(5, 0), 0, L[0]), 1, L[1]), 2, L[2])}.

  The arrays can be converted to pointers.
  From the \Cpp manual:
  \begin{quote}
  An lvalue or rvalue of type "array of N T" or "array of unknown bound of T"
  can be converted to a prvalue of type "pointer to T". 
  The result is a pointer to the first element of the array.
  \end{quote}
  Therefore the pointer arithmetic is extended over array locations:\\
\indent   $L[I] + V = \texttt{select}(\texttt{seq-array}(N, L),I+V)$,\\
\indent   $++ L[I] = \texttt{select}(\texttt{seq-array}(N, L),I+1)$,\\
\indent   $-- L[I] = \texttt{select}(\texttt{seq-array}(N, L),I-1)$.


   Moreover, we have a piece of pointer arithmetic over these locations:\\
   $L[I] + V = \texttt{select}(\texttt{seq-array}(N, L),I+V)$,\\
   $++ L[I] = \texttt{select}(\texttt{seq-array}(N, L),I+1)$,\\
   $-- L[I] = \texttt{select}(\texttt{seq-array}(N, L),I-1)$.

   The lvalue of $L[I]$ is $\texttt{select}(\texttt{seq-array}(N, L),I)$, 
   and the rvalue of $L[I]$ is $\texttt{select}(A,I)$, where
   $\texttt{seq-array}(N, L),I)\texttt{ |-> } A$\texttt{:Array}.

  Since we did not considered yet the casting, we cannot write $A+I$ 
  but we can write $\&A[0] + I$. 

   The casting will be defined in a future iteration.

  */





