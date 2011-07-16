module Network.JsonRpc.Utils (
    parseRpc
) where

import qualified Data.ByteString.Lazy as LBS
import qualified Data.Attoparsec.Lazy as A
import Data.Aeson (json, FromJSON, fromJSON, Result(Success, Error))

parseRpc :: FromJSON a => LBS.ByteString -> Maybe a
parseRpc input = do
    v <- A.maybeResult $ A.parse json input
    case fromJSON v of
        Success a -> Just a
        Error _   -> Nothing
