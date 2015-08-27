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
import Math (abs, round, pow)
import Data.Int (toNumber, fromNumber)
import Data.Array
import Data.Maybe (Maybe(..), maybe)
import Data.Either
import Data.Function (on)
import Data.Tuple (Tuple(..))

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
import qualified Bootstrap as B


-- Routing

data Route = PlayersRoute | TipsRoute Player

reverseRoute :: Route -> String
reverseRoute PlayersRoute  = "#overview"
reverseRoute (TipsRoute p) = "#tips/" ++ playerLit p

routing :: Match Route
routing =
  const PlayersRoute <$> lit "overview"
    <|>
  TipsRoute <$> (lit "tips" *> routingPlayer)

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
playerLit Henning = "henning"
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
  route driver PlayersRoute  = launchAff (driver (action Overview))
  route driver (TipsRoute p) = launchAff (driver (action (SelectPlayer p)))


data Input a =
    SelectPlayer Player a
  | Overview a
  | Use Metric a

data State =
    Loading
  | Error String
  | Players Metric (Array Team)
  | Tips Player Metric (Array Team)


initialState :: State
initialState = Loading

initialMetric :: Metric
initialMetric = Manhattan

ui :: forall eff p. Component State Input (Aff AppEffects) p
ui = component render eval
 where
  render :: Render State Input p
  render Loading =
    renderPage [H.h1_ [H.text "Loading Data..."]]
  render (Error text) =
    renderPage [H.text ("An error occurred: " ++ text)]
  render (Players metric standings) =
    let entries = entriesForStandings metric standings
    in
    renderPage
      [ H.div [P.class_ (H.className "bs-example")] [pointsTable entries]
      , renderMetrics metric
      ]
  render (Tips player metric standings) =
    renderPage
      [ H.table [P.class_ (H.className "main-table") ]
        [ H.tr_
          [ H.td [ P.class_ (H.className "nav-col") ]
                 [ H.h2_ [H.text (show player)]
                 , H.a [P.href (reverseRoute PlayersRoute)] [H.text "Zur Übersicht"]
                 ]
          , H.td [ P.class_ (H.className "content-col") ]
                 [tipTable metric (tipsForPlayer player) standings]
          , H.td_ []
          ]
        ]
      , renderMetrics metric
      ]

  eval :: Eval Input State Input (Aff AppEffects)
  eval (Overview next) = do
    s <- S.get
    stateE <- currentState s
    case stateE of
      Left text -> S.modify (\_ -> Error text)
      Right (Tuple metric standings) -> S.modify (\_ -> Players metric standings)
    pure next
  eval (SelectPlayer player next) = do
    s <- S.get
    stateE <- currentState s
    case stateE of
      Left text   -> S.modify (\_ -> Error text)
      Right (Tuple metric standings) -> S.modify (\_ -> Tips player metric standings)
    pure next
  eval (Use metric next) = do
    S.modify (evalMetric metric)
    pure next

  evalMetric _ Loading = Loading
  evalMetric _ (Error t) = Error t
  evalMetric metric (Tips p _ standings) = Tips p metric standings
  evalMetric metric (Players _ standings) = Players metric standings  

  currentState (Tips _ metric standings)  = return (Right (Tuple metric standings))
  currentState (Players metric standings) = return (Right (Tuple metric standings))
  currentState _ = do
    S.modify (\_ -> Loading)
    standingsE <- liftFI (standings 1)
    return (map (Tuple initialMetric) standingsE)

renderPage :: forall p i. Array (H.HTML p i) -> H.HTML p i
renderPage contents =
  H.div [P.class_ (H.className "content")]
    ((H.h1 [P.class_ (H.className "jumbotron")] [H.text "Saison Spektakel 2015/16"])
     : contents)

renderMetrics :: forall p. Metric -> H.HTML p (Input Unit)
renderMetrics metric =
  B.navPills
    [ row "Manhattan" Manhattan 
    , row "Euklid" Euclid
    , row "Wulf" Wulf
      ]
 where
  row name metric' =
    Tuple (H.a [ E.onClick (E.input_ (Use metric')) ] [ H.text name ]) (metric==metric')

type Entry = { player :: Player, points :: Number }

entriesForStandings :: Metric -> Array Team -> Array Entry
entriesForStandings metric standings =
  sortBy
    (compare `on` _.points)
    (map (\p -> { player: p, points: ratePlayer metric standings p }) allPlayers)

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
      , H.td_ [H.a [P.href (reverseRoute (TipsRoute entry.player))] [H.text (show entry.player)]]
      , H.td_ [H.text (showNumber entry.points 1)] ]

tipTable :: forall p i. Metric -> Array Team -> Array Team -> H.HTML p i
tipTable metric tip standings =
  H.table
    [P.class_ (H.className "table")]
    [H.thead_ [tipHeader], H.tbody_ (zipWith tipRow (range 1 (length tip)) tip)]
 where
  tipHeader = H.tr_ [H.th_ [H.text "#"], H.th_ [H.text "Verein"], H.th_ [H.text "Abstand"]]
  tipRow i team =
    let dist = case fromNumber (rateTip Manhattan standings team i) of
                    Just i -> i
        p = rateTip metric standings team i
        t = trend standings team i
    in
    H.tr
      [rowColor dist t]
      [ H.td_ [H.text (show i)]
      , H.td_ [H.text (show team)]
      , H.td_ [H.text (showNumber p 1)] ]

rowColor :: forall i. Int -> Trend -> H.Prop i
rowColor dist trend =
  P.classes [H.className (trendClass trend), H.className (distClass dist)]
 where
  trendClass Correct = "correct"
  trendClass Worse   = "worse"
  trendClass Better  = "better"
  distClass i = "dist-" ++ show i


showNumber :: Number -> Int -> String
showNumber p d = show (roundTo p d)
 
roundTo :: Number -> Int -> Number
roundTo x d = round (x * m) / m
 where
  m = pow 10.0 (toNumber d)
