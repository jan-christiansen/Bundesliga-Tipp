module Ratings where


import Data.Array (zipWith, range, length)
import Data.Int (fromNumber)
import Data.Maybe (Maybe(..))

import Team
import Tip


type Rating = { pos :: Int, team :: Team, value :: Number, dist :: Int, trend :: Trend }

ratings :: Metric -> Array Team -> Array Team -> Array Rating
ratings metric tips standings =
  zipWith rating (range 1 (length tips)) tips
 where
  rating i team =
    let dist = case fromNumber (rateTip Manhattan standings team i) of
                    Just i -> i
        value = rateTip metric standings team i
        t = trend standings team i
    in
    { pos: i, team: team, value: value, dist: dist, trend: t }
