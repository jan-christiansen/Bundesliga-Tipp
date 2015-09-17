module Player where


import Prelude

import Util


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
  | Henning
  | Spiegel

instance showPlayer :: Show Player where
  show JanWulf = "JanWulf"
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
  show Nikita = "Nikita"
  show Henning = "Henning"
  show Spiegel = "Spiegel"

instance prettyPlayer :: Pretty Player where
  pretty JanWulf = "Jan W."
  pretty Jan = "Jan"
  pretty JR = "JR"
  pretty Christoph = "Christoph"
  pretty Johannes = "Johannes"
  pretty Julia = "Julia"
  pretty Daniel = "Daniel"
  pretty Mirko = "Mirko"
  pretty Ulf = "Ulf"
  pretty Sandra = "Sandra"
  pretty Maike = "Maike"
  pretty Nikita = "Nikita (alias Zufallstipp)"
  pretty Henning = "Prof. Henning"
  pretty Spiegel = "Spiegel.de-Prognose"


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
  , Henning
  , Spiegel
  ]
