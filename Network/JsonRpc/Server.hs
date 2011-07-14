module Network.JsonRpc.Server (
    handleReq
  , handleLine
  , handle
  , interactive
) where

import Control.Monad                (forever)
import Control.Applicative          ((<$>))

import qualified Data.ByteString.Lazy as LBS
import qualified Data.ByteString      as BS

import Data.Aeson     
import Network.JsonRpc

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
    case parse s of
        Nothing -> fail "invalid request"
        Just r  -> encode <$> f r

handle :: [MethodDescriptor] -> LBS.ByteString -> IO LBS.ByteString
handle = handleLine . handleReq

interactive :: (LBS.ByteString -> IO LBS.ByteString) -> IO ()
interactive f = forever $ do
    l <- BS.getLine
    let ll = LBS.fromChunks [l]
    o <- f ll
    LBS.putStr o
