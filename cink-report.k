/*!
\setlength{\parindent}{1em}
\usepackage{tikz}
\usetikzlibrary{shapes,arrows,positioning}

\title{CinK -- an experiment on how to think in \K}

\author{Dorel Lucanu (\texttt{dlucanu@info.uaic.ro})\\ and\\ 
        Traian Florin \c{S}erb\u{a}nu\c{t}\u{a} (\texttt{traian.serbanuta@info.uaic.ro})}

\organization{Alexandru Ioan Cuza University of Ia\c{s}i, Romania}

\newcommand{\myparagraph}[1]{\textbf{#1}}
\newcommand{\KTool}{\K tool\xspace}
\newcommand{\Cink}{CinK\xspace}
\newcommand{\Cpp}{\mbox{C\raisebox{.2ex}{\small\!+\!+}}\xspace}

%\usepackage[tight,style=bubble]{k}
\usepackage{epsfig}
%\usepackage{a4}
\setlength{\textwidth}{16cm}
\setlength{\textheight}{23.5cm}
\setlength{\topmargin}{-2.5cm}
\setlength{\oddsidemargin}{5mm}
\setlength{\evensidemargin}{5mm}
\setlength{\abovedisplayskip}{3mm}
\setlength{\belowdisplayskip}{3mm}
\setlength{\abovedisplayshortskip}{0mm}
\setlength{\belowdisplayshortskip}{2mm}
\setlength{\baselineskip}{12pt}
\setlength{\normalbaselineskip}{12pt}
\normalbaselines
\bibliographystyle{plain}
\pagestyle{empty}

\newcommand{\myparagraph}[1]{\textbf{#1}}
\newcommand{\KTool}{\K tool\xspace}
\newcommand{\Cink}{CinK\xspace}
\newcommand{\Cpp}{\mbox{C\raisebox{.2ex}{\small\!+\!+}}\xspace}

\centerline{\large\bf University ``Alexandru Ioan Cuza'' of Ia\c{s}i}
\centerline{\large\bf Faculty of Computer Science}
\noindent
\rule{\textwidth}{0.02in}

\vfill

\noindent
\begin{minipage}[c]{2cm}\Huge\bf
\vspace{.3in}
T\hfill\\
E\hfill\\
C\hfill\\
H\hfill\\
N\hfill\\
I\hfill\\
C\hfill\\
A\hfill\\
L\hfill\\
\vspace{.3in}

R\hfill\\
E\hfill\\
P\hfill\\
O\hfill\\
R\hfill\\
T\hfill\\
\end{minipage}
\begin{minipage}[c]{13.8cm}
\vspace{1in}

\begin{center}
\epsfig{file=doc-files/fii.eps,height=1.25in,width=1.25in}
\end{center}

\vspace{1in}

\noindent
\begin{center}
\fbox{
\begin{minipage}{10cm}
\centerline{~}
\begin{center}\Large\bf 
                 CinK -- an exercise on how to think in \K%%% titlu
\end{center}
\vspace{.3in}

\centerline{\Large\bf    Dorel Lucanu, Traian Florin \c{S}erb\u{a}nu\c{t}\u{a}}   %% author

\vspace{.3in}

\centerline{\Large\bf TR 12-03, \rm June 2012}
\centerline{~}
\end{minipage}
}
\end{center}

\vspace{1.3in}

\centerline{\Large\bf ISSN 1224-9327}
\centerline{~}
\end{minipage}

\vfill

\noindent
\rule{\textwidth}{0.02in}
\noindent\begin{minipage}[b]{4cm}
\begin{center}
\epsfig{file=doc-files/Siguniv.eps,height=1in,width=1in}
\end{center}
\end{minipage}
\begin{minipage}[b]{11cm}
\centerline{\large\bf Universitatea ``Alexandru Ioan Cuza'' Ia\c{s}i}
\centerline{\large\bf Facultatea de Informatic\u{a}}
\centerline{Str. Berthelot 16, 6600-Ia\c{s}i, Romania}
\centerline{Tel. +40-32-201090, email: bibl@infoiasi.ro}
\centerline{~}
\end{minipage}

\newpage
*/

//require "doc-files/preamble.k"
//require "doc-files/cover.k"
require "doc-files/intro.k"
require "basic/doc-files/basic-intro.k"
require "basic/cink-basic-syntax.k"
require "basic/cink-basic-semantics.k"
//require "basic/cink.k"

require "threads/doc-files/threads-intro.k"
require "threads/doc-files/imports-intro.k"

require "doc-files/concl.k"


/*@ \section{The Main Module}
Includes the modules defining the syntax and semantics, and defines 
the main configuration of the language.
*/



module CINK
  imports CINK-BASIC-SYNTAX
  imports CINK-BASIC-SEMANTICS

 /*@ \subsection{Configuration.} 
   The configuration is standard for such languages (compare it to that of IMPPP
   and SIMPLE).
  */


  configuration <T color="yellow">
                  <control color="pink">
                      <k color="green"> ($PGM:Pgm ~> execute) </k>
                      <env color="LightSkyBlue"> .Map </env>
                      <fstack color="orange"> .List </fstack>
                      <br/>
                      <return> .K </return>
                      <sideEffects>
                        <sideEffect multiplicity="*"> .K </sideEffect>
                      </sideEffects>
                  </control>
                  <br/>
                  <genv color="SkyBlue"> .Map </genv>
                  <store color="white"> .Map </store>
                  <in color="magenta" stream="stdin"> .List </in>
                  <out color="Orchid" stream="stdout"> .List </out>
                </T>
endmodule

