module Main where

import Prelude
import Control.Monad.Eff (Eff())
import Network.HTTP.Affjax (AJAX())
import Halogen

import qualified Players as P


-- ulimit -n 2560

-- pulp browserify > dist/app.js


main :: Eff (HalogenEffects (ajax :: AJAX)) Unit
main = P.main
