module Player where


import Prelude


data Player =
    JanWulf
  | Jan
  | JR
  | Christoph
  | Johannes
  | Julia
  | Daniel
  | Mirko
  | Ulf
  | Sandra

instance showPlayer :: Show Player where
  show JanWulf = "Jan W."
  show Jan = "Jan"
  show JR = "JR"
  show Christoph = "Christoph"
  show Johannes = "Johannes"
  show Julia = "Julia"
  show Daniel = "Daniel"
  show Mirko = "Mirko"
  show Ulf = "Ulf"
  show Sandra = "Sandra"

allPlayers :: Array Player
allPlayers =
  [JanWulf, Jan, JR, Christoph, Johannes, Julia, Daniel, Mirko, Ulf, Sandra]

type Entry = { player :: Player, points :: Int }

entries :: Array Entry
entries = map (\p -> { player: p, points: 0 }) allPlayers
