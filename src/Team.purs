module Team where


import Prelude

       
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
  eq _ _ = false

instance showTeam :: Show Team where
  show Bayern = "FC Bayern München"
  show Leverkusen = "Bayer 04 Leverkusen"
  show Dortmund = "BVB Borussia Dortmund"
  show Wolfsburg = "VfL Wolfsburg"
  show Mainz = "FSV Mainz 05"
  show Schalke = "FC Schalke 04"
  show Gladbach = "Borussia Mönchengladbach"
  show Hannover = "Hannover 96"
  show Hoffenheim = "TSV 1899 Hoffenheim"
  show Stuttgart = "VfB Stuttgart"
  show Hamburg = "Hamburger SV"
  show Bremen = "SV Werder Bremen"
  show Augsburg = "FC Augburg"
  show Frankfurt = "Eintracht Frankfurt"
  show Koeln = "1.FC Köln"
  show Berlin = "Hertha BSC Berlin"
  show Darmstadt = "SV Darmstadt 98"
  show Ingolstadt = "FC Ingolstadt 04"