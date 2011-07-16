import System.IO
import Control.Monad
import Control.Concurrent
import Network.Socket
import Network.JsonRpc (server, proxy, toMethod)
import qualified Data.ByteString.Lazy as LBS

-- method exposed through rpc
add :: Int -> Int -> IO Int
add a b = return $ a + b

-- a server handler. ByteString -> IO ByteString
serv = server [("add", toMethod add)]

main = withSocketsDo $ do
    sock <- socket AF_INET Stream defaultProtocol
    bindSocket sock $ SockAddrInet (PortNum 8000) 0
    listen sock 1
    forever $ do
        (csock, addr) <- accept sock
        forkIO $ do
            h <- socketToHandle csock ReadWriteMode
            input <- LBS.hGetContents h
            output <- serv input
            LBS.hPutStr h output
            hClose h
