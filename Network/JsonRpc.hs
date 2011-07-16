-- |
-- Module      :  Network.JsonRpc
-- Copyright   :  huanyi 2011-2011
-- License     :  BSD3
-- 
-- Maintainer  :  yi.codeplayer@gmail.com
-- Stability   :  experimental
-- Portability :  unknown
--
-- haskell json rpc library.

module Network.JsonRpc (
    -- $example
    RpcProxy(..)
  , RpcMethod(..)
  , client
  , proxy
  , server
  , httpProxy
  , Request(..)
  , Response(..)
) where

import Network.JsonRpc.Protocol
import Network.JsonRpc.Internals
import Network.JsonRpc.Server
import Network.JsonRpc.Client

-- $example
-- example:
--
-- >import Network.JsonRpc (server, client, proxy, toMethod)
-- >
-- >-- method exposed with rpc
-- >add :: Int -> Int -> IO Int
-- >add a b = return $ a + b
-- >
-- >-- a server handler. ByteString -> IO ByteString
-- >-- in a real world rpc server, this handler can be used to handle network message.
-- >serv = server [("add", toMethod add)]
-- >
-- >-- a proxy which call serv directly.
-- >-- a real world rpc proxy would communicate with remote server through network.
-- >directProxy = proxy serv
-- >
-- >add' :: Int -> Int -> IO Int
-- >add' = directProxy "add"
-- >
-- >main = add' 1 2 >>= print
