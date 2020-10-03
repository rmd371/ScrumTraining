module Main where

import Prelude

import Effect (Effect)
import TryPureScript (render, withConsole, h1, text)
import Test.Unit.Main (runTest)
import Test.Unit.Assert as Assert
import Test.Unit (suite, test)
import Control.Monad.Reader.Class (class MonadAsk, ask)

newtype Reader e a = Reader (e -> a)

-- TODO: comment in the unit tests below after you've implemented the associated method

-- runReader :: forall e a. Reader e a -> e -> a

--derive newtype instance semigroupOp :: Semigroup a ⇒ Semigroup (Reader s a)
-- instance semigroupReader :: Semigroup a => Semigroup (Reader e a) where
--   -- append :: a -> a -> a
--   -- append :: Reader e a -> Reader e a -> Reader e a

-- derive newtype instance functorStat3 :: Functor (Reader s)
-- instance functorReader :: Functor (Reader s) where
--   -- map :: forall a b. (a -> b) -> f a -> f b

-- derive newtype instance applyReader :: Apply (Reader e)
-- instance applyReader :: Apply (Reader e) where
--   -- apply :: forall a b. f (a -> b) -> f a -> f b

--derive newtype instance applicativeReader :: Apply (Reader e) => Applicative (Reader e)
-- instance applicativeReader :: Applicative (Reader s) where
--   -- pure :: forall a. a -> f a

-- derive newtype instance bindReader :: Bind (Reader e)
-- instance bindReader :: Bind (Reader e) where
--   -- bind :: forall a b. m a -> (a -> m b) -> m b

-- instance monadReader :: Monad (Reader e)

-- -- derive newtype instance monadAskReader :: MonadAsk e (Reader e)
-- instance askReader :: MonadAsk e (Reader e) where
--   -- ask :: forall e a. (e -> a) -> Reader e a

type Env = { type :: String, buildType :: String, symbol :: String, rank :: Int }

env :: Env
env = { type: "pure", buildType: "script", symbol: "#", rank: 1 }

typeRdr :: Reader Env String
typeRdr = Reader (\e -> e.type)

buildTypeRdr :: Reader Env String
buildTypeRdr = Reader (\e -> e.buildType)

typePlusBuildType :: Reader Env String
typePlusBuildType = typeRdr <> buildTypeRdr

rankRdr :: Reader Env Int
rankRdr = Reader (\e -> e.rank)

rankToStr :: Int -> String
rankToStr = \x -> "#" <> show x

rankToPhraseRdr :: Reader Env (Int -> String)
rankToPhraseRdr = Reader $ \e -> \i -> e.buildType <> "ing for " <> rankToStr i

main :: Effect Unit
main = do 
  render $ h1 $ text "Build my own Reader tests"
  render =<< withConsole do 
    runTest do
      suite "Reader" do
        test "runReader" do
          Assert.assert "returns 'pure'" $ runReader typeRdr env == "pure"
        -- test "append" do
        --   Assert.assert "returns 'purescript'" $ runReader typePlusBuildType env == "purescript"
        -- test "map" do
        --   Assert.assert "return '#1'" $ runReader (map rankToStr rankRdr) env == "#1"
        -- test "apply" do
        --   Assert.assert "return 'scripting for #1'" $ runReader (apply rankToPhraseRdr rankRdr) env == "scripting for #1"
        -- test "pure/of" do
        --   Assert.assert "return 'is'" $ runReader (pure "is") env == "is"
        -- test "bind/chain" do
        --   Assert.assert "return '#1'" $ runReader (bind typePlusBuildType (\x -> pure $ x <> " is fun")) env == "purescript is fun"
        -- test "ask" do
        --   Assert.assert "return '#'" $ runReader ask (\e -> e.symbol) env == "#"
