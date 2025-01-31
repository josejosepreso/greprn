import System.Directory
import System.Environment
import Control.Exception (catch, SomeException)
import Text.Regex.Posix
import Data.Either

handler :: SomeException -> IO [a]
handler e = pure []

grep :: String -> FilePath -> IO [String]
grep _ [] = pure []
grep query path = search 1 path <$> (lines <$> readFile path) `catch` handler
  where search _ _ [] = []
        search i file (x:xs)
          | x =~ (".*" ++ query ++ ".*") =
            pure ("FOUND" ++ file ++ ":" ++ show i ++ ": " ++ x)
            `mappend` search (succ i) file xs
          | otherwise = search (succ i) file xs

find :: [String] -> [FilePath] -> IO [FilePath]
find [] _ = pure []
find _ [] = pure []
find query (x:xs) = (grep (head query) x) `mappend` (find query xs) `mappend` (contents >>= find query) `mappend` contents
  where contents = fullPath x <$> listDirectory x `catch` handler

fullPath :: FilePath -> [FilePath] -> [FilePath]
fullPath root paths = map ((++) (root ++ "/")) paths

main :: IO ()
main = do
  query <- getArgs
  getCurrentDirectory >>= listDirectory >>= find query >>= putStr . unlines . map (drop 5) . filter (=~ "FOUND*")
