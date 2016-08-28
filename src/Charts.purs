module Charts where


import Prelude
import Control.Apply ((*>))
import Control.Monad.Eff (Eff())
import Data.Array (zipWith, range, length, filter, head, uncons, sortBy)
import Data.Int (toNumber)
import Data.Either (Either(..), either)
import Data.Function (on)
import Data.Maybe (Maybe(..), maybe)
import Data.String (take)
import Data.StrMap (fromList,fromFoldable,singleton)
import Data.Tuple (Tuple(..), fst, snd)

import Halogen.HTML as H
import Halogen.HTML.Properties as P
import Control.Monad.Eff.JQuery (select)
import DOM (DOM())
import DOM.HTML (window)
import DOM.HTML.Types (htmlDocumentToDocument, readHTMLElement)
import DOM.HTML.Window (document)
import DOM.Node.Document (getElementsByClassName)
import DOM.Node.HTMLCollection (item)
import Data.Nullable (toMaybe)
import Data.Foreign (toForeign)
import Data.Foldable (foldMap)

import Preface ((++))
import ECharts

import Util
import Team (short)
import Tip (Metric(), calculate)
import Ranking (Ranking())
import Ratings (Rating())
import Player (Player())

return = pure

type RenderChartEff e a = Eff (dom :: DOM, echarts :: ECHARTS | e) a

renderRatingsChart :: forall eff. Boolean -> Metric -> Array (Tuple Player (Array Rating)) -> String
                   -> RenderChartEff eff (Maybe EChart)
renderRatingsChart aggregated metric playerRatings class_ = do
  w <- window
  d <- document w
  elems <- getElementsByClassName class_ (htmlDocumentToDocument d)
  e <- item 0 elems
  case readHTMLElement (toForeign e) of
    Left _  -> return Nothing
    Right x -> do
      chart <- init Nothing x
      setOption (ratingsOptions aggregated metric playerRatings) true chart
      return (Just chart)

ratingsOptions :: Boolean -> Metric -> Array (Tuple Player (Array Rating)) -> Option
ratingsOptions aggregated metric playerRatings =
  Option $ optionDefault
    { title = Just $ Title titleDefault
      { text = Nothing --Just $ (if aggregated then "Aggregierte " else "") ++ "Punkteverteilung"
      }
    , legend = Just $ Legend $ legendDefault
      { show = Just true
      , selected = if length playerRatings >= 4
                      then Just (fromFoldable (map (\(Tuple p arr) -> Tuple (pretty p) false) playerRatings))
                      else Nothing
      , "data" = Just $ map (fst >>> pretty >>> legendItemDefault) playerRatings
      }
    , xAxis = Just $ OneAxis $ Axis $ axisDefault
      { "type" = Just CategoryAxis
      , "data" = Just $ map CommonAxisData $ if aggregated
                                                then map show (points ratings)
                                                else categories
      , splitLine = Just $ AxisSplitLine $ axisSplitLineDefault
        { show = Just false }
      }
    , yAxis = Just $ OneAxis $ Axis $ axisDefault
      { "type" = Just ValueAxis
      , min = Just 0.0
      , max = if aggregated then Just 6.0 else Just (calculate metric 1 18)
      , splitNumber = if aggregated then Just 6.0 else Nothing
      }
    , series = Just $ map (series >>> Just) playerRatings
    }
 where
  ratings = maybe [] snd (head playerRatings)
  points ratings = map (calculate metric 0 >>> roundTo 2) (range 0 (length ratings - 1))
  datum ratings i = toNumber (length (filter (\r -> r.value == i) ratings))
  categories =
    if length playerRatings >= 1
       then map (\_ -> "") ratings 
       else map (_.team >>> short) (sortBy (compare `on` _.value) ratings)
  series (Tuple p ratings) =
    BarSeries
      { common: universalSeriesDefault
        { name = Just (pretty p)
        }
      , barSeries: barSeriesDefault
        { barGap = Just (Pixel 0.0)
        , barCategoryGap = Just (Pixel 0.0)
        , "data" = Just $ if aggregated
                             then map (datum ratings >>> Simple >>> Value) (points ratings)
                             else map (_.value >>> Simple >>> Value) (sortBy (compare `on` _.value) ratings)
        }
      }
