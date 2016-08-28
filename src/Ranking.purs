module Ranking where


import Prelude (compare, map)
import Data.Array (sortBy)
import Data.Function (on)

import Player (Player(), allPlayersForSeason)
import Season (Season)
import Tip (Metric(), ratePlayer)
import Team (Team())


type Ranking = { player :: Player, points :: Number }


rankingsForStandings :: Metric -> Array Team -> Season -> Array Ranking
rankingsForStandings metric standings season =
  sortBy
    (compare `on` _.points)
    (map (\p -> { player: p, points: ratePlayer metric standings season p }) (allPlayersForSeason season))
