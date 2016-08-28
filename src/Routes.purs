module Routes where

import Prelude
import Control.Alt ((<|>))
import Control.Plus (empty)
import Data.Foldable (foldr)

import Routing
import Routing.Match
import Routing.Match.Class

import Preface ((++))

import Player


-- Routing

data Route = PlayersRoute | TipsRoute Player

reverseRoute :: Route -> String
reverseRoute PlayersRoute  = "#"
reverseRoute (TipsRoute p) = "#" ++ playerLit p

routing :: Match Route
routing =
  const PlayersRoute <$> lit ""
    <|>
  TipsRoute <$> routingPlayer

routingPlayer :: Match Player
routingPlayer =
  foldr (<|>) empty (map (\p -> const p <$> lit (playerLit p)) allPlayers)

playerLit :: Player -> String
playerLit JanWulf = "janw"
playerLit Jan = "jan"
playerLit JR = "jr"
playerLit Christoph = "christoph"
playerLit Johannes = "johannes"
playerLit Julia = "julia"
playerLit Daniel = "daniel"
playerLit Mirko = "mirko"
playerLit Ulf = "ulf"
playerLit Sandra = "sandra"
playerLit Maike = "maike"
playerLit Nikita = "nikita"
playerLit Henning = "henning"
playerLit Spiegel = "spiegel"
