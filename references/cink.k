require "intro.k"
//require "imports-intro.k"
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
                      <return> .K </return>
                  </control>
                  <br/>
                  <genv color="SkyBlue"> .Map </genv>
                  <store color="white"> .Map </store>
                  <in color="magenta" stream="stdin"> .List </in>
                  <out color="Orchid" stream="stdout"> .List </out>
                  <sideEffects> .K </sideEffects>
                </T>
endmodule
