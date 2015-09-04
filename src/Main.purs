module Main where

-- ulimit -n 2560
-- pulp browserify > dist/app.js

import Prelude

import Control.Bind ((=<<))
import Control.Monad.Aff (Aff(), launchAff, later')
import Control.Monad.Eff (Eff())
import Control.Monad.Eff.Console (print)
import Control.Monad.Free (liftFI)
import Data.Traversable (for)
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
import Routing (matches)

import Routes
import Team
import Player
import Tip
import Standings
import qualified Bootstrap as B


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

type Matchday = Int

data Input a =
    SelectPlayer Player a
  | SelectDay Matchday a
  | Overview a
  | Use Metric a

type MatchdayState =
  { standings :: Array Team
  , currentMatchday :: Matchday
  , maxMatchday :: Matchday
  }

data State =
    Loading
  | Error String
  | Players Metric MatchdayState
  | Tips Player Metric MatchdayState

updateMatchday :: Array Team -> Matchday -> State -> State
updateMatchday _ _ l@Loading   = l
updateMatchday _ _ e@(Error _) = e
updateMatchday standings day (Tips p m s) =
  Tips p m { standings: standings, currentMatchday: day, maxMatchday: s.maxMatchday }
updateMatchday standings day (Players m s) =
  Players m { standings: standings, currentMatchday: day, maxMatchday: s.maxMatchday }

updateMetric :: Metric -> State -> State
updateMetric _      l@Loading     = l
updateMetric _      e@(Error _)   = e
updateMetric metric (Tips p _ s)  = Tips p metric s
updateMetric metric (Players _ s) = Players metric s


initialState :: State
initialState = Loading

initialMetric :: Metric
initialMetric = Manhattan

metric :: State -> Metric
metric (Tips _ metric _ )  = metric
metric (Players metric _ ) = metric
metric _                   = initialMetric

matchdayState :: forall eff a. State -> Aff (ajax :: AJAX | eff) (Either String MatchdayState)
matchdayState (Tips _ _ state)  = return (Right state)
matchdayState (Players _ state) = return (Right state)
matchdayState _ = do
  tableE <- leagueTable Nothing
  return (do
    LeagueTable maxDay sts <- tableE
    return { standings: sts, currentMatchday: maxDay, maxMatchday: maxDay })


ui :: forall eff p. Component State Input (Aff AppEffects) p
ui = component render eval

render :: forall p. Render State Input p
render Loading =
  renderPage [H.h1_ [H.text "Loading Data..."]]
render (Error text) =
  renderPage [H.text ("An error occurred: " ++ text)]
render (Players metric s) =
  let entries = entriesForStandings metric s.standings
  in
  renderPage
    [ renderCurrentTable s.standings
    , renderMetrics metric
    , H.div [P.class_ (H.className "main-content")]
            [ H.div [P.class_ (H.className "bs-example")] [pointsTable entries] ]
    , renderMatchdays s
    ]
render (Tips player metric s) =
  renderPage
    [ renderCurrentTable s.standings
    , renderMetrics metric
    , H.div [P.class_ (H.className "main-content")]
            [ H.div [ P.class_ (H.className "players-nav") ]
                    [ H.h2_ [H.text (show player)]
                    , H.a [P.href (reverseRoute PlayersRoute)] [H.text "Zur Übersicht"]
                    ]
            , H.div [P.class_ (H.className "bs-example")] [tipTable metric (tipsForPlayer player) s.standings]
            ]
    , renderMatchdays s
    ]

eval :: Eval Input State Input (Aff AppEffects)
eval (Overview next) = do
  s <- S.get
  S.modify (const Loading)
  stateE <- liftFI (matchdayState s)
  case stateE of
    Left text       -> S.modify (\_ -> Error text)
    Right matchdayS -> S.modify (\_ -> Players (metric s) matchdayS)
  pure next
eval (SelectPlayer player next) = do
  s <- S.get
  S.modify (const Loading)
  stateE <- liftFI (matchdayState s)
  case stateE of
    Left text       -> S.modify (\_ -> Error text)
    Right matchdayS -> S.modify (\_ -> Tips player (metric s) matchdayS)
  pure next
eval (SelectDay day next) = do
  s <- S.get
  S.modify (const Loading)
  tableE <- liftFI (leagueTable (Just day))
  S.modify (\_ -> case tableE of
                    Left text   -> Error text
                    Right table -> updateMatchday (standings table) day s)
  pure next
eval (Use metric next) = do
  S.modify (updateMetric metric)
  pure next


renderPage :: forall p i. Array (H.HTML p i) -> H.HTML p i
renderPage contents =
  H.div [P.class_ (H.className "content")]
    ( H.h1 [P.class_ (H.className "jumbotron")] [H.text "Saison Spektakel 2015/16"]
    : contents )

renderMatchdays :: forall p. MatchdayState -> H.HTML p (Input Unit)
renderMatchdays s =
  H.div [P.class_ (H.className "matchdays")]
        [ B.navPills (map row (range 1 s.maxMatchday)) ]
 where
  row day' =
    Tuple
      (H.a [ E.onClick (E.input_ (SelectDay day')) ] [ H.text (show day') ])
      (s.currentMatchday==day')

renderMetrics :: forall p. Metric -> H.HTML p (Input Unit)
renderMetrics metric =
  B.navTabs
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
      , H.td_ [H.text (pretty team)]
      , H.td_ [H.text (showNumber p 1)] ]

rowColor :: forall i. Int -> Trend -> H.Prop i
rowColor dist trend =
  P.classes [H.className (trendClass trend), H.className (distClass dist)]
 where
  trendClass Correct = "correct"
  trendClass Worse   = "worse"
  trendClass Better  = "better"
  distClass i = "dist-" ++ show i

renderCurrentTable :: forall p i. Array Team -> H.HTML p i
renderCurrentTable standings =
  H.div [P.class_ (H.className "current-table")]
        (map row (chunks 3 icons) ++
        [ H.div [P.class_ (H.className "clear")] [] ])
 where
  row icons = H.div [P.class_ (H.className "current-table-row")] icons
  icons = map icon standings
  icon team =
    H.div [P.class_ (H.className "team")]
          [H.img [ P.src ("images/" ++ show team ++ ".svg")
                 , P.class_ (H.className "icon")
                 ]
          ]

chunks :: forall a. Int -> Array a -> Array (Array a)
chunks _ [] = []
chunks i xs = take i xs : chunks i (drop i xs)

showNumber :: Number -> Int -> String
showNumber p d = show (roundTo p d)
 
roundTo :: Number -> Int -> Number
roundTo x d = round (x * m) / m
 where
  m = pow 10.0 (toNumber d)
