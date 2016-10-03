module Player where


import Prelude

import Season
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
  | Jens
  | Thorsten
  | Torsten
  | Arvid
  | Marcellus
  | Sebastian
  | Stefan
  | Svenja
  | Frank
  | Marktwert

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
  show Jens = "Jens"
  show Thorsten = "Thorsten"
  show Torsten = "Torsten"
  show Arvid = "Arvid"
  show Marcellus = "Marcellus"
  show Sebastian = "Sebastian"
  show Stefan = "Stefan"
  show Svenja = "Svenja"
  show Frank = "Frank"
  show Marktwert = "Marktwert"

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
  pretty Jens = "Jens"
  pretty Thorsten = "Thorsten"
  pretty Torsten = "Torsten"
  pretty Arvid = "Arvid"
  pretty Marcellus = "Marcellus"
  pretty Sebastian = "Sebastian"
  pretty Stefan = "Stefan (alias Ahnungslosertipp)"
  pretty Svenja = "Svenja"
  pretty Frank = "Frank"
  pretty Marktwert = "Marktwert zu Saisonbeginn"


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
  , Jens
  , Thorsten
  , Torsten
  , Arvid
  , Marcellus
  , Sebastian
  , Stefan
  , Svenja
  , Frank
  , Marktwert
  ]

allPlayersForSeason :: Season -> Array Player
allPlayersForSeason Season1516 =
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
allPlayersForSeason Season1617 =
  [ JanWulf
  , Jan
  , JR
  , Christoph
  , Johannes
  , Julia
  , Daniel
  , Mirko
  , Sandra
  , Nikita
  , Henning
  , Jens
  , Thorsten
  , Torsten
  , Arvid
  , Marcellus
  , Sebastian
  , Stefan
  , Svenja
  , Frank
  , Marktwert
  ]
           
