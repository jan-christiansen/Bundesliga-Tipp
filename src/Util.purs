module Util where


import Prelude
import Math (abs, round, pow)
import Data.Array
import Data.Int (toNumber)


class Pretty a where
  pretty :: a -> String

showNumber :: Int -> Number -> String
showNumber d p = show (roundTo d p)
 
roundTo :: Int -> Number -> Number
roundTo d x = round (x * m) / m
 where
  m = pow 10.0 (toNumber d)

chunks :: forall a. Int -> Array a -> Array (Array a)
chunks _ [] = []
chunks i xs = take i xs : chunks i (drop i xs)
