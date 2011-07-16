{-# LANGUAGE RankNTypes #-}
import System.IO
import System.Posix.Types
import Foreign.C.Types (CTime)
import qualified Data.ByteString.Lazy as LBS
import Control.Concurrent
import Control.Exception
import Control.Monad
import Data.Attoparsec.Number
import Data.Aeson
import Network.JsonRpc
import Network

tcpProxy :: RpcProxy a => PortNumber -> String -> a
tcpProxy port = proxy handler
    where
    handler req = withSocketsDo $ do
        h <- connectTo "localhost" $ PortNumber port
        hSetBuffering h NoBuffering
        LBS.hPutStr h req
        LBS.hGetContents h

p :: RpcProxy a => String -> a
p = tcpProxy 8000

instance FromJSON CTime where
    parseJSON x = case x of
                    (Number (I i)) -> return $ fromInteger i

instance ToJSON CTime where
    toJSON x = Number $ I $ toInteger $ fromEnum x

echo = p "echo" :: String -> IO String
timestamp = p "timestamp" :: IO EpochTime
random = p "random" :: IO Int

main = do
    vars <- forM [1..10] $ \n -> do
        finish <- newEmptyMVar
        forkIO $ do
            echo ("test"++show n) >>= putStrLn . ("echo: "++) .show
            timestamp >>= putStrLn . ("timestamp: "++) . show
            random >>= putStrLn . ("random: "++) . show
            `finally`
            putMVar finish ()
        return finish
    forM_ vars takeMVar
