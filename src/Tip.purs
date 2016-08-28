module Tip where


import Prelude
import Data.Array
import Data.Maybe
import Data.Int
import Data.Foldable (sum)
import Math (abs, pow, sqrt)

import Team
import Season
import Player


data Trend = Better | Correct | Worse

trend :: Array Team -> Team -> Int -> Trend
trend standings team pos =
  case elemIndex team standings of
    Nothing -> Correct -- should yield an error
    Just i  -> if i+1==pos then Correct else if i+1<pos then Better else Worse


data Metric =
    Manhattan
  | Euclid
  | Wulf

instance eqMetric :: Eq Metric where
  eq Manhattan Manhattan = true
  eq Euclid Euclid = true
  eq Wulf Wulf = true
  eq _ _ = false

ratePlayer :: Metric -> Array Team -> Season -> Player -> Number
ratePlayer metric standings s p =
  rateTips metric standings (tipsForPlayer s p)

rateTips :: Metric -> Array Team -> Array Team -> Number
rateTips metric standings tips =
  normalize metric (sum (zipWith (rateTip metric standings) tips (range 1 (length tips))))

normalize :: Metric -> Number -> Number
normalize Manhattan s = s
normalize Euclid    s = sqrt s
normalize Wulf      s = pow s 2.0


rateTip :: Metric -> Array Team -> Team -> Int -> Number
rateTip metric standings team pos =
  case elemIndex team standings of
    Nothing -> 0.0 -- should yield an error
    Just i  -> calculate metric pos (i+1)

calculate :: Metric -> Int -> Int -> Number
calculate Manhattan = manhattan
calculate Euclid    = euclid
calculate Wulf      = wulf

manhattan :: Int -> Int -> Number
manhattan tip actual = abs (toNumber tip - toNumber actual)

euclid :: Int -> Int -> Number
euclid tip actual = pow (toNumber tip - toNumber actual) 2.0

wulf :: Int -> Int -> Number
wulf tip actual = sqrt (abs (toNumber tip - toNumber actual))


tipsForPlayer :: Season -> Player -> Array Team
tipsForPlayer Season1516 JanWulf =
   [ Bayern, Leverkusen, Dortmund
   , Wolfsburg, Mainz, Schalke
   , Gladbach, Hannover, Hoffenheim
   , Stuttgart, Hamburg, Bremen
   , Augsburg, Frankfurt, Koeln
   , Berlin, Darmstadt, Ingolstadt ]
tipsForPlayer Season1617 JanWulf =
   [ Bayern, Dortmund, Berlin
   , Gladbach, Leverkusen, Bremen
   , Mainz, Schalke, Frankfurt
   , Hamburg, Leipzig, Hoffenheim
   , Augsburg, Koeln, Wolfsburg
   , Darmstadt, Ingolstadt, Freiburg ]
tipsForPlayer Season1516 Christoph =
    [ Bayern, Gladbach, Wolfsburg
    , Leverkusen, Schalke, Dortmund
    , Hoffenheim, Augsburg, Bremen
    , Mainz, Frankfurt, Koeln
    , Hannover, Berlin, Ingolstadt
    , Hamburg, Darmstadt, Stuttgart ]
tipsForPlayer Season1516 Johannes =
    [ Bayern, Dortmund, Wolfsburg
    , Leverkusen, Gladbach, Schalke
    , Mainz, Augsburg, Hoffenheim
    , Bremen, Frankfurt, Stuttgart
    , Koeln, Hamburg, Berlin
    , Hannover, Darmstadt, Ingolstadt ]
tipsForPlayer Season1617 Johannes =
    [ Bayern, Dortmund, Leverkusen
    , Schalke, Gladbach, Wolfsburg
    , Leipzig, Mainz, Berlin
    , Augsburg, Hamburg, Hoffenheim
    , Koeln, Bremen, Frankfurt
    , Freiburg, Darmstadt, Ingolstadt ]
tipsForPlayer Season1516 Jan =
    [ Bayern, Gladbach, Dortmund
    , Wolfsburg, Leverkusen, Stuttgart
    , Augsburg, Koeln, Schalke
    , Bremen, Mainz, Hamburg
    , Hoffenheim, Ingolstadt, Frankfurt
    , Berlin, Hannover, Darmstadt ]
