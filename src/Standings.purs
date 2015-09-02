module Standings where


import Prelude
import Control.Monad.Aff (Aff(), launchAff)
import Data.Array
import Data.JSON
import Data.Either
import Data.Maybe
import Data.Tuple
import Data.Traversable (traverse)
import qualified Data.Map as M
import Network.HTTP.Affjax (AJAX(), defaultRequest, affjax)
import Network.HTTP.RequestHeader (RequestHeader(..))

import Team

data LeagueTable = LeagueTable Int (Array Team)

matchday :: LeagueTable -> Int
matchday (LeagueTable day _) = day

standings :: LeagueTable -> Array Team
standings (LeagueTable _ sts) = sts

leagueTable :: forall eff a. Maybe Int -> Aff (ajax :: AJAX | eff) (Either String LeagueTable)
leagueTable mDay = do
  let reqHeader = RequestHeader "X-Auth-Token" "9d7d681dea7c4cf49b095d7cc1d8d9c5"
      req       = defaultRequest { headers = [reqHeader]
                                 , url = "http://api.football-data.org/alpha/soccerseasons/394/leagueTable" ++ matchdayQuery mDay }
  result <- affjax req
  let response = result.response
  return (do
    decoded <- eitherDecode response
    matchday <- parseMatchday decoded
    standings <- parseStandings decoded
    return (LeagueTable matchday standings))
 where
  matchdayQuery Nothing = ""
  matchdayQuery (Just i) = "?matchday=" ++ show i

parseField :: String -> JValue -> Either String JValue
parseField fieldName jvalue@(JObject o) =
  maybe (Left ("No property " ++ show fieldName ++ " in " ++ show jvalue)) Right (M.lookup fieldName o)
parseField _ _                   =
  Left "Data is not a object"

parseMatchday :: JValue -> Either String Int
parseMatchday jValue = parseField "matchday" jValue >>= parseInt

parseInt :: JValue -> Either String Int
parseInt (JInt i) = Right i
parseInt _        = Left "Data is not an integer"

parseStandings :: JValue -> Either String (Array Team)
parseStandings jValue = parseField "standing" jValue >>= parseStanding

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


icon :: forall eff a. Int -> Aff (ajax :: AJAX | eff) (Either String (Tuple String String))
icon teamNo = do
  let reqHeader = RequestHeader "X-Auth-Token" "9d7d681dea7c4cf49b095d7cc1d8d9c5"
      req       = defaultRequest { headers = [reqHeader]
                                 , url = "http://api.football-data.org/alpha/teams/" ++ show teamNo }
  result <- affjax req
  let response = result.response
  return (do
    decoded <- eitherDecode response
    parseSvgUrl decoded)

parseSvgUrl :: JValue -> Either String (Tuple String String)
parseSvgUrl jValue = do
  value <- parseField "crestUrl" jValue
  code <- parseCode value
  url <- parseUrl value
  return (Tuple code url)

parseCode :: JValue -> Either String String
parseCode (JString code) = Right code
parseCode _              = Left "code should be a string"

parseUrl :: JValue -> Either String String
parseUrl (JString url) = Right url
parseUrl _             = Left "cresUrl should be a string"


-- {"_links":{"self":{"href":"http://api.football-data.org/alpha/teams/1"},"fixtures":{"href":"http://api.football-data.org/alpha/teams/1/fixtures"},"players":{"href":"http://api.football-data.org/alpha/teams/1/players"}}
-- ,"name":"1. FC Köln"
-- ,"code":"EFFZEH"
-- ,"shortName":"Köln"
-- ,"squadMarketValue":"42,150,000 €"
-- ,"crestUrl":"http://upload.wikimedia.org/wikipedia/de/1/16/1._FC_Köln.svg"}
