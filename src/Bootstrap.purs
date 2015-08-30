module Bootstrap where


import Prelude
import Data.Array (length, zipWith, range)
import Data.Tuple (Tuple(..))
import qualified Halogen.HTML as H
import qualified Halogen.HTML.Properties as P
import qualified Halogen.HTML.Events as E

import qualified Bootstrap.Classes as B


nav :: forall i p. H.ClassName -> Array (Tuple (H.HTML p i) Boolean) -> H.HTML p i
nav navClass contents =
  H.ul
    [P.classes [B.nav, navClass]]
    (map pill contents)
 where
  pill (Tuple content active) =
    let props = if active then [P.class_ B.active] else []
    in
    H.li props [ content ]

navPills :: forall i p. Array (Tuple (H.HTML p i) Boolean) -> H.HTML p i
navPills = nav B.navPills

navTabs :: forall i p. Array (Tuple (H.HTML p i) Boolean) -> H.HTML p i
navTabs = nav B.navTabs