tipsForPlayer Season1617 Jan =
    [ Bayern, Dortmund, Leverkusen
    , Gladbach, Schalke, Mainz
    , Wolfsburg, Hoffenheim, Koeln
    , Hamburg, Leipzig, Bremen
    , Berlin, Freiburg, Ingolstadt
    , Frankfurt, Augsburg, Darmstadt ]
tipsForPlayer Season1516 JR =
    [ Bayern, Gladbach, Wolfsburg
    , Schalke, Leverkusen, Dortmund
    , Mainz, Stuttgart, Berlin
    , Hoffenheim, Augsburg, Koeln
    , Bremen, Hamburg, Ingolstadt
    , Hannover, Frankfurt, Darmstadt ]
tipsForPlayer Season1617 JR =
    [ Bayern, Dortmund, Gladbach
    , Leverkusen, Schalke, Mainz
    , Wolfsburg, Koeln, Hoffenheim
    , Hamburg, Leipzig, Augsburg
    , Berlin, Freiburg, Darmstadt
    , Bremen, Ingolstadt, Frankfurt ]
tipsForPlayer Season1516 Ulf =
    [ Bayern, Wolfsburg, Dortmund
    , Leverkusen, Gladbach, Schalke
    , Augsburg, Hoffenheim, Mainz
    , Bremen, Stuttgart, Frankfurt
    , Hannover, Koeln, Hamburg
    , Berlin , Ingolstadt, Darmstadt ]
tipsForPlayer Season1516 Mirko =
    [ Wolfsburg, Bayern, Dortmund
    , Leverkusen, Gladbach, Schalke
    , Hamburg, Augsburg, Bremen
    , Berlin, Mainz, Stuttgart
    , Hoffenheim, Ingolstadt, Koeln
    , Hannover, Frankfurt, Darmstadt ]
tipsForPlayer Season1516 Julia =
    [ Bayern, Dortmund, Wolfsburg
    , Leverkusen, Gladbach, Schalke
    , Frankfurt, Augsburg, Hannover
    , Mainz, Darmstadt, Stuttgart
    , Hamburg, Hoffenheim, Bremen
    , Berlin, Koeln, Ingolstadt ]
tipsForPlayer Season1617 Julia =
    [ Bayern, Leverkusen, Dortmund
    , Schalke, Gladbach, Koeln
    , Wolfsburg, Hamburg, Mainz
    , Augsburg, Leipzig, Hoffenheim
    , Berlin, Freiburg, Bremen
    , Frankfurt, Ingolstadt, Darmstadt ]
tipsForPlayer Season1516 Daniel =
    [ Dortmund, Bayern, Wolfsburg
    , Gladbach, Frankfurt, Leverkusen
    , Augsburg, Schalke, Bremen
    , Hannover, Hoffenheim, Mainz
    , Koeln, Stuttgart, Hamburg
    , Berlin, Darmstadt, Ingolstadt ]
tipsForPlayer Season1617 Daniel =
    [ Bayern, Dortmund, Mainz
    , Gladbach, Schalke, Wolfsburg
    , Leverkusen, Frankfurt, Koeln
    , Hamburg, Bremen, Leipzig
    , Darmstadt, Augsburg, Freiburg
    , Berlin, Ingolstadt, Hoffenheim ]
tipsForPlayer Season1516 Sandra =
    [ Gladbach, Bayern, Wolfsburg
    , Dortmund, Leverkusen, Hoffenheim
    , Bremen, Augsburg, Schalke
    , Frankfurt, Mainz, Hamburg
    , Ingolstadt, Stuttgart, Koeln
    , Berlin, Hannover, Darmstadt ]
tipsForPlayer Season1617 Sandra =
    [ Dortmund, Bayern, Gladbach
    , Leverkusen, Schalke, Leipzig
    , Mainz, Hamburg, Koeln
    , Berlin, Freiburg, Bremen
    , Ingolstadt, Wolfsburg, Augsburg
    , Frankfurt, Hoffenheim, Darmstadt ]
tipsForPlayer Season1516 Maike =
    [ Bayern, Dortmund, Wolfsburg
    , Gladbach, Schalke, Augsburg
    , Leverkusen, Frankfurt, Bremen
    , Hoffenheim, Hannover, Koeln
    , Stuttgart, Mainz, Hamburg
    , Berlin, Darmstadt, Ingolstadt ]
