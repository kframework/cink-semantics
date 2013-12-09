/*@
 \section{Threads}
This file includes the extension of the starting iteration with a minimal support
for threads.

Fom the \Cpp manual:\\
\begin{quote}
A thread of execution (also known as a thread) is a single flow of 
control within a program, including the initial
invocation of a specific top-level function, and recursively 
including every function invocation subsequently
executed by the thread.
\\{} 
[ Note: When one thread creates another, the initial call to 
the top-level function of the new thread is executed by the new thread, 
not by the creating thread. —end note ]\\
Every thread in a program can potentially access every object and function 
in a program.\\
Under a hosted implementation, a C++ program can have more than one thread 
running concurrently. The execution of each thread proceeds
as defined by the remainder of this standard. The execution of the entire 
program consists of an execution of all of its threads.\\{}
[ Note: Usually the execution can be viewed as an interleaving of all its threads. 
However, some kinds of atomic operations, for example, allow executions 
inconsistent  with a simple interleaving, as described below. —end note ]\\
Under a freestanding implementation, it is implementation-defined whether
a program can have more than one thread of execution.\\
Implementations should ensure that all unblocked threads eventually make progress. 
\\ {}
[ Note: Standard
library functions may silently block on I/O or locks. 
Factors in the execution environment, including
externally-imposed thread priorities, may prevent an implementation 
from making certain guarantees of forward progress. —end note ]\\
The value of an object visible to a thread T at a particular point is 
the initial value of the object, a value
assigned to the object by T, or a value assigned to the object by 
another thread, according to the rules below.\\ {}
[ Note: In some cases, there may instead be undefined behavior. 
Much of this section is motivated by the desire to support atomic 
operations with explicit and detailed visibility constraints. 
However, it also implicitly supports a simpler view for more 
restricted programs. —end note ]
\end{quote}

*/

