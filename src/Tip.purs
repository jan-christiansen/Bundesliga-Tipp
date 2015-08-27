module Tip where


import Prelude
import Data.Array
import Data.Maybe
import Data.Int
import Data.Foldable (sum)
import Math (abs, pow, sqrt)

import Team
import Player


data Trend = Better | Correct | Worse

trend :: Array Team -> Team -> Int -> Trend
trend standings team pos =
  case elemIndex team standings of
    Nothing -> Correct -- should yield an error
    Just i  -> if i+1==pos then Correct else if i+1<pos then Better else Worse


data Metric =
    Euclid
  | Wulf

instance eqMetric :: Eq Metric where
  eq Euclid Euclid = true
  eq Wulf Wulf = true
  eq _ _ = false

allMetrics :: Array Metric
allMetrics = [Euclid, Wulf]

localization :: Metric -> String
localization Euclid = "Euklid"
localization Wulf = "Wulf"

ratePlayer :: Metric -> Array Team -> Player -> Int
ratePlayer metric standings p =
  rateTips metric standings (tipsForPlayer p)

rateTips :: Metric -> Array Team -> Array Team -> Int
rateTips metric standings tips =
  sum (zipWith (rateTip metric standings) tips (range 1 (length tips)))

rateTip :: Metric -> Array Team -> Team -> Int -> Int
rateTip metric standings team pos =
  case elemIndex team standings of
    Nothing -> 0 -- should yield an error
    Just i  -> calculate metric pos (i+1)

calculate :: Metric -> Int -> Int -> Int
calculate Euclid = euclid
calculate Wulf   = wulf

euclid :: Int -> Int -> Int
euclid tip actual =
  case fromNumber (abs (toNumber tip - toNumber actual)) of
       Nothing -> 0 -- should yield an error
       Just i  -> i

wulf :: Int -> Int -> Int
wulf tip actual = round (pow ((sqrt (toNumber tip) + sqrt (toNumber actual))) 2.0)


tipsForPlayer :: Player -> Array Team
tipsForPlayer JanWulf =
   [ Bayern, Leverkusen, Dortmund
   , Wolfsburg, Mainz, Schalke
   , Gladbach, Hannover, Hoffenheim
   , Stuttgart, Hamburg, Bremen
   , Augsburg, Frankfurt, Koeln
   , Berlin, Darmstadt, Ingolstadt ]
tipsForPlayer Christoph =
    [ Bayern, Gladbach, Wolfsburg
    , Leverkusen, Schalke, Dortmund
    , Hoffenheim, Augsburg, Bremen
    , Mainz, Frankfurt, Koeln
    , Hannover, Berlin, Ingolstadt
    , Hamburg, Darmstadt, Stuttgart ]
tipsForPlayer Johannes =
    [ Bayern, Dortmund, Wolfsburg
    , Leverkusen, Gladbach, Schalke
    , Mainz, Augsburg, Hoffenheim
    , Bremen, Frankfurt, Stuttgart
    , Koeln, Hamburg, Berlin
    , Hannover, Darmstadt, Ingolstadt ]
tipsForPlayer Jan =
    [ Bayern, Gladbach, Dortmund
    , Wolfsburg, Leverkusen, Stuttgart
    , Augsburg, Koeln, Schalke
    , Bremen, Mainz, Hamburg
    , Hoffenheim, Ingolstadt, Frankfurt
    , Berlin, Hannover, Darmstadt ]
tipsForPlayer JR =
    [ Bayern, Gladbach, Wolfsburg
    , Schalke, Leverkusen, Dortmund
    , Mainz, Stuttgart, Berlin
    , Hoffenheim, Augsburg, Koeln
    , Bremen, Hamburg, Ingolstadt
    , Hannover, Frankfurt, Darmstadt ]
tipsForPlayer Ulf =
    [ Bayern, Wolfsburg, Dortmund
    , Leverkusen, Gladbach, Schalke
    , Augsburg, Hoffenheim, Mainz
    , Bremen, Stuttgart, Frankfurt
    , Hannover, Koeln, Hamburg
    , Berlin , Ingolstadt, Darmstadt ]
tipsForPlayer Mirko =
    [ Wolfsburg, Bayern, Dortmund
    , Leverkusen, Gladbach, Schalke
    , Hamburg, Augsburg, Bremen
    , Berlin, Mainz, Stuttgart
    , Hoffenheim, Ingolstadt, Koeln
    , Hannover, Frankfurt, Darmstadt ]
tipsForPlayer Julia =
    [ Bayern, Dortmund, Wolfsburg
    , Leverkusen, Gladbach, Schalke
    , Frankfurt, Augsburg, Hannover
    , Mainz, Darmstadt, Stuttgart
    , Hamburg, Hoffenheim, Bremen
    , Berlin, Koeln, Ingolstadt ]
tipsForPlayer Daniel =
    [ Dortmund, Bayern, Wolfsburg
    , Gladbach, Frankfurt, Leverkusen
    , Augsburg, Schalke, Bremen
    , Hannover, Hoffenheim, Mainz
    , Koeln, Stuttgart, Hamburg
    , Berlin, Darmstadt, Ingolstadt ]
tipsForPlayer Sandra =
    [ Gladbach, Bayern, Wolfsburg
    , Dortmund, Leverkusen, Hoffenheim
    , Bremen, Augsburg, Schalke
    , Frankfurt, Mainz, Hamburg
    , Ingolstadt, Stuttgart, Koeln
    , Berlin, Hannover, Darmstadt ]
tipsForPlayer Maike =
    [ Bayern, Dortmund, Wolfsburg
    , Gladbach, Schalke, Augsburg
    , Leverkusen, Frankfurt, Bremen
    , Hoffenheim, Hannover, Koeln
    , Stuttgart, Mainz, Hamburg
    , Berlin, Darmstadt, Ingolstadt ]
tipsForPlayer Nikita =
     [ Frankfurt, Darmstadt, Stuttgart
     , Bayern, Ingolstadt, Mainz
     , Berlin, Dortmund, Schalke
     , Koeln, Augsburg, Gladbach
     , Hoffenheim, Hannover, Bremen
     , Hamburg, Wolfsburg, Leverkusen ]
tipsForPlayer Spiegel =
    [ Bayern, Leverkusen, Wolfsburg
    , Dortmund, Gladbach, Schalke
    , Stuttgart, Augsburg, Hoffenheim
    , Hamburg, Frankfurt, Koeln
    , Mainz, Bremen, Berlin
    , Hannover, Ingolstadt, Darmstadt ]
tipsForPlayer Henning =
    [ Bayern, Dortmund, Leverkusen
    , Gladbach, Schalke, Wolfsburg
    , Hamburg, Hoffenheim, Stuttgart
    , Augsburg, Frankfurt, Bremen
    , Mainz, Koeln, Berlin
    , Hannover, Ingolstadt, Darmstadt ]
