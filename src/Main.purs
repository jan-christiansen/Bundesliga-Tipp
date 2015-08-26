module Main where

-- ulimit -n 2560
-- pulp browserify > dist/app.js

import Prelude

import Control.Bind ((=<<))
import Control.Alt ((<|>))
import Control.Plus (empty)
import Control.Apply ((*>))
import Control.Monad.Aff (Aff(), launchAff, later')
import Control.Monad.Eff (Eff())
import Control.Monad.Eff.Console (print)
import Control.Monad.Free (liftFI)
import Data.Foldable (foldr)

import Math (abs)
import Data.Int (toNumber, fromNumber)
import Data.Array
import Data.Maybe (Maybe(..))
import Data.Either
import Data.Function (on)

import Control.Monad.Eff.Class (MonadEff, liftEff)
import Halogen
import qualified Halogen.Query.StateF as S
import Halogen.Util (appendToBody)
import qualified Halogen.HTML as H
import qualified Halogen.HTML.Events as E
import qualified Halogen.HTML.Properties as P
import DOM (DOM())
import DOM.Event.EventTarget (eventListener, addEventListener)
import DOM.Event.EventTypes (readystatechange, load)
import DOM.Event.Types (Event())
import DOM.HTML (window)
import DOM.HTML.Document (body)
import DOM.HTML.Types (HTMLElement(), htmlElementToNode, windowToEventTarget)

import Network.HTTP.Affjax (AJAX(), get)

import Routing
import Routing.Match
import Routing.Match.Class

import Team
import Player
import Tip
import Standings


-- Routing

data Route = Players | Tips Player

reverseRoute :: Route -> String
reverseRoute Players  = ""
reverseRoute (Tips p) = "#tips/" ++ playerLit p

routing :: Match Route
routing =
  const Players <$> lit ""
    <|>
  const (Tips Jan) <$> (lit "tips" *> routingPlayer)

routingPlayer :: Match Player
routingPlayer =
  foldr (<|>) empty (map (\p -> const p <$> lit (playerLit p)) allPlayers)

playerLit :: Player -> String
playerLit JanWulf = "janw"
playerLit Jan = "jan"
playerLit JR = "jr"
playerLit Christoph = "christoph"
playerLit Johannes = "johannes"
playerLit Julia = "julia"
playerLit Daniel = "daniel"
playerLit Mirko = "mirko"
playerLit Ulf = "ulf"
playerLit Sandra = "sandra"
playerLit Maike = "maike"
playerLit Nikita = "nikita"
playerLit Spiegel = "spiegel"


-- Main Application

type AppEffects = HalogenEffects (ajax :: AJAX)

main :: Eff AppEffects Unit
main = launchAff $ do
  app <- runUI ui initialState
  appendToBody app.node
  w <- liftEff window
  liftEff $
    addEventListener
      load
      (eventListener (\_ -> matches routing $ \_ new -> route app.driver new))
      false
      (windowToEventTarget w)
 where
  route driver Players  = launchAff (driver (action Overview))
  route driver (Tips p) = launchAff (driver (action (SelectPlayer p)))


data Input a =
    SelectPlayer Player a
  | Overview a

type Entry = { player :: Player, points :: Int }

data State =
    Loading
  | Error String
  | RenderPlayers (Array Team)
  | RenderTips Player (Array Team)


initialState :: State
initialState = Loading

entriesForStandings :: Array Team -> Array Entry
entriesForStandings standings =
  sortBy
    (compare `on` _.points)
    (map (\p -> { player: p, points: ratePlayer standings p }) allPlayers)


ui :: forall eff p. Component State Input (Aff AppEffects) p
ui = component render eval
 where
  render :: Render State Input p
  render Loading =
    renderPage [H.h1_ [H.text "Loading Data..."]]
  render (Error text) =
    renderPage [H.text ("An error occurred: " ++ text)]
  render (RenderPlayers standings) =
    let entries = entriesForStandings standings
    in
    renderPage [H.div [P.class_ (H.className "bs-example")] [pointsTable entries]]
  render (RenderTips player standings) =
    renderPage
      [ H.h2_ [H.text ("Spieler: " ++ (show player))]
      , H.a [P.href (reverseRoute Players)] [H.text "Zur Übersicht"]
      , H.div [P.class_ (H.className "bs-example")] [tipTable (tipsForPlayer player) standings] ]

  eval :: Eval Input State Input (Aff AppEffects)
  eval (Overview next) = do
    s <- S.get
    teamsM <- teams s
    case teamsM of
      Left text   -> S.modify (\_ -> Error text)
      Right teams -> S.modify (\_ -> RenderPlayers teams)
    pure next
  eval (SelectPlayer player next) = do
    s <- S.get
    teamsM <- teams s
    case teamsM of
      Left text   -> S.modify (\_ -> Error text)
      Right teams -> S.modify (\_ -> RenderTips player teams)
    pure next

  teams (RenderTips _ standings)  = return (Right standings)
  teams (RenderPlayers standings) = return (Right standings)
  teams _                         = do
    S.modify (\_ -> Loading)
    liftFI (standings 1)

renderPage :: forall p i. Array (H.HTML p i) -> H.HTML p i
renderPage contents =
  H.div [P.class_ (H.className "content")]
    ((H.h1 [P.class_ (H.className "jumbotron")] [H.text "Saison Spektakel 2015/16"]) : contents)

pointsTable :: forall p. Array Entry -> H.HTML p (Input Unit)
pointsTable entries =
  H.table
    [P.class_ (H.className "table")]
    [H.thead_ [pointsHeader], H.tbody_ (zipWith pointsRow (range 1 (length entries)) entries)]
 where
  pointsHeader = H.tr_ [H.th_ [H.text "#"], H.th_ [H.text "Tipper"], H.th_ [H.text "Punkte"]]
  pointsRow i entry =
    H.tr_
      [ H.td_ [H.text (show i)]
      , H.td_ [H.a [P.href (reverseRoute (Tips entry.player))] [H.text (show entry.player)]]
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
    H.tr
      [rowColor dist t]
      [ H.td_ [H.text (show i)]
      , H.td_ [H.text (show team)]
      , H.td_ [H.text (show dist)] ]

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
