module Network.JsonRpc.Server (
    server
  , MethodDescriptor 
) where

import Control.Monad            (forever)
import Control.Applicative      ((<$>))
import Data.Aeson               (Value(..), encode)
import Network.JsonRpc.Protocol (Request(..), Response(..), parseRpc)
import qualified Data.ByteString.Lazy as LBS
import qualified Data.ByteString      as BS

type MethodDescriptor = (String, ([Value] -> IO Value))

handleReq :: [MethodDescriptor] -> Request -> IO Response
handleReq methods req = do
    let name = reqMethod req
        params = reqParams req
    case lookup name methods of
        Just f -> do
            r <- f params
            return $ Response r Null (reqId req)

handleLine :: (Request -> IO Response) -> LBS.ByteString -> IO LBS.ByteString
handleLine f s =
    case parseRpc s of
        Nothing -> fail "invalid request"
        Just r  -> encode <$> f r

server :: [MethodDescriptor] -> LBS.ByteString -> IO LBS.ByteString
server = handleLine . handleReq

interactive :: (LBS.ByteString -> IO LBS.ByteString) -> IO ()
interactive f = forever $ do
    l <- BS.getLine
    let ll = LBS.fromChunks [l]
    o <- f ll
    LBS.putStr o

