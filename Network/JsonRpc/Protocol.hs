{-# LANGUAGE OverloadedStrings #-}
module Network.JsonRpc.Protocol (
    Request(..)
  , Response(..)
) where

import Control.Applicative ((<$>), (<*>))
import qualified Data.Text as T
import Data.Aeson (Value(Object), ToJSON(toJSON), FromJSON(parseJSON),
                   fromJSON, object, (.:), (.=) )

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
    parseJSON (Object v) = Request
                           <$> v .: "method"
                           <*> v .: "params"
                           <*> v .: "id"

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
    parseJSON (Object v) = Response
                           <$> v .: "result"
                           <*> v .: "error"
                           <*> v .: "id"

