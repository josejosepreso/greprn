import System.Directory
import Control.Exception (catch, SomeException)

ls :: [FilePath] -> IO [FilePath]
ls [] = pure []
ls (x:xs) = ls xs `mappend` (ls =<< contents) `mappend` contents
  where contents = listDirectory x `catch` (\(e :: SomeException) -> pure [])

fullPath :: FilePath -> IO String
fullPath path = (++) <$> getCurrentDirectory <*> pure path

main :: IO ()
main = undefined
