require "../doc-files/preamble.k"
require "../doc-files/intro.k"
require "doc-files/pointers-intro.k"
require "doc-files/imports-intro.k"
require "cink-pointers.k"


/*@ \section{The Main Module}
 
*/

module CINK
  imports CINK-POINTERS-SYNTAX
  imports CINK-POINTERS-SEMANTICS

  configuration <T color="yellow">
                  <control color="pink">
                      <k color="green"> ($PGM:Pgm ~> execute) </k>
                      <env color="LightSkyBlue"> .Map </env>
                      <fstack color="orange"> .List </fstack>
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
