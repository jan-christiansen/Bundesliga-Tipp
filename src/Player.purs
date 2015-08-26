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
  | Maike
  | Nikita
  | Spiegel

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
  show Maike = "Maike"
  show Nikita = "Nikita (alias Zufallstipp)"
  show Spiegel = "Spiegel.de-Prognose"

allPlayers :: Array Player
allPlayers =
  [ JanWulf
  , Jan
  , JR
  , Christoph
  , Johannes
  , Julia
  , Daniel
  , Mirko
  , Ulf
  , Sandra
  , Maike
  , Nikita
  , Spiegel
  ]
