module Routes where

import Control.Alt ((<|>))
import Control.Plus (empty)
import Data.Foldable (foldr)

-- import Routing
import Routing.Match (Match)
import Routing.Match.Class (lit)

import Preface ((++))
import Prelude (const, map, (<$>), (<*>), (<*), (*>), class Show)
import Player (Player(..), allPlayers)
import Season


-- Routing

data Route = PlayersRoute Season | TipsRoute Season Player

instance showRoute :: Show Route where
  show = reverseRoute

reverseRoute :: Route -> String
reverseRoute (PlayersRoute s)  = "#" ++ seasonLit s
reverseRoute (TipsRoute s p) = "#" ++ seasonLit s ++ "/" ++ playerLit p

seasonLit :: Season -> String
seasonLit Season1516 = "2015"
seasonLit Season1617 = ""

routing :: Match Route
routing =
  TipsRoute <$> routingSeason <*> routingPlayer
    <|>
  PlayersRoute <$> routingSeason

routingSeason :: Match Season
routingSeason =
    foldr (<|>) empty (map (\s -> const s <$> lit (seasonLit s)) allSeasons)

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
playerLit Jens = "jens"
playerLit Thorsten = "thorsten"
playerLit Torsten = "torsten"
playerLit Arvid = "arvid"
playerLit Marcellus = "marcellus"
playerLit Sebastian = "sebastian"
playerLit Stefan = "stefan"
playerLit Svenja = "svenja"
playerLit Frank = "frank"
playerLit Marktwert = "marktwert"
