import Network.JsonRpc (server, proxy, toMethod)

-- method exposed through rpc
add :: Int -> Int -> IO Int
add a b = return $ a + b

-- a server handler. ByteString -> IO ByteString
serv = server [("add", toMethod add)]

-- a proxy which call serv directly.
directProxy = proxy serv

-- client proxy of add method
add' :: Int -> Int -> IO Int
add' = directProxy "add"

main = add' 1 2 >>= print
