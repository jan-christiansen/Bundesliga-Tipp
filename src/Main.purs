module Main where

-- ulimit -n 2560
-- pulp browserify > dist/app.js

import Prelude

import Control.Apply ((*>))
import Control.Bind ((=<<))
import Control.Monad.Aff (Aff())
import Control.Monad.Eff (Eff())
import Control.Monad.Eff.Class (liftEff)

import Data.Array (length, range, zipWith, (:))
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Either (Either(..))
import Data.Tuple (Tuple(..))

import ECharts.Chart as EChart
import ECharts.Effects (ECHARTS)
import Halogen ( ComponentDSL, ComponentHTML, Component, HalogenEffects
               , modify, get, fromAff, fromEff, component, runUI, action )
import Halogen.Util (awaitBody, runHalogenAff)
import Halogen.HTML as H
import Halogen.HTML.Events as E
import Halogen.HTML.Properties as P
import DOM (DOM())
import DOM.Event.EventTarget (eventListener, addEventListener)
import DOM.HTML.Event.EventTypes (load, resize)
import DOM.HTML (window)
import DOM.HTML.Types (windowToEventTarget)
import Network.HTTP.Affjax (AJAX())
import Routing (matches)
import Preface ((++), concat)

import Util (chunks, showNumber, pretty)
import Routes (Route(..), reverseRoute, routing)
import Season (Season, defaultSeason)
import Team (Team)
import Player (Player)
import Tip (Metric(..), Trend(..), tipsForPlayer)
import Standings (LeagueTable(..), standings, leagueTable)
import Ranking (Ranking(), rankingsForStandings)
import Ratings (Rating(), ratings)
import Charts (renderRatingsChart)
import Bootstrap as B


-- Main Application

type AppEffects = HalogenEffects (ajax :: AJAX, echarts :: ECHARTS)

main :: Eff AppEffects Unit
main = runHalogenAff do
  body <- awaitBody
  driver <- runUI ui initialState body
  liftEff (matches routing $ \_ new -> route driver new)
 where
  route driver (PlayersRoute s) = runHalogenAff (driver (action (Overview s)))
  route driver (TipsRoute s p) = runHalogenAff (driver (action (SelectPlayer s p)))

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
    SelectPlayer Season Player a
  | SelectDay Matchday a
  | Overview Season a
  | Use Metric a

type MatchdayState =
  { standings :: Array Team
  , currentMatchday :: Matchday
  , maxMatchday :: Matchday
  , season :: Season
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
  Tips p m { standings: standings, currentMatchday: day, maxMatchday: s.maxMatchday, season: s.season }
updateMatchday standings day (Players m s) =
  Players m { standings: standings, currentMatchday: day, maxMatchday: s.maxMatchday, season: s.season }

updateMetric :: Metric -> State -> State
updateMetric _ l@Loading     = l
updateMetric _ e@(Error _)   = e
updateMetric m (Tips p _ s)  = Tips p m s
updateMetric m (Players _ s) = Players m s

initialState :: State
initialState = Loading

initialMetric :: Metric
initialMetric = Manhattan

metric :: State -> Metric
metric (Tips _ m _ )  = m
metric (Players m _ ) = m
metric _              = initialMetric

matchdayState :: State -> Either String MatchdayState
matchdayState (Tips _ _ state)  = Right state
matchdayState (Players _ state) = Right state
matchdayState (Error s) = Left s
matchdayState Loading = Left "error: Loading is not possible here"


ui :: Component State Input (Aff AppEffects)
ui = component {render, eval}

render :: State -> ComponentHTML Input
render Loading =
  renderPage [H.h1_ [H.text "Loading Data..."]] Nothing
render (Error text) =
  renderPage [H.text ("An error occurred: " ++ text)] Nothing
render (Players mtrc s) =
  let rankings = rankingsForStandings mtrc s.standings s.season
  in
  renderPage
    [ renderCurrentTable s.standings
    , renderMetrics mtrc
    , H.div [ P.class_ (H.className "main-content") ]
            [ H.div [P.class_ (H.className "bs-example")]
                    [ pointsTable s.season rankings ]
            ]
    , chartDiv
    , chartDiv2
    ]
    (Just s.season)
 where
  chartDiv = H.div_ [H.h2_ [H.text "Aggregierte Punkteverteilung"], H.div [P.class_ (H.className "ratings-chart")] []]
  chartDiv2 = H.div_ [H.h2_ [H.text "Punkteverteilung"], H.div [P.class_ (H.className "ratings-chart-2")] []]

render (Tips player mtrc s) =
  renderPage
    [ renderCurrentTable s.standings
    , renderMetrics mtrc
    , H.div [P.class_ (H.className "main-content")]
            [ H.div [ P.class_ (H.className "players-nav") ]
                    [ H.h2_ [H.text (pretty player)]
                    , H.a [P.href (reverseRoute (PlayersRoute s.season))] [H.text "Zur Übersicht"]
                    ]
            , H.div [P.class_ (H.className "bs-example")]
                    [ratingsTable (ratings mtrc (tipsForPlayer s.season player) s.standings)]
            ]
    , chartDiv
    , chartDiv2
    , renderMatchdays s
    ]
    (Just s.season)
 where
  chartDiv = H.div_ [H.h2_ [H.text "Aggregierte Punkteverteilung"], H.div [P.class_ (H.className "ratings-chart")] []]
  chartDiv2 = H.div_ [H.h2_ [H.text "Punkteverteilung"], H.div [P.class_ (H.className "ratings-chart-2")] []]


renderRatingsCharts :: forall eff. Boolean -> Metric -> Array (Tuple Player (Array Rating))
                    -> String -> Eff (dom :: DOM, echarts :: ECHARTS | eff) Unit
renderRatingsCharts aggregated mtrc playerRatings className = do
  chartM <- renderRatingsChart aggregated mtrc playerRatings className
  case chartM of
       Nothing -> pure unit
       Just c  -> onResize (EChart.resize c)


renderCharts :: forall eff. State -> Eff (dom :: DOM, echarts :: ECHARTS | eff) Unit
renderCharts Loading = pure unit
renderCharts (Error _) = pure unit
renderCharts s@(Players m mS) =
  let players = map _.player (rankingsForStandings (metric s) mS.standings mS.season)
      playerRatings = map (\p -> Tuple p (ratings (metric s) (tipsForPlayer mS.season p) mS.standings)) players
  in do
  renderRatingsCharts true (metric s) playerRatings "ratings-chart"
  renderRatingsCharts false (metric s) playerRatings "ratings-chart-2"
renderCharts s@(Tips p m mS) =
  let playerRating = Tuple p (ratings (metric s) (tipsForPlayer mS.season p) mS.standings)
  in do
  renderRatingsCharts true (metric s) [playerRating] "ratings-chart"
  renderRatingsCharts false (metric s) [playerRating] "ratings-chart-2"

eval :: Input ~> ComponentDSL State Input (Aff AppEffects)
eval (Overview season next) = do
  s <- get
  case matchdayState s of
    Left text -> do
      tableE <- fromAff (leagueTable season Nothing)
      case tableE of
        Left text' -> modify (\_ -> Error text')
        Right (LeagueTable maxDay sts) -> do
         let newState =
              Players (metric s)
                      { standings: sts, currentMatchday: maxDay
                      , maxMatchday: maxDay, season: season}
         modify (\_ -> newState)
         fromEff (renderCharts newState)
    Right matchdayS -> do
      if matchdayS.season == season
       then do
         let newState = Players (metric s) matchdayS
         modify (\_ -> newState)
         fromEff (renderCharts newState)
       else do
         tableE <- fromAff (leagueTable season Nothing)
         case tableE of
           Left text   -> modify (\_ -> Error text)
           Right (LeagueTable maxDay sts) -> do
             let newState =
                  Players (metric s)
                          { standings: sts, currentMatchday: maxDay
                          , maxMatchday: maxDay, season: season}
             modify (\_ -> newState)
             fromEff (renderCharts newState)
  pure next
