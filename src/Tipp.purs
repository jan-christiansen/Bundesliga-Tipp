module Tipp where

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


data Team =
    Bayern
  | Leverkusen
  | Dortmund
  | Wolfsburg
  | Mainz
  | Schalke
  | Gladbach
  | Hannover
  | Hoffenheim
  | Stuttgart
  | Hamburg
  | Bremen
  | Augsburg
  | Frankfurt
  | Koeln
  | Berlin
  | Darmstadt
  | Ingolstadt

instance eqTeam :: Eq Team where
  eq Bayern Bayern = true
  eq Leverkusen Leverkusen = true
  eq Dortmund Dortmund = true
  eq Wolfsburg Wolfsburg = true
  eq Mainz Mainz = true
  eq Schalke Schalke = true
  eq Gladbach Gladbach = true
  eq Hannover Hannover = true
  eq Hoffenheim Hoffenheim = true
  eq Stuttgart Stuttgart = true
  eq Hamburg Hamburg = true
  eq Bremen Bremen = true
  eq Augsburg Augsburg = true
  eq Frankfurt Frankfurt = true
  eq Koeln Koeln = true
  eq Berlin Berlin = true
  eq Darmstadt Darmstadt = true
  eq Ingolstadt Ingolstadt = true  
  eq _ _ = false

instance showTeam :: Show Team where
  show Bayern = "FC Bayern München"
  show Leverkusen = "Bayer 04 Leverkusen"
  show Dortmund = "BVB Borussia Dortmund"
  show Wolfsburg = "VfL Wolfsburg"
  show Mainz = "FSV Mainz 05"
  show Schalke = "FC Schalke 04"
  show Gladbach = "Borussia Mönchengladbach"
  show Hannover = "Hannover 96"
  show Hoffenheim = "TSV 1899 Hoffenheim"
  show Stuttgart = "VfB Stuttgart"
  show Hamburg = "Hamburger SV"
  show Bremen = "SV Werder Bremen"
  show Augsburg = "FC Augburg"
  show Frankfurt = "Eintracht Frankfurt"
  show Koeln = "1.FC Köln"
  show Berlin = "Hertha BSC Berlin"
  show Darmstadt = "SV Darmstadt 98"
  show Ingolstadt = "FC Ingolstadt 04"


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
      , H.div [P.class_ (H.className "bs-example")] [tipTable (tipForPlayer st.player) st.matchday] ]

  eval :: Eval Input State Input (Aff AppEffects)
  eval (Click next) = do
    pure next

header :: forall p i. Player -> H.HTML p i
header player =
  H.h2_ [H.text ("Spieler: " ++ (show player))]

tipTable :: forall p i. Array Team -> Array Team -> H.HTML p i
tipTable tip matchday =
  H.table
    [P.class_ (H.className "table")]
    [H.thead_ [tipHeader], H.tbody_ (zipWith tipRow (range 1 (length tip)) tip)]
 where
  tipHeader = H.tr_ [H.th_ [H.text "#"], H.th_ [H.text "Verein"], H.th_ [H.text "Abstand"]]
  tipRow i team =
    let dist = distance team i matchday
    in
    H.tr [rowColor dist] [
      H.td_ [H.text (show i)],
      H.td_ [H.text (show team)],
      H.td_ [H.text (show dist)]]
  distance team pos matchday =
    case elemIndex team matchday of
         Nothing -> 0 -- should yield an error
         Just i  -> metric pos (i+1)

metric :: Int -> Int -> Int
metric tip actual = tip - actual
  -- case fromNumber (abs (toNumber i-toNumber j)) of
  --      Nothing -> 0 -- should yield an error
  --      Just i  -> i

rowColor :: forall i. Int -> H.Prop i
rowColor i = P.classes [H.className (trend i), H.className (dist i)]
 where
  trend i = if i==0 then "correct" else if i>0 then "better" else "worse"
  dist i = case fromNumber (abs (toNumber i)) of
                Nothing -> ""
                Just i  -> "dist-" ++ show i

