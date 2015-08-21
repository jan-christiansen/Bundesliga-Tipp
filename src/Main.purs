module Main where

import Prelude

import Control.Alt ((<|>))
import Control.Monad.Aff (Aff(), launchAff)
import Control.Monad.Eff (Eff())
import Control.Monad.Eff.Console
import Control.Monad.Free (liftFI)

import Data.Array
import Data.Functor (($>))
import Data.Either (Either(..))
import Data.Foreign.Class (readProp)

import Halogen
import Halogen.Query.StateF (modify)
import Halogen.Util (appendToBody)
import qualified Halogen.HTML as H
import qualified Halogen.HTML.Events as E

import Network.HTTP.Affjax (AJAX(), get)

import Player


-- pulp browserify > dist/app.js

type AppEffects = HalogenEffects (ajax :: AJAX)


main :: Eff AppEffects Unit
main = Tipp.main


-- main :: Eff AppEffects Unit
-- main = launchAff $ do
--   app <- runUI Tipp.ui Tipp.initialState
--   appendToBody app.node


-- data Input a = Click a


-- type State = { text :: String }

-- initialState :: State
-- initialState = { text : "test" }


-- type AppEffects = HalogenEffects (ajax :: AJAX)

-- ui :: forall eff p. Component State Input (Aff AppEffects) p
-- ui = Tipp.ui

-- ui :: forall eff p. Component State Input (Aff AppEffects) p
-- ui = component render eval
--  where
--   render :: Render State Input p
--   render st = pointsTable Player.entries

--   eval :: Eval Input State Input (Aff AppEffects)
--   eval (Click next) = do
--     result <- liftFI fetchJS
--     modify (_ { text = result })
--     pure next

-- pointsTable :: forall p i. Array Player.Entry -> H.HTML p i
-- pointsTable entries =
--   H.table_ (zipWith pointsRow (range 1 (length entries)) entries)
--  where
--   pointsRow i entry =
--     H.tr_ [
--       H.td_ [H.text (show i)],
--       H.td_ [H.text (show (entry.player))],
--       H.td_ [H.text (show (entry.points))]]


-- ui :: forall eff p. Component State Input (Aff AppEffects) p
-- ui = component render eval
--  where
--   render :: Render State Input p
--   render st =
--     H.div_ [H.text st.text
--            ,H.button [E.onClick (E.input_ Click)]
--                                 [H.text "click"]]


fetchJS :: forall eff. Aff (ajax :: AJAX | eff) String
fetchJS = do
  result <- get "http://api.football-data.org/alpha/soccerseasons/394/leagueTable"
  let response = result.response
  return case readProp "error" response of
    Right js -> js
    Left  _  -> "Error"
