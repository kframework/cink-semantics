require "../doc-files/preamble.k"
require "../doc-files/intro.k"
require "doc-files/ltlmc-intro.k"
require "doc-files/imports-intro.k"
require "builtins/model-checker.k"
require "../threads/cink-threads.k"

require "cink-ltlmc.k"

/*@  \section{The Main Module} */


module CINK

  imports CINK-LTLMC-SYNTAX
  imports CINK-THREADS-SYNTAX
  imports CINK-BASIC-SEMANTICS
  imports CINK-THREADS-SEMANTICS
  imports CINK-LTLMC-SEMANTICS

  configuration <T color="yellow">
                  <threads color="pink">
                    <thread multiplicity="*" color="purple"> 
                      <name color="yellow"> noName </name>
                      <k color="green"> ($PGM:Pgm ~> execute) </k>
                      <env color="LightSkyBlue"> .Map </env>
                      <br/>
                      <fstack color="orange"> .List </fstack>
                      <sideEffects>
                        <sideEffect multiplicity="*"> .K </sideEffect>
                      </sideEffects>
                      <return> .K </return>
                    </thread>
                  </threads>
                  <br/>
                  <genv color="SkyBlue"> .Map </genv>
                  <store color="white"> .Map </store>
                  <in color="magenta" stream="stdin"> .List </in>
                  <out color="Orchid" stream="stdout"> .List </out>
                </T>

endmodule




