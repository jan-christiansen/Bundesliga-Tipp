module Main where

-- ulimit -n 2560
-- pulp browserify > dist/app.js

import Prelude

import Control.Apply ((*>))
import Control.Bind ((=<<))
import Control.Monad.Aff (Aff(), launchAff, later')
import Control.Monad.Eff (Eff())
import Control.Monad.Eff.Console (print)
import Control.Monad.Free (liftFI)
import Data.Traversable (for, traverse)
import Data.Int (toNumber, fromNumber)
import Data.Array
import Data.Maybe (Maybe(..), maybe)
import Data.Either
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
import DOM.Event.EventTypes (readystatechange, load, resize)
import DOM.Event.Types (Event())
import DOM.HTML (window)
import DOM.HTML.Document (body)
import DOM.HTML.Types (HTMLElement(), htmlElementToNode, windowToEventTarget)
import Network.HTTP.Affjax (AJAX(), get)
import Routing (matches)

import Util
import Routes
import Team
import Player
import Tip
import Standings
import Ranking (Ranking(), rankingsForStandings)
import Ratings (Rating(), ratings)
import Charts (renderRatingsChart)
import qualified Bootstrap as B


-- Main Application

type AppEffects = HalogenEffects (ajax :: AJAX)

main :: Eff AppEffects Unit
main = launchAff $ do
  app <- runUI ui initialState
  appendToBody app.node
  w <- liftEff window
  liftEff (onLoad (matches routing $ \_ new -> route app.driver new))
 where
  route driver PlayersRoute  = launchAff (driver (action Overview))
  route driver (TipsRoute p) = launchAff (driver (action (SelectPlayer p)))

onLoad :: forall eff a. Eff (dom :: DOM | eff) a -> Eff (dom :: DOM | eff) Unit
onLoad handler = do
  w <- window
  addEventListener load (eventListener (const handler)) false (windowToEventTarget w)

onResize :: forall eff a. Eff (dom :: DOM | eff) a -> Eff (dom :: DOM | eff) Unit
onResize handler = do
  w <- window
  addEventListener resize (eventListener (const handler)) false (windowToEventTarget w)


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

matchdayState :: forall eff. State -> Aff (ajax :: AJAX | eff) (Either String MatchdayState)
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
  let rankings = rankingsForStandings metric s.standings
  in
  renderPage
    [ renderCurrentTable s.standings
    , renderMetrics metric
    , H.div [ P.class_ (H.className "main-content") ]
            [ H.div [P.class_ (H.className "bs-example")]
                    [ pointsTable rankings ]
            ]
    , chartDiv
    , chartDiv2
    ]
 where
  chartDiv = H.div [P.class_ (H.className "ratings-chart")] []
  chartDiv2 = H.div [P.class_ (H.className "ratings-chart-2")] []
render (Tips player metric s) =
  renderPage
    [ renderCurrentTable s.standings
    , renderMetrics metric
    , H.div [P.class_ (H.className "main-content")]
            [ H.div [ P.class_ (H.className "players-nav") ]
                    [ H.h2_ [H.text (pretty player)]
                    , H.a [P.href (reverseRoute PlayersRoute)] [H.text "Zur Übersicht"]
                    ]
            , H.div [P.class_ (H.className "bs-example")]
                    [ratingsTable (ratings metric (tipsForPlayer player) s.standings)]
            ]
    , chartDiv
    , chartDiv2
    , renderMatchdays s
    ]
 where
  chartDiv = H.div [P.class_ (H.className "ratings-chart")] []
  chartDiv2 = H.div [P.class_ (H.className "ratings-chart-2")] []


renderRatingsCharts :: Boolean -> Metric -> Array (Tuple Player (Array Rating)) -> String -> Aff AppEffects Unit
renderRatingsCharts aggregated metric playerRatings className = liftEff $ do
  chartM <- renderRatingsChart aggregated metric playerRatings className
  case chartM of
       Nothing -> return unit
       Just c  -> onResize (ECharts.Chart.resize c)  

renderCharts :: State -> Aff AppEffects Unit
renderCharts Loading = return unit
renderCharts (Error _) = return unit
renderCharts s@(Players m mS) =
  let players = map _.player (rankingsForStandings (metric s) mS.standings)
      playerRatings = map (\p -> Tuple p (ratings (metric s) (tipsForPlayer p) mS.standings)) players
  in do
  renderRatingsCharts true (metric s) playerRatings "ratings-chart"
  renderRatingsCharts false (metric s) playerRatings "ratings-chart-2"
renderCharts s@(Tips p m mS) =
  let playerRating = Tuple p (ratings (metric s) (tipsForPlayer p) mS.standings)
  in do
  renderRatingsCharts true (metric s) [playerRating] "ratings-chart"
  renderRatingsCharts false (metric s) [playerRating] "ratings-chart-2"

eval :: Eval Input State Input (Aff AppEffects)
eval (Overview next) = do
  s <- S.get
  -- S.modify (const Loading)
  stateE <- liftFI (matchdayState s)
  case stateE of
    Left text       -> S.modify (\_ -> Error text)
    Right matchdayS -> do
      let newState = Players (metric s) matchdayS
      S.modify (\_ -> newState)
      liftFI (renderCharts newState)
  pure next
eval (SelectPlayer player next) = do
  s <- S.get
  -- S.modify (const Loading)
  stateE <- liftFI (matchdayState s)
  case stateE of
    Left text       -> S.modify (\_ -> Error text)
    Right matchdayS -> do
      let newState = Tips player (metric s) matchdayS
      S.modify (\_ -> newState)
      liftFI (renderCharts newState)
  pure next
eval (SelectDay day next) = do
  s <- S.get
  -- S.modify (const Loading)
  tableE <- liftFI (leagueTable (Just day))
  case tableE of
    Left text   -> S.modify (\_ -> Error text)
    Right table -> do
      let newState = updateMatchday (standings table) day s
      S.modify (\_ -> newState)
      liftFI (renderCharts newState)
  pure next
eval (Use metric next) = do
  s <- S.get
  let newState = updateMetric metric s
  S.modify (\_ -> newState)
  liftFI (renderCharts newState)
  pure next


renderPage :: forall p i. Array (H.HTML p i) -> H.HTML p i
renderPage contents =
  H.div [P.class_ (H.className "content")]
    ( H.h1 [P.class_ (H.className "jumbotron")] [H.text "Saison Spektakel 2015/16"]
    : contents
    )

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

pointsTable :: forall p. Array Ranking -> H.HTML p (Input Unit)
pointsTable rankings =
  H.table
    [P.class_ (H.className "table")]
    [H.thead_ [pointsHeader], H.tbody_ (zipWith pointsRow (range 1 (length rankings)) rankings)]
 where
  pointsHeader = H.tr_ [H.th_ [H.text "#"], H.th_ [H.text "Tipper"], H.th_ [H.text "Punkte"]]
  pointsRow i ranking =
    H.tr_
      [ H.td_ [H.text (show i)]
      , H.td_ [H.a [P.href (reverseRoute (TipsRoute ranking.player))] [H.text (pretty ranking.player)]]
      , H.td_ [H.text (showNumber 1 ranking.points)] ]

ratingsTable :: forall p i. Array Rating -> H.HTML p i
ratingsTable ratings =
  H.table
    [P.class_ (H.className "table")]
    [H.thead_ [ratingHeader], H.tbody_ (map ratingRow ratings)]
 where
  ratingHeader = H.tr_ [H.th_ [H.text "#"], H.th_ [H.text "Verein"], H.th_ [H.text "Abstand"]]
  ratingRow rating =
    H.tr
      [rowColor rating.dist rating.trend]
      [ H.td_ [H.text (show rating.pos)]
      , H.td_ [H.text (pretty rating.team)]
      , H.td_ [H.text (showNumber 1 rating.value)] ]

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