tipsForPlayer Season1516 Nikita =
     [ Frankfurt, Darmstadt, Stuttgart
     , Bayern, Ingolstadt, Mainz
     , Berlin, Dortmund, Schalke
     , Koeln, Augsburg, Gladbach
     , Hoffenheim, Hannover, Bremen
     , Hamburg, Wolfsburg, Leverkusen ]
tipsForPlayer Season1617 Nikita =
    [ Bayern, Berlin, Hoffenheim
    , Freiburg, Wolfsburg, Hamburg
    , Ingolstadt, Koeln, Leverkusen
    , Bremen, Leipzig, Augsburg
    , Mainz, Darmstadt, Frankfurt
    , Dortmund, Schalke, Gladbach ]
tipsForPlayer Season1516 Spiegel =
    [ Bayern, Leverkusen, Wolfsburg
    , Dortmund, Gladbach, Schalke
    , Stuttgart, Augsburg, Hoffenheim
    , Hamburg, Frankfurt, Koeln
    , Mainz, Bremen, Berlin
    , Hannover, Ingolstadt, Darmstadt ]
tipsForPlayer Season1516 Henning =
    [ Bayern, Dortmund, Leverkusen
    , Gladbach, Schalke, Wolfsburg
    , Hamburg, Hoffenheim, Stuttgart
    , Augsburg, Frankfurt, Bremen
    , Mainz, Koeln, Berlin
    , Hannover, Ingolstadt, Darmstadt ]
tipsForPlayer Season1617 Jens =
    [ Dortmund, Bayern, Leverkusen
    , Mainz, Schalke, Wolfsburg
    , Berlin, Freiburg, Gladbach
    , Frankfurt, Koeln, Hoffenheim
    , Bremen, Augsburg, Ingolstadt
    , Hamburg, Darmstadt, Leipzig ]
tipsForPlayer Season1617 Marcellus =
    [ Bayern, Dortmund, Leverkusen
    , Wolfsburg, Gladbach, Leipzig
    , Schalke, Bremen, Frankfurt
    , Hamburg, Mainz, Hoffenheim
    , Darmstadt, Berlin, Koeln
    , Freiburg, Ingolstadt, Augsburg ]
tipsForPlayer Season1617 Thorsten =
    [ Bayern, Dortmund, Leverkusen
    , Gladbach, Schalke, Mainz
    , Wolfsburg, Koeln, Berlin
    , Augsburg, Frankfurt, Freiburg
    , Bremen, Ingolstadt, Leipzig
    , Hamburg, Hoffenheim, Darmstadt ]
tipsForPlayer Season1617 Torsten =
    [ Dortmund, Bayern, Gladbach
    , Leverkusen, Koeln, Schalke
    , Leipzig, Wolfsburg, Augsburg
    , Mainz, Ingolstadt, Berlin
    , Freiburg, Bremen, Hoffenheim
    , Hamburg, Darmstadt, Frankfurt ]
tipsForPlayer Season1617 Arvid =
    [ Bayern, Dortmund, Leverkusen
    , Wolfsburg, Schalke, Gladbach
    , Hoffenheim, Mainz, Berlin
    , Hamburg, Koeln, Bremen
    , Leipzig, Frankfurt, Augsburg
    , Freiburg, Ingolstadt, Darmstadt ]
tipsForPlayer Season1617 Sebastian =
    [ Bayern, Dortmund, Leverkusen
    , Gladbach, Schalke, Mainz
    , Berlin, Wolfsburg, Koeln
    , Hamburg, Ingolstadt, Augsburg
    , Bremen, Darmstadt, Hoffenheim
    , Frankfurt, Freiburg, Leipzig ]
tipsForPlayer Season1617 Svenja =
    [ Bayern, Dortmund, Leverkusen
    , Gladbach, Schalke, Wolfsburg
    , Hamburg, Berlin, Mainz
    , Koeln, Bremen, Frankfurt
    , Hoffenheim, Leipzig, Augsburg
    , Freiburg, Ingolstadt, Darmstadt ]
tipsForPlayer Season1617 Stefan =
    [ Koeln, Mainz, Leverkusen
    , Dortmund, Gladbach, Frankfurt
    , Augsburg, Bayern, Ingolstadt
    , Schalke, Hamburg, Berlin
    , Leipzig, Freiburg, Darmstadt
    , Hoffenheim, Wolfsburg, Bremen ]
tipsForPlayer _ _ = []
