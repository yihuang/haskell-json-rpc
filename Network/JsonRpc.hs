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
-- >-- method exposed through rpc
-- >add :: Int -> Int -> IO Int
-- >add a b = return $ a + b
-- >
-- >-- a server handler. ByteString -> IO ByteString
-- >serv = server [("add", toMethod add)]
-- >
-- >-- a proxy which call serv directly.
-- >directProxy = proxy serv
-- >
-- >-- client proxy of add method
-- >add' :: Int -> Int -> IO Int
-- >add' = directProxy "add"
-- >
-- >main = add' 1 2 >>= print
