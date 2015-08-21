module Tips where

import Prelude

import Control.Alt ((<|>))
import Control.Monad.Aff (Aff(), launchAff)
import Control.Monad.Eff (Eff())
import Control.Monad.Eff.Console
import Control.Monad.Free (liftFI)

import Math (abs)
import Data.Int (toNumber, fromNumber)
import Data.Array
import Data.Maybe (Maybe(..))

import Halogen
import Halogen.Query.StateF (modify)
import Halogen.Util (appendToBody)
import qualified Halogen.HTML as H
import qualified Halogen.HTML.Events as E
import qualified Halogen.HTML.Properties as P

import Network.HTTP.Affjax (AJAX(), get)

import Player
import Team
import Tip


main :: Eff AppEffects Unit
main = launchAff $ do
  app <- runUI ui initialState
  appendToBody app.node


data Input a = Click a


type State = { player :: Player,  matchday :: Array Team }

initialState :: State
initialState = { player : Jan, matchday: matchday 1 }


type AppEffects = HalogenEffects (ajax :: AJAX)

ui :: forall eff p. Component State Input (Aff AppEffects) p
ui = component render eval
 where
  render :: Render State Input p
  render st =
    H.div [P.class_ (H.className "content")]
      [ H.h1 [P.class_ (H.className "jumbotron")]
        [H.text "Saison Spektakel 2015/16"]
      , header st.player
      , H.div [P.class_ (H.className "bs-example")] [tipTable (tipsForPlayer st.player) st.matchday] ]

  eval :: Eval Input State Input (Aff AppEffects)
  eval (Click next) = do
    pure next

header :: forall p i. Player -> H.HTML p i
header player =
  H.h2_ [H.text ("Spieler: " ++ (show player))]

tipTable :: forall p i. Array Team -> Array Team -> H.HTML p i
tipTable tip standings =
  H.table
    [P.class_ (H.className "table")]
    [H.thead_ [tipHeader], H.tbody_ (zipWith tipRow (range 1 (length tip)) tip)]
 where
  tipHeader = H.tr_ [H.th_ [H.text "#"], H.th_ [H.text "Verein"], H.th_ [H.text "Abstand"]]
  tipRow i team =
    let dist = rateTip standings team i
        t = trend standings team i
    in
    H.tr [rowColor dist t] [
      H.td_ [H.text (show i)],
      H.td_ [H.text (show team)],
      H.td_ [H.text (show dist)]]

rowColor :: forall i. Int -> Trend -> H.Prop i
rowColor dist trend =
  P.classes [H.className (trendClass trend), H.className (distClass dist)]
 where
  trendClass Correct = "correct"
  trendClass Worse   = "worse"
  trendClass Better  = "better"
  distClass i =
    case fromNumber (abs (toNumber i)) of
      Nothing -> "" -- should yield an error
      Just i  -> "dist-" ++ show i
