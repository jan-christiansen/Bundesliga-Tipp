module Team where


import Prelude
import Util


data Team =
    Bayern
  | Leverkusen
  | Dortmund
  | Wolfsburg
  | Mainz
  | Schalke
  | Gladbach
  | Hannover
  | Hoffenheim
  | Stuttgart
  | Hamburg
  | Bremen
  | Augsburg
  | Frankfurt
  | Koeln
  | Berlin
  | Darmstadt
  | Ingolstadt
  | Freiburg
  | Leipzig

instance eqTeam :: Eq Team where
  eq Bayern Bayern = true
  eq Leverkusen Leverkusen = true
  eq Dortmund Dortmund = true
  eq Wolfsburg Wolfsburg = true
  eq Mainz Mainz = true
  eq Schalke Schalke = true
  eq Gladbach Gladbach = true
  eq Hannover Hannover = true
  eq Hoffenheim Hoffenheim = true
  eq Stuttgart Stuttgart = true
  eq Hamburg Hamburg = true
  eq Bremen Bremen = true
  eq Augsburg Augsburg = true
  eq Frankfurt Frankfurt = true
  eq Koeln Koeln = true
  eq Berlin Berlin = true
  eq Darmstadt Darmstadt = true
  eq Ingolstadt Ingolstadt = true
  eq Freiburg Freiburg = true
  eq Leipzig Leipzig = true
  eq _ _ = false

instance showTeam :: Show Team where
  show Bayern = "Bayern"
  show Leverkusen = "Leverkusen"
  show Dortmund = "Dortmund"
  show Wolfsburg = "Wolfsburg"
  show Mainz = "Mainz"
  show Schalke = "Schalke"
  show Gladbach = "Gladbach"
  show Hannover = "Hannover"
  show Hoffenheim = "Hoffenheim"
  show Stuttgart = "Stuttgart"
  show Hamburg = "Hamburg"
  show Bremen = "Bremen"
  show Augsburg = "Augsburg"
  show Frankfurt = "Frankfurt"
  show Koeln = "Koeln"
  show Berlin = "Berlin"
  show Darmstadt = "Darmstadt"
  show Ingolstadt = "Ingolstadt"
  show Leipzig = "Leipzig"
  show Freiburg = "Freiburg"

instance prettyTeam :: Pretty Team where
  pretty Bayern = "FC Bayern München"
  pretty Leverkusen = "Bayer 04 Leverkusen"
  pretty Dortmund = "BVB Borussia Dortmund"
  pretty Wolfsburg = "VfL Wolfsburg"
  pretty Mainz = "FSV Mainz 05"
  pretty Schalke = "FC Schalke 04"
  pretty Gladbach = "Borussia Mönchengladbach"
  pretty Hannover = "Hannover 96"
  pretty Hoffenheim = "TSG 1899 Hoffenheim"
  pretty Stuttgart = "VfB Stuttgart"
  pretty Hamburg = "Hamburger SV"
  pretty Bremen = "SV Werder Bremen"
  pretty Augsburg = "FC Augsburg"
  pretty Frankfurt = "SG Eintracht Frankfurt"
  pretty Koeln = "1.FC Köln"
  pretty Berlin = "Hertha BSC Berlin"
  pretty Darmstadt = "SV Darmstadt 98"
  pretty Ingolstadt = "FC Ingolstadt 04"
  pretty Freiburg = "SC Freiburg"
  pretty Leipzig = "RB Leipzig"

short :: Team -> String
short Bayern = "FCB"
short Leverkusen = "B04"
short Dortmund = "BVB"
short Wolfsburg = "WOB"
short Mainz = "M05"
short Schalke = "S04"
short Gladbach = "BMG"
short Hannover = "H96"
short Hoffenheim = "TSG"
short Stuttgart = "VFB"
short Hamburg = "HSV"
short Bremen = "SVW"
short Augsburg = "FCA"
short Frankfurt = "SGE"
short Koeln = "1.FC"
short Berlin = "BSC"
short Darmstadt = "D98"
short Ingolstadt = "I04"
short Leipzig = "RBL"
short Freiburg = "SCF"
