{-# LANGUAGE QuasiQuotes, TemplateHaskell, OverloadedStrings, DeriveDataTypeable, DisambiguateRecordFields #-}
module Network.JsonRpc.Protocol (
    Request(..)
  , Response(..)
  , parse
) where

import qualified Data.ByteString.Lazy as LBS
import qualified Data.Attoparsec.Lazy as AL
import Control.Applicative
import Data.Text
import qualified Data.Aeson as AE
import Data.Aeson.Generic
import Data.Aeson.Types hiding(parse)
import Data.Aeson.QQ

data Request = Request {
    reqMethod :: String
  , reqParams :: [Value]
  , reqId     :: Integer
}

instance ToJSON Request where
    toJSON r = [aesonQQ| {method: <|reqMethod r|>, params: <|reqParams r|>, id: <|reqId r|>} |]

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
    toJSON r = [aesonQQ| {result: <|respResult r|>, error: <|respError r|>, id: <|respId r|>} |]

instance FromJSON Response where
    parseJSON (Object v) = Response <$>
                               v .: "result"
                           <*> v .: "error"
                           <*> v .: "id"

parse :: FromJSON a => LBS.ByteString -> Maybe a
parse input = do
    v <- AL.maybeResult $ AL.parse AE.json input
    case AE.fromJSON v of
        Success a -> Just a
        Error _   -> Nothing
