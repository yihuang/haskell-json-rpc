{-# LANGUAGE OverloadedStrings #-}
module Network.JsonRpc.Protocol (
    Request(..)
  , Response(..)
  , parseRpc
) where

import qualified Data.ByteString.Lazy as LBS
import qualified Data.Attoparsec.Lazy as A
import Control.Applicative ((<$>), (<*>))
import qualified Data.Text as T
import Data.Aeson (Value(..), json, ToJSON(..), FromJSON(..), fromJSON,
                   object, (.:), (.=), Result(..))

data Request = Request {
    reqMethod :: String
  , reqParams :: [Value]
  , reqId     :: Integer
}

instance ToJSON Request where
    toJSON r = object [
                   "method" .= reqMethod r
                 , "params" .= reqParams r
                 , "id"     .= reqId r
               ]

instance FromJSON Request where
    parseJSON (Object v) = Request <$>
                           v .: "method" <*>
                           v .: "params" <*>
                           v .: "id"

data Response = Response {
    respResult :: Value
  , respError  :: Value
  , respId     :: Integer
}

instance ToJSON Response where
    toJSON r = object [
                   "result" .= respResult r
                 , "error"  .= respError r
                 , "id"     .= respId r
               ]

instance FromJSON Response where
    parseJSON (Object v) = Response <$>
                               v .: "result"
                           <*> v .: "error"
                           <*> v .: "id"

parseRpc :: FromJSON a => LBS.ByteString -> Maybe a
parseRpc input = do
    v <- A.maybeResult $ A.parse json input
    case fromJSON v of
        Success a -> Just a
        Error _   -> Nothing
