{-# LANGUAGE FlexibleInstances, TypeSynonymInstances #-}

module Network.JsonRpc.Internals (
    RpcMethod(..)
  , RpcProxy(..)
) where

import Data.Data            (Data)
import Data.Aeson           (Value(..), Result(..))
import Data.Aeson.Generic   (toJSON, fromJSON)

class RpcMethod a where
    toMethod :: a -> [Value] -> IO Value

instance Data a => RpcMethod (IO a) where
    toMethod x [] = fmap toJSON x
    toMethod _ _  = fail "too many arguments"

instance (Data a, RpcMethod b) => RpcMethod (a -> b) where
    toMethod f (x:xs) =
        case fromJSON x of
            Success v -> toMethod (f v) xs
            _         -> fail "invalid request"
    toMethod _ _ = fail "too few arguments"

class RpcProxy a where
    toProxy :: ([Value] -> IO Value)
            -> a

instance Data a => RpcProxy (IO a) where
    toProxy f = do
        v <- f []
        case fromJSON v of
            Success v1 -> return v1
            Error msg  -> fail msg

instance (Data a, RpcProxy b) => RpcProxy (a -> b) where
    toProxy f x = toProxy $ \xs -> f (toJSON x : xs)

