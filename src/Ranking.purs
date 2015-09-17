module Ranking where


import Prelude (compare, map)
import Data.Array (sortBy)
import Data.Function (on)

import Player (Player(), allPlayers)
import Tip (Metric(), ratePlayer)
import Team (Team())


type Ranking = { player :: Player, points :: Number }


rankingsForStandings :: Metric -> Array Team -> Array Ranking
rankingsForStandings metric standings =
  sortBy
    (compare `on` _.points)
    (map (\p -> { player: p, points: ratePlayer metric standings p }) allPlayers)
