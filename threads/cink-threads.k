require "../basic/cink-basic-syntax.k"
require "../basic/cink-basic-semantics.k"

/*@ \section{The New Modules}


*/

module CINK-THREADS-SYNTAX
  imports CINK-BASIC-SYNTAX

  syntax Stmt ::= "std::thread" Id "(" Id "," Exps ")" ";"
                | "std::thread" Id "(" Id ")" ";"

  rule std::thread T:Id(F:Id); => std::thread T(F, .Exps); [macro]
endmodule

module CINK-THREADS-SEMANTICS
  imports CINK-THREADS-SYNTAX

  syntax K ::= "noName"


  /*@
    For now, \Cink includes a minimal support for threads, namely the creation 
    of a thread and the ending of a thread. The statement for creating a thread
    specifies the name of the thread \textit{T}, the name of a function
    \textit{F}, and the arguments \textit{El} of the function.
    The rule giving semantics to this statement, creates a new cell 
    \texttt{thread}, where the computation from the cell \texttt{k} of the new
    thread is the function call expression given as arguments, and the
    environment of the new thread is current environment of the current
    thread.
  */

  rule <thread>...
         <k> std::thread T:Id(F:Id, El:Exps); => . ...</k>
         <env> Env:Map </env>
       ...</thread>
       (. => 
        <thread>... 
          <name> T </name>  
          <k> F(El); </k>
          <env> Env </env>  
        ...</thread>
       )
       [kripke(thread)]

  /*@
    A thread is finished (and deleted) when the content of its \texttt{k}
    cell is empty:
  */
  rule <thread>... <k> .K </k>  ...</thread> => . [thread-end]

endmodule

