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
  result <- get "http://api.football-data.org/alpha/soccerseasons/394/leagueTable"
  let response = result.response
  return (eitherDecode response >>= parseData)

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
