module Players where

import Prelude

import Control.Alt ((<|>))
import Control.Monad.Aff (Aff(), launchAff)
import Control.Monad.Eff (Eff())
import Control.Monad.Free (liftFI)

import Math (abs)
import Data.Int (toNumber, fromNumber)
import Data.Array
import Data.Maybe (Maybe(..))
import Data.Either

import Halogen
import Halogen.Query.StateF (modify)
import Halogen.Util (appendToBody)
import qualified Halogen.HTML as H
import qualified Halogen.HTML.Events as E
import qualified Halogen.HTML.Properties as P

import Network.HTTP.Affjax (AJAX(), get)

import Team
import Player
import Tip
import Standings


main :: Eff AppEffects Unit
main = launchAff $ do
  app <- runUI ui initialState
  appendToBody app.node


data Input a = Click a


type Entry = { player :: Player, points :: Int }

data State =
    Loading
  | Error String
  | State (Array Team)


initialState :: State
initialState = Loading

entriesForStandings :: Array Team -> Array Entry
entriesForStandings standings =
  map (\p -> { player: p, points: Tip.ratePlayer standings p }) Player.allPlayers


type AppEffects = HalogenEffects (ajax :: AJAX)

ui :: forall eff p. Component State Input (Aff AppEffects) p
ui = component render eval
 where
  render :: Render State Input p
  render Loading = H.button [E.onClick (E.input_ Click)] [H.text "Click Me"]
  render (Error text) = H.text ("An error occurred: " ++ text)
  render (State standings) =
    let entries = entriesForStandings standings
    in
    H.div [P.class_ (H.className "content")]
      [ H.h1 [P.class_ (H.className "jumbotron")]
        [H.text "Saison Spektakel 2015/16"]
      , H.div [P.class_ (H.className "bs-example")] [pointsTable entries] ]

  eval :: Eval Input State Input (Aff AppEffects)
  eval (Click next) = do
    teamsM <- liftFI (standings 1)
    case teamsM of
      Left text   -> modify (\_ -> Error text)
      Right teams -> modify (\_ -> State teams)
    pure next

header :: forall p i. H.HTML p i
header =
  H.h2_ [H.text "Tabellenstand"]

pointsTable :: forall p i. Array Entry -> H.HTML p i
pointsTable entries =
  H.table
    [P.class_ (H.className "table")]
    [H.thead_ [pointsHeader], H.tbody_ (zipWith pointsRow (range 1 (length entries)) entries)]
 where
  pointsHeader = H.tr_ [H.th_ [H.text "#"], H.th_ [H.text "Tipper"], H.th_ [H.text "Punkte"]]
  pointsRow i entry =
    H.tr_
      [ H.td_ [H.text (show i)]
      , H.td_ [H.text (show entry.player)]
      , H.td_ [H.text (show entry.points)] ]
