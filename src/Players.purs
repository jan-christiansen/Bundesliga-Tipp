module Players where

import Prelude

import Control.Bind ((=<<))
import Control.Alt ((<|>))
import Control.Monad.Aff (Aff(), launchAff, later')
import Control.Monad.Eff (Eff())
import Control.Monad.Free (liftFI)

import Math (abs)
import Data.Int (toNumber, fromNumber)
import Data.Array
import Data.Maybe (Maybe(..))
import Data.Either

import Control.Monad.Eff.Class (MonadEff, liftEff)
import Halogen
import Halogen.Query.StateF (modify)
import Halogen.Util (appendToBody)
import qualified Halogen.HTML as H
import qualified Halogen.HTML.Events as E
import qualified Halogen.HTML.Properties as P
import DOM (DOM())
import DOM.Event.EventTarget (eventListener, addEventListener)
import DOM.Event.EventTypes (readystatechange)
import DOM.Event.Types (Event())
import DOM.HTML (window)
import DOM.HTML.Document (body)
import DOM.HTML.Types (HTMLElement(), htmlElementToNode, windowToEventTarget)

import Network.HTTP.Affjax (AJAX(), get)

import Team
import Player
import Tip
import Standings


type AppEffects = HalogenEffects (ajax :: AJAX)

main :: Eff AppEffects Unit
main = launchAff $ do
  app <- runUI ui initialState
  appendToBody app.node
  -- w <- window
  -- addEventListener
  --   readystatechange
  --   (eventListener (temp app.driver))
  --   false
  --   (windowToEventTarget w)
  --     where
  --       temp :: Driver Input (ajax :: AJAX) -> Event -> Eff AppEffects Unit
  --       temp driver _ = launchAff (driver (action Load))

  
-- avar :: AVAR, err :: EXCEPTION, dom :: DOM | eff)

-- Natural f (Aff (HalogenEffects eff))

-- Aff (HalogenEffects eff) { node :: HTMLElement, driver :: Driver f eff }

-- addEventListener :: forall eff. EventType
--                     -> EventListener (dom :: DOM | eff)
--                     -> Boolean
--                     -> EventTarget -> Eff (dom :: DOM | eff) Unit

-- eventListener :: forall eff a. (Event -> Eff eff a) -> EventListener eff                       


data Input a =
    SelectPlayer Player a
  | Load a

type Entry = { player :: Player, points :: Int }

data State =
    Loading
  | Error String
  | Players (Array Team)
  | Tips Player (Array Team)


initialState :: State
initialState = Loading

entriesForStandings :: Array Team -> Array Entry
entriesForStandings standings =
  map (\p -> { player: p, points: ratePlayer standings p }) allPlayers


ui :: forall eff p. Component State Input (Aff AppEffects) p
ui = component render eval
 where
  render :: Render State Input p
  render Loading =
    H.h1_ [H.text "Loading Data..."]
  render (Error text) = H.text ("An error occurred: " ++ text)
  render (Players standings) =
    let entries = entriesForStandings standings
    in
    H.div [P.class_ (H.className "content")]
      [ H.h1 [P.class_ (H.className "jumbotron")]
        [H.text "Saison Spektakel 2015/16"]
      , H.div [P.class_ (H.className "bs-example")] [pointsTable entries] ]
  render (Tips player standings) =
    H.div [P.class_ (H.className "content")]
      [ H.h1 [P.class_ (H.className "jumbotron")]
        [H.text "Saison Spektakel 2015/16"]
      , H.h2_ [H.text ("Spieler: " ++ (show player))]
      , H.div [P.class_ (H.className "bs-example")] [tipTable (tipsForPlayer player) standings] ]

  eval :: Eval Input State Input (Aff AppEffects)
  eval (Load next) = do
    teamsM <- liftFI (standings 1)
    case teamsM of
      Left text   -> modify (\_ -> Error text)
      Right teams -> modify (\_ -> Players teams)
    pure next
  eval (SelectPlayer player next) = do
    teamsM <- liftFI (standings 1) -- load new???
    case teamsM of
      Left text   -> modify (\_ -> Error text)
      Right teams -> modify (\_ -> Tips player teams)
    pure next


pointsTable :: forall p i. Array Entry -> H.HTML p (Input Unit)
pointsTable entries =
  H.table
    [P.class_ (H.className "table")]
    [H.thead_ [pointsHeader], H.tbody_ (zipWith pointsRow (range 1 (length entries)) entries)]
 where
  pointsHeader = H.tr_ [H.th_ [H.text "#"], H.th_ [H.text "Tipper"], H.th_ [H.text "Punkte"]]
  pointsRow i entry =
    H.tr_
      [ H.td_ [H.text (show i)]
      , H.td_ [H.button [E.onClick (E.input_ (SelectPlayer entry.player))] [H.text (show entry.player)]]
      , H.td_ [H.text (show entry.points)] ]

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
