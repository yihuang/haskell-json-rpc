import Control.Monad
import Data.Aeson
import Network.JsonRpc (server, client, RpcProxy, toMethod, toProxy)

-- method exposed through rpc
add :: Int -> Int -> IO Int
add a b = return $ a + b

-- a server handler. ByteString -> IO ByteString
serv = server [("add", toMethod add)]

-- a proxy which call serv directly.
directProxy :: RpcProxy b => String -> b
directProxy method = toProxy (client serv method)

-- client proxy of add method
add' :: Int -> Int -> IO Int
add' = directProxy "add"

main = print =<< add' 1 2
