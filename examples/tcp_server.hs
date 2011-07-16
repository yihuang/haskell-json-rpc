import Debug.Trace
import qualified Data.ByteString.Lazy as LBS
import System.Random hiding (random)
import System.IO
import System.Exit
import System.Posix.Time
import Foreign.C.Types (CTime)
import Control.Exception
import Control.Concurrent
import Control.Monad
import Data.Attoparsec.Number
import Data.Aeson
import Network.JsonRpc
import Network

instance FromJSON CTime where
    parseJSON x = case x of
                    (Number (I i)) -> return $ fromInteger i

instance ToJSON CTime where
    toJSON x = Number $ I $ toInteger $ fromEnum x

echo :: String -> IO String
echo s = return $ id s

random :: IO Int
random = randomIO

timestamp = epochTime

serve = server [("echo", toMethod echo)
               ,("random", toMethod random)
               ,("timestamp", toMethod timestamp)
               ]

tcpServer :: PortNumber -> IO ()
tcpServer port = withSocketsDo $ do
    sock <- listenOn $ PortNumber port
    forever $ do
        (h, host, port) <- accept sock
        hSetBuffering h NoBuffering
        forkIO . forever $ do
            putTraceMsg "reading request..."
            req <- LBS.hGetContents h
            when (LBS.null req) $ do
                putTraceMsg "closed"
                hClose h
                throwIO ThreadKilled
            putTraceMsg "handling..."
            rsp <- serve req
            putTraceMsg "sending response..."
            LBS.hPutStr h rsp

main = tcpServer 8000
