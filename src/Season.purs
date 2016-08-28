module Season where

import Prelude (class Show, class Eq)
import Util (class Pretty)

data Season = Season1516 | Season1617

instance showSeason :: Show Season where
  show Season1516 = "Saison 2015/16"
  show Season1617 = "Saison 2016/17"

instance prettySeason :: Pretty Season where
  pretty Season1516 = "Saison Spektakel 2015/16"
  pretty Season1617 = "Saison Spektakel 2016/17"

instance eqSeason :: Eq Season where
  eq Season1516 Season1516 = true
  eq Season1617 Season1617 = true
  eq _          _          = false

defaultSeason :: Season
defaultSeason = Season1617

allSeasons :: Array Season
allSeasons = [Season1516, Season1617]
