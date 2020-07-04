import Data.List
import System.Environment (getArgs)
import System.IO (putStr)

strSplit :: Char -> String -> [String]
strSplit _ "" = []
strSplit c str = case dropWhile (== c) str of
    "" -> []
    str' -> w : strSplit c str''
        where (w, str'') = break (== c) str'

seps :: [String]
seps = map makeSep [0..]
  where
    makeSep 0 = "%F{240}"
    makeSep n = " %F{" ++ (show n) ++ "}»%F{240} "

buildPath :: [String] -> [String] -> Integer -> String
buildPath [] _ 0 = "%F{240}/"
buildPath [] _ _ = ""
buildPath x c 0
  | "~" `isPrefixOf` (head x) = (head c) ++ (head x) ++ (buildPath (tail x) (tail c) 1)
  | otherwise = (head c) ++ "/" ++ (head x) ++ (buildPath (tail x) (tail c) 1)
buildPath x c _ = (head c) ++ (head x) ++ (buildPath (tail x) (tail c) 1)

main = do
  argv <- getArgs

  putStr $ buildPath (strSplit '/' $ head argv) seps 0
