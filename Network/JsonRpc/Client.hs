module Network.JsonRpc.Client (
    client
  , httpProxy
) where

import qualified Data.ByteString      as BS
import qualified Data.ByteString.Lazy as LBS
import Control.Applicative          ((<$>))
import Data.Aeson                   (Value, encode)
import Network.JsonRpc.Internals    (RpcProxy, toProxy)
import Network.JsonRpc.Protocol     (Request(..), Response(..), parseRpc)

-- TODO
httpTransport :: String -> LBS.ByteString -> IO LBS.ByteString
httpTransport url req = do
    print req
    l <- BS.getLine
    return $ LBS.fromChunks [l]

client :: (LBS.ByteString -> IO LBS.ByteString) -> String -> [Value] -> IO Value
client serv method params = do
    let req = encode $ Request {
        reqMethod = method
      , reqParams = params
      , reqId = 1
    }
    rsp <- parseRpc <$> serv req
    case rsp of
        Just r ->
            return $ respResult r
        Nothing -> fail "invalid response"

httpProxy :: RpcProxy a => String -> String -> a
httpProxy url method = toProxy (client (httpTransport url) method)
