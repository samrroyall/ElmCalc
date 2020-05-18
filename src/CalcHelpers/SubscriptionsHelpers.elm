module CalcHelpers.SubscriptionsHelpers exposing (..)

import CalcHelpers.CalcTypes exposing (..)

import String
import Json.Decode as Decode


--------------------------------------------------------------------------------
--------------------------- Helpers for subscriptions --------------------------
--------------------------------------------------------------------------------

toKey : String -> Key
toKey string =
  case String.uncons string of
    Just (char, "") -> Character char
    _ -> Control string

keyDecoder : Decode.Decoder Key
keyDecoder = Decode.map toKey (Decode.field "key" Decode.string)

assignKey : Key -> Msg
assignKey k =
  case k of
    Character c ->
      -- Digits
      if (Char.isDigit c) || (c == '.')
        then AddSymbol (String.fromChar c)
      else if c == '-'
        then HandleMinus
      -- Operators
      else if (c == '/') || (c == '*') || (c == '+') || (c == '^') || (c == 'r')
        then Build ((String.fromChar c), Op (String.fromChar c))
      -- Other
      else if c == '('
        then Build ("(", LParen)
      else if c == ')'
        then Build (")", RParen)
      else if c == ' '
        then Build ("", Empty)
      --else DoNothing
      else Error ("Unknown key: " ++ (String.fromChar c))
    Control s   ->
      if s == "Escape"
        then Clear
      else if s == "Enter"
        then Calculate
      else if s == "Shift"
        then WaitForChar
      else if s == "Backspace"
        then Backspace
      else Error ("Unknown key: " ++ s)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