eval (SelectPlayer season player next) = do
  s <- get
  case matchdayState s of
    Left text       -> modify (\_ -> Error text)
    Right matchdayS -> do
      if matchdayS.season == season
       then do
         let newState = Tips player (metric s) matchdayS
         modify (\_ -> newState)
         fromEff (renderCharts newState)
       else do
         tableE <- fromAff (leagueTable season Nothing)
         case tableE of
           Left text   -> modify (\_ -> Error text)
           Right table -> do
             let newState = updateMatchday (standings table) matchdayS.currentMatchday s
             modify (\_ -> newState)
             fromEff (renderCharts newState)
  pure next
eval (SelectDay day next) = do
  s <- get
  case matchdayState s of
    Left text       -> modify (\_ -> Error text)
    Right matchdayS -> do
      tableE <- fromAff (leagueTable matchdayS.season (Just day))
      case tableE of
        Left text   -> modify (\_ -> Error text)
        Right table -> do
         let newState = updateMatchday (standings table) day s
         modify (\_ -> newState)
         fromEff (renderCharts newState)
  pure next
eval (Use mtrc next) = do
  s <- get
  let newState = updateMetric mtrc s
  modify (\_ -> newState)
  fromEff (renderCharts newState)
  pure next


renderPage :: forall p i. Array (H.HTML p i) -> Maybe Season -> H.HTML p i
renderPage contents mSeason =
  H.div [P.class_ (H.className "content")]
    ( H.h1 [P.class_ (H.className "jumbotron")] [H.text (pretty (fromMaybe defaultSeason mSeason))]
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
renderMetrics mtrc =
  B.navTabs
    [ row "Manhattan" Manhattan
    , row "Euklid" Euclid
    , row "Wulf" Wulf
    ]
 where
  row name mtrc' =
    Tuple (H.a [ E.onClick (E.input_ (Use mtrc')) ] [ H.text name ]) (mtrc==mtrc')

pointsTable :: forall p. Season -> Array Ranking -> H.HTML p (Input Unit)
pointsTable season rankings =
  H.table
    [P.class_ (H.className "table")]
    [H.thead_ [pointsHeader], H.tbody_ (zipWith pointsRow (range 1 (length rankings)) rankings)]
 where
  pointsHeader = H.tr_ [H.th_ [H.text "#"], H.th_ [H.text "Tipper"], H.th_ [H.text "Punkte"]]
  pointsRow i ranking =
    H.tr_
      [ H.td_ [H.text (show i)]
      , H.td_ [H.a [P.href (reverseRoute (TipsRoute season ranking.player))] [H.text (pretty ranking.player)]]
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
        (concat (map row (chunks 3 icons))
        [ H.div [P.class_ (H.className "clear")] [] ])
 where
  row tIcons = H.div [P.class_ (H.className "current-table-row")] tIcons
  icons = map icon standings
  icon team =
    H.div [P.class_ (H.className "team")]
          [H.img [ P.src ("images/" ++ show team ++ ".svg")
                 , P.class_ (H.className "icon")
                 ]
          ]
