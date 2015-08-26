module Tip where


import Prelude
import Data.Array
import Data.Foldable
import Data.Maybe
import Data.Int
import Math (abs)

import Team
import Player


ratePlayer :: Array Team -> Player -> Int
ratePlayer standings p = rateTips standings (tipsForPlayer p)

rateTips :: Array Team -> Array Team -> Int
rateTips standings tips =
  sum (zipWith (rateTip standings) tips (range 1 (length tips)))

rateTip :: Array Team -> Team -> Int -> Int
rateTip standings team pos =
  case elemIndex team standings of
    Nothing -> 0 -- should yield an error
    Just i  -> metric pos (i+1)

data Trend = Better | Correct | Worse

trend :: Array Team -> Team -> Int -> Trend
trend standings team pos =
  case elemIndex team standings of
    Nothing -> Correct -- should yield an error
    Just i  -> if i+1==pos then Correct else if i+1<pos then Better else Worse


metric :: Int -> Int -> Int
metric tip actual =
  case fromNumber (abs (toNumber tip - toNumber actual)) of
    Nothing -> 0 -- should yield an error
    Just i  -> i


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
