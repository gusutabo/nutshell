import Data.Char

data Token
  = TokOpenParen -- (
  | TokCloseParen -- )
  | TokOp String -- +, -, /, *
  | TokIdent String -- Identifiers
  | TokNum Int -- Integer numbers
  deriving (Show, Eq)

tokenize :: String -> [Token] -- Receives a string and transforms it into a list of Tokens.
tokenize [] = [] -- Base case: empty input = empty list.
tokenize (c:cs)
  | isSpace c = tokenize cs -- Skips whitespace
  -- Recognizes opening and closing parentheses
  | c == '(' = TokOpenParen : tokenize cs
  | c == ')' = TokCloseParen : tokenize cs
  -- Recognizes mathematical operators
  | c `elem` "+-*/" = TokOp [c] : tokenize cs
  -- Recognizes identifiers made of letters and digits
  | isAlpha c =
      let (ident, rest) = span isAlphaNum cs
      in TokIdent (c : ident) : tokenize rest
  -- Recognizes integer numbers
  | isDigit c =
      let (numStr, rest) = span isDigit cs
      in TokNum (read (c : numStr)) : tokenize rest
  -- Raises an error if the character is not recognized
  | otherwise = error ("Lexical Error: Unexpected '" ++ [c] ++ "'")

main :: IO ()
main = do
  let input = "(age + 42) * 5"
  print (tokenize input)