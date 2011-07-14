import Network.JsonRpc
import Network.JsonRpc.Server (interactive, handle)

add :: Int -> Int -> IO Int
add a b = return $ a + b

main = interactive $ handle [("add", toMethod add)]
