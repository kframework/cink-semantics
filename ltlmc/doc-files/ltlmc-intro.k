
/*@ \section{Introduction}

\Cink is a kernel of the \Cpp language we used to experiment with \K.
The language is used
an example for teaching classes and is refered in several research papers.

We assume the reader is already familiar with the \K Framework and the 
\KTool and here we try to share our experiece in defining a languages with some
specific features, as \Cpp is. 

\Cink is developed in several iterations, each iteration adding an incremental 
contribution.

This file includes an extension of the \Cink-threads iteration with a small 
property language, including LTL formulas, and we show how the \KTool is used 
together with Maude system for analazing \Cink programs.

The definition must be parsed with the command

  kompile cink --transition="kripke"

in order to use the model-checker. The model against to the LTL formulas are
checked is the transitional system where the transitions are given by the
rules annotated with the tag "kripke".


*/

