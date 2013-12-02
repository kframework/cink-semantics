require "../doc-files/preamble.k"
require "../doc-files/intro.k"
require "doc-files/references-intro.k"
require "doc-files/imports-intro.k"
require "cink-references.k"


/*@ \section{The Main Module}
 
*/

module CINK
  imports CINK-REFERENCES-SYNTAX
  imports CINK-REFERENCES-SEMANTICS

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
