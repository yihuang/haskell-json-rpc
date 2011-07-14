module Network.JsonRpc.Client (
    proxy
) where

import Control.Applicative
import qualified Data.ByteString      as BS
import qualified Data.ByteString.Lazy as LBS
import Data.Aeson (Value, encode)
import Network.JsonRpc
import Network.JsonRpc.Protocol (parse)

transport :: LBS.ByteString -> IO LBS.ByteString
transport req = do
    print req
    l <- BS.getLine
    return $ LBS.fromChunks [l]

worker :: String -> String -> [Value] -> IO Value
worker url method params = do
    let req = encode $ Request {
        reqMethod = method
      , reqParams = params
      , reqId = 1
    }
    rsp <- parse <$> transport req
    case rsp of
        Just r ->
            return $ respResult r
        Nothing -> fail "invalid response"

proxy :: RpcProxy a => String -> String -> a
proxy url method = toProxy (worker url method)