matchday :: Int -> Array Team
matchday _ =
  [ Bayern
  , Dortmund
  , Schalke
  , Koeln
  , Leverkusen
  , Wolfsburg
  , Berlin
  , Ingolstadt
  , Darmstadt
  , Hannover
  , Frankfurt
  , Hoffenheim
  , Augsburg
  , Mainz
  , Stuttgart
  , Bremen
  , Gladbach    
  , Hamburg
  ]

tipForPlayer :: Player -> Array Team
tipForPlayer JanWulf =
   [ Bayern, Leverkusen, Dortmund
   , Wolfsburg, Mainz, Schalke
   , Gladbach, Hannover, Hoffenheim
   , Stuttgart, Hamburg, Bremen
   , Augsburg, Frankfurt, Koeln
   , Berlin, Darmstadt, Ingolstadt ]
tipForPlayer Christoph =
    [ Bayern, Gladbach, Wolfsburg
    , Leverkusen, Schalke, Dortmund
    , Hoffenheim, Augsburg, Bremen
    , Mainz, Frankfurt, Koeln
    , Hannover, Berlin, Ingolstadt
    , Hamburg, Darmstadt, Stuttgart ]
tipForPlayer Johannes =
    [ Bayern, Dortmund, Wolfsburg
    , Leverkusen, Gladbach, Schalke
    , Mainz, Augsburg, Hoffenheim
    , Bremen, Frankfurt, Stuttgart
    , Koeln, Hamburg, Berlin
    , Hannover, Darmstadt, Ingolstadt ]
tipForPlayer Jan =
    [ Bayern, Gladbach, Dortmund
    , Wolfsburg, Leverkusen, Stuttgart
    , Augsburg, Koeln, Schalke
    , Bremen, Mainz, Hamburg
    , Hoffenheim, Ingolstadt, Frankfurt
    , Berlin, Hannover, Darmstadt ]
tipForPlayer JR =
    [ Bayern, Gladbach, Wolfsburg
    , Schalke, Leverkusen, Dortmund
    , Mainz, Stuttgart, Berlin
    , Hoffenheim, Augsburg, Koeln
    , Bremen, Hamburg, Ingolstadt
    , Hannover, Frankfurt, Darmstadt ]
tipForPlayer Ulf =
    [ Bayern, Wolfsburg, Dortmund
    , Leverkusen, Gladbach, Schalke
    , Augsburg, Hoffenheim, Mainz
    , Bremen, Stuttgart, Frankfurt
    , Hannover, Koeln, Hamburg
    , Berlin , Ingolstadt, Darmstadt ]
tipForPlayer Mirko =
    [ Wolfsburg, Bayern, Dortmund
    , Leverkusen, Gladbach, Schalke
    , Hamburg, Augsburg, Bremen
    , Berlin, Mainz, Stuttgart
    , Hoffenheim, Ingolstadt, Koeln
    , Hannover, Frankfurt, Darmstadt ] 
tipForPlayer Julia =
    [ Bayern, Dortmund, Wolfsburg
    , Leverkusen, Gladbach, Schalke
    , Frankfurt, Augsburg, Hannover
    , Mainz, Darmstadt, Stuttgart
    , Hamburg, Hoffenheim, Bremen
    , Berlin, Koeln, Ingolstadt ]
tipForPlayer Daniel =
    [ Dortmund, Bayern, Wolfsburg
    , Gladbach, Frankfurt, Leverkusen
    , Augsburg, Schalke, Bremen
    , Hannover, Hoffenheim, Mainz
    , Koeln, Stuttgart, Hamburg
    , Berlin, Darmstadt, Ingolstadt ]
tipForPlayer Sandra =
    [ Gladbach, Bayern, Wolfsburg
    , Dortmund, Leverkusen, Hoffenheim
    , Bremen, Augsburg, Schalke
    , Frankfurt, Mainz, Hamburg
    , Ingolstadt, Stuttgart, Koeln
    , Berlin, Hannover, Darmstadt ]
