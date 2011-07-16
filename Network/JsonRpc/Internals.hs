-- | Full description of this trick: http://okmij.org/ftp/Haskell/vararg-fn.lhs
module Network.JsonRpc.Internals (
    RpcMethod(..)
  , RpcProxy(..)
) where

import Data.Aeson (Value(..), Result(..), ToJSON(toJSON), FromJSON, fromJSON)

class RpcMethod a where
    toMethod :: a -> [Value] -> IO Value

instance ToJSON a => RpcMethod (IO a) where
    toMethod x [] = fmap toJSON x
    toMethod _ _  = fail "too many arguments"

instance (FromJSON a, RpcMethod b) => RpcMethod (a -> b) where
    toMethod f (x:xs) =
        case fromJSON x of
            Success v -> toMethod (f v) xs
            _         -> fail "invalid request"
    toMethod _ _ = fail "too few arguments"

class RpcProxy a where
    toProxy :: ([Value] -> IO Value)
            -> a

instance FromJSON a => RpcProxy (IO a) where
    toProxy f = do
        v <- f []
        case fromJSON v of
            Success v1 -> return v1
            Error msg  -> fail msg

instance (ToJSON a, RpcProxy b) => RpcProxy (a -> b) where
    toProxy f x = toProxy $ \xs -> f (toJSON x : xs)

