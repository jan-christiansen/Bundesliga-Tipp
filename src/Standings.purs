module Standings where


import Prelude
import Control.Monad.Aff (Aff(), launchAff)
import Data.Array
import Data.JSON
import Data.Either
import Data.Maybe
import Data.Traversable (traverse)
import qualified Data.Map as M
import Network.HTTP.Affjax (AJAX(), get)


import Team


standings :: forall eff. Int -> Aff (ajax :: AJAX | eff) (Either String (Array Team))
standings _ = do
  -- result <- get "http://api.football-data.org/alpha/soccerseasons/394/leagueTable"
  -- let response = result.response
  -- return (eitherDecode response >>= parseData)
  return (eitherDecode test >>= parseData)

parseData :: JValue -> Either String (Array Team)
parseData (JObject o) =
  maybe (Left "No property standing") Right (M.lookup "standing" o) >>= parseStanding
parseData _           =
  Left "Data is not a object"

parseStanding :: JValue -> Either String (Array Team)
parseStanding (JArray a) = traverse parseTeam a
parseStanding _          = Left "Standing is not an array"

parseTeam :: JValue -> Either String Team
parseTeam (JObject o) =
  maybe (Left "No property teamName") Right (M.lookup "teamName" o) >>= parseJSTeamName
 where
  parseJSTeamName (JString string) = parseTeamName string
  parseJSTeamName _                = Left "TeamName is not a string"
parseTeam _           = Left "Team is not an object"

parseTeamName :: String -> Either String Team
parseTeamName "FC Bayern München" = Right Bayern
parseTeamName "Borussia Dortmund" = Right Dortmund
parseTeamName "FC Schalke 04" = Right Schalke
parseTeamName "1. FC Köln" = Right Koeln
parseTeamName "Bayer Leverkusen" = Right Leverkusen
parseTeamName "VfL Wolfsburg" = Right Wolfsburg
parseTeamName "Hertha BSC" = Right Berlin
parseTeamName "FC Ingolstadt 04" = Right Ingolstadt
parseTeamName "SV Darmstadt 98" = Right Darmstadt
parseTeamName "Hannover 96" = Right Hannover
parseTeamName "Eintracht Frankfurt" = Right Frankfurt
parseTeamName "TSG 1899 Hoffenheim" = Right Hoffenheim
parseTeamName "FC Augsburg" = Right Augsburg
parseTeamName "1. FSV Mainz 05" = Right Mainz
parseTeamName "VfB Stuttgart" = Right Stuttgart
parseTeamName "Werder Bremen" = Right Bremen
parseTeamName "Bor. Mönchengladbach" = Right Gladbach    
parseTeamName "Hamburger SV" = Right Hamburg
parseTeamName name = Left ("TeamName \"" ++ name ++ "\" cannot be parsed")

test = """{"_links":{"self":"http://api.football-data.org/alpha/soccerseasons/394/leagueTable/?matchday=1","soccerseason":"http://api.football-data.org/alpha/soccerseasons/394"},"leagueCaption":"1. Bundesliga 2015/16","matchday":1,"standing":[{"_links":{"team":{"href":"http://api.football-data.org/alpha/teams/5"}},"position":1,"teamName":"FC Bayern München","playedGames":1,"points":3,"goals":5,"goalsAgainst":0,"goalDifference":5},{"_links":{"team":{"href":"http://api.football-data.org/alpha/teams/4"}},"position":2,"teamName":"Borussia Dortmund","playedGames":1,"points":3,"goals":4,"goalsAgainst":0,"goalDifference":4},{"_links":{"team":{"href":"http://api.football-data.org/alpha/teams/6"}},"position":3,"teamName":"FC Schalke 04","playedGames":1,"points":3,"goals":3,"goalsAgainst":0,"goalDifference":3},{"_links":{"team":{"href":"http://api.football-data.org/alpha/teams/1"}},"position":4,"teamName":"1. FC Köln","playedGames":1,"points":3,"goals":3,"goalsAgainst":1,"goalDifference":2},{"_links":{"team":{"href":"http://api.football-data.org/alpha/teams/3"}},"position":5,"teamName":"Bayer Leverkusen","playedGames":1,"points":3,"goals":2,"goalsAgainst":1,"goalDifference":1},{"_links":{"team":{"href":"http://api.football-data.org/alpha/teams/11"}},"position":5,"teamName":"VfL Wolfsburg","playedGames":1,"points":3,"goals":2,"goalsAgainst":1,"goalDifference":1},{"_links":{"team":{"href":"http://api.football-data.org/alpha/teams/9"}},"position":7,"teamName":"Hertha BSC","playedGames":1,"points":3,"goals":1,"goalsAgainst":0,"goalDifference":1},{"_links":{"team":{"href":"http://api.football-data.org/alpha/teams/31"}},"position":7,"teamName":"FC Ingolstadt 04","playedGames":1,"points":3,"goals":1,"goalsAgainst":0,"goalDifference":1},{"_links":{"team":{"href":"http://api.football-data.org/alpha/teams/55"}},"position":9,"teamName":"SV Darmstadt 98","playedGames":1,"points":1,"goals":2,"goalsAgainst":2,"goalDifference":0},{"_links":{"team":{"href":"http://api.football-data.org/alpha/teams/8"}},"position":9,"teamName":"Hannover 96","playedGames":1,"points":1,"goals":2,"goalsAgainst":2,"goalDifference":0},{"_links":{"team":{"href":"http://api.football-data.org/alpha/teams/2"}},"position":11,"teamName":"TSG 1899 Hoffenheim","playedGames":1,"points":0,"goals":1,"goalsAgainst":2,"goalDifference":-1},{"_links":{"team":{"href":"http://api.football-data.org/alpha/teams/19"}},"position":11,"teamName":"Eintracht Frankfurt","playedGames":1,"points":0,"goals":1,"goalsAgainst":2,"goalDifference":-1},{"_links":{"team":{"href":"http://api.football-data.org/alpha/teams/16"}},"position":13,"teamName":"FC Augsburg","playedGames":1,"points":0,"goals":0,"goalsAgainst":1,"goalDifference":-1},{"_links":{"team":{"href":"http://api.football-data.org/alpha/teams/15"}},"position":13,"teamName":"1. FSV Mainz 05","playedGames":1,"points":0,"goals":0,"goalsAgainst":1,"goalDifference":-1},{"_links":{"team":{"href":"http://api.football-data.org/alpha/teams/10"}},"position":15,"teamName":"VfB Stuttgart","playedGames":1,"points":0,"goals":1,"goalsAgainst":3,"goalDifference":-2},{"_links":{"team":{"href":"http://api.football-data.org/alpha/teams/12"}},"position":16,"teamName":"Werder Bremen","playedGames":1,"points":0,"goals":0,"goalsAgainst":3,"goalDifference":-3},{"_links":{"team":{"href":"http://api.football-data.org/alpha/teams/18"}},"position":17,"teamName":"Bor. Mönchengladbach","playedGames":1,"points":0,"goals":0,"goalsAgainst":4,"goalDifference":-4},{"_links":{"team":{"href":"http://api.football-data.org/alpha/teams/7"}},"position":18,"teamName":"Hamburger SV","playedGames":1,"points":0,"goals":0,"goalsAgainst":5,"goalDifference":-5}]}"""
