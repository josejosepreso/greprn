import System.Directory
import System.Environment
import Control.Exception (try, catch, SomeException)
import Text.Regex.Posix
import qualified Data.ByteString as B
import System.Console.ANSI

handler :: SomeException -> IO [a]
handler e = pure []

lines' path = do
  content <- B.readFile path
  if B.isValidUtf8 content then lines <$> readFile path else pure []

grep :: String -> FilePath -> IO [String]
grep _ [] = pure []
grep query path = search 1 path <$> lines' path `catch` handler
  where search _ _ [] = []
        search i file (x:xs)
          | x =~ regex = output `mappend` search (succ i) file xs
          | otherwise = search (succ i) file xs
            where output = pure $ "FOUND\ESC[91m" ++ file ++ "\ESC[0m:\ESC[32m" ++ show i ++ "\ESC[0m:" ++ x
                  regex = ".*" ++ query ++ ".*"

find :: [String] -> [FilePath] -> IO [FilePath]
find [] _ = pure []
find _ [] = pure []
find query (x:xs) = (grep (head query) x) `mappend` (find query xs) `mappend` (dirContents >>= find query) `mappend` dirContents
  where dirContents = fullPath x <$> listDirectory x `catch` handler

fullPath :: FilePath -> [FilePath] -> [FilePath]
fullPath root paths = map ((++) (root ++ "/")) paths

main :: IO ()
main = do
  query <- getArgs
  getCurrentDirectory >>= listDirectory >>= find query >>= putStr . unlines . map (drop 5) . filter (=~ "FOUND*")
