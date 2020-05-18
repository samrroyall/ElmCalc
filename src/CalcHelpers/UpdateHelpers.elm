module CalcHelpers.UpdateHelpers exposing (..)

import CalcHelpers.CalcTypes exposing (..)

import String
import List

--------------------------------------------------------------------------------
------------------------------ Helpers for update ------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
----------------------------- Helpers for parsing ------------------------------
--------------------------------------------------------------------------------

takeWhile : List a -> a -> List a
takeWhile xs v =
  case xs of
    x :: rest ->
      if x /= v
        then x :: takeWhile rest v
        else []
    [] -> []

takeAfter : List a -> a -> List a
takeAfter xs v =
  case xs of
    x :: rest ->
      if x == v
        then rest
        else takeAfter rest v
    [] -> []

innerParens : List Symbol -> List Symbol
innerParens syms =
  List.reverse (takeWhile (List.reverse (takeWhile syms RParen)) LParen)

afterInnerParens : List Symbol -> List Symbol
afterInnerParens syms = takeAfter syms RParen

beforeInnerParens : List Symbol -> List Symbol
beforeInnerParens syms = List.reverse (takeAfter (List.reverse (takeWhile syms RParen)) LParen)

countParens : List Symbol -> Int -> Int
countParens syms score =
  if score < 0
    then -1
  else
    case syms of
      x :: rest ->
        if x == LParen
          then countParens rest (score + 1)
        else if x == RParen
          then countParens rest (score - 1)
        else countParens rest score
      [] -> score

containsTrig : List Symbol -> Bool
containsTrig syms =
  if List.member (Op "sin") syms
    then True
  else if List.member (Op "cos") syms
    then True
  else if List.member (Op "tan") syms
    then True
  else if List.member (Op "arcsin") syms
    then True
  else if List.member (Op "arccos") syms
    then True
  else if List.member (Op "arctan") syms
    then True
  else if List.member (Op "ln") syms
    then True
  else if List.member (Op "log") syms
    then True
  else False

handleTrig : List Symbol -> List Symbol
handleTrig syms =
  case syms of
    a :: b :: c :: rest ->
      if a == Op "sin"
        then reOrderHelper ((Ex a b Empty) :: c :: rest) (Just "trig")
      else if a == Op "cos"
        then reOrderHelper ((Ex a b Empty) :: c :: rest) (Just "trig")
      else if a == Op "tan"
        then reOrderHelper ((Ex a b Empty) :: c :: rest) (Just "trig")
      else if a == Op "arcsin"
        then reOrderHelper ((Ex a b Empty) :: c :: rest) (Just "trig")
      else if a == Op "arccos"
        then reOrderHelper ((Ex a b Empty) :: c :: rest) (Just "trig")
      else if a == Op "arctan"
        then reOrderHelper ((Ex a b Empty) :: c :: rest) (Just "trig")
      else if a == Op "ln"
        then reOrderHelper ((Ex a b Empty) :: c :: rest) (Just "trig")
      else if a == Op "log"
        then reOrderHelper ((Ex a b Empty) :: c :: rest) (Just "trig")
      else a :: reOrderHelper (b :: c :: rest) (Just "trig")
    _ -> Debug.todo "Should not happen"

reOrderHelper : List Symbol -> Maybe String -> List Symbol
reOrderHelper syms v =
  case syms of
    a :: b :: c :: rest ->
      case v of
        Nothing ->
          if containsTrig syms
            then reOrderHelper syms (Just "trig")
          else if (List.member (Op "r") syms)
            then reOrderHelper syms (Just "r")
          else if (List.member (Op "^") syms)
            then reOrderHelper syms (Just "^")
          else if (List.member (Op "*") syms) || (List.member (Op "/") syms)
            then reOrderHelper syms (Just "*/")
          else reOrderHelper syms (Just "+-")
        Just "trig" ->
          handleTrig syms
        Just "r" ->
          if a == Op "r"
            then reOrderHelper ((Ex (Op "^") b (FNum 0.5)) :: c :: rest) v
          else a :: reOrderHelper (b :: c :: rest) v
        Just "^" ->
          if b == Op "^"
            then reOrderHelper ((Ex (Op "^") a c) :: rest) v
          else a :: reOrderHelper (b :: c :: rest) v
        Just "*/" ->
          if b == Op "*"
            then  reOrderHelper ((Ex (Op "*") a c) :: rest) v
          else if b == Op "/"
            then reOrderHelper ((Ex (Op "/") a c) :: rest) v
          else a :: reOrderHelper (b :: c :: rest) v
        Just "+-" ->
          if b == Op "+"
            then reOrderHelper ((Ex (Op "+") a c) :: rest) v
          else if b == Op "-"
            then reOrderHelper ((Ex (Op "-") a c) :: rest) v
          else a :: reOrderHelper (b :: c :: rest) v
        _         -> Debug.todo "Should not happen"
    [a] ->
      case a of
        FNum _ -> [a]
        INum _ -> [a]
        Ex _ _ _ -> [a]
        _    -> [Empty]
    a :: b :: [] ->
      if a == (Op "r")
        then [Ex (Op "^") b (FNum 0.5)]
      else if a == (Op "sin")
        then [Ex a b Empty]
      else if a == (Op "cos")
        then [Ex a b Empty]
      else if a == (Op "tan")
        then [Ex a b Empty]
      else if a == (Op "arcsin")
        then [Ex a b Empty]
      else if a == (Op "arccos")
        then [Ex a b Empty]
      else if a == (Op "arctan")
        then [Ex a b Empty]
      else if a == (Op "log")
        then [Ex a b Empty]
      else if a == (Op "ln")
        then [Ex a b Empty]
      else [a, b]
    []  -> []

symReorder : List Symbol -> List Symbol
symReorder syms =
  let ordered = (reOrderHelper syms Nothing) in
    case ordered of
      [Empty]    -> ordered
      []         -> ordered
      [INum _]   -> ordered
      [FNum _]   -> ordered
      [Ex o f s] -> ordered
      _          -> (symReorder ordered)

exToExpr : Symbol -> Expr
exToExpr sym =
  case sym of
    Ex (Op s) l r ->
      if s == "+"
        then Plus (exToExpr l) (exToExpr r)
      else if s == "-"
        then Plus (exToExpr l) (Multiply (Floating -1.0) (exToExpr r))
      else if s == "^"
        then Power (exToExpr l) (exToExpr r)
      else if s == "*"
        then Multiply (exToExpr l) (exToExpr r)
      else if s == "/"
        then Divide (exToExpr l) (exToExpr r)
      else if s == "sin"
        then Sin (exToExpr l)
      else if s == "cos"
        then Cos (exToExpr l)
      else if s == "tan"
        then Tan (exToExpr l)
      else if s == "arcsin"
        then Arcsin (exToExpr l)
      else if s == "arccos"
        then Arccos (exToExpr l)
      else if s == "log"
        then Log (exToExpr l)
      else if s == "ln"
        then Ln (exToExpr l)
      else if s == "arctan"
        then Arctan (exToExpr l)
      else Debug.todo "Should not happen"
    INum x -> Floating (toFloat x)
    FNum x -> Floating x
    _               -> Debug.todo "Should not happen"


reOrder : List Symbol -> Expr
reOrder syms =
  let ordered = (reOrderHelper syms Nothing) in
    case ordered of
      [Empty]    -> Invalid
      []         -> Invalid
      [INum i]   -> exToExpr (INum i)
      [FNum f]   -> exToExpr (FNum f)
      [Ex o f s] -> exToExpr (Ex o f s)
      _          -> (reOrder ordered)

parseParens : List Symbol -> Expr
parseParens syms =
  if ((countParens syms 0) == 0) && (List.member LParen syms)
    then
      case symReorder (innerParens syms) of
        [Empty] -> Invalid
        ow      -> parseParens ((beforeInnerParens syms) ++ ow ++ (afterInnerParens syms))
  else if (countParens syms 0) == 0
    then
      case reOrder syms of
        Invalid -> Invalid
        ow      -> ow
  else Invalid

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

parseSymbolList : List Symbol -> Expr
parseSymbolList syms =
  if (List.member LParen syms) || (List.member RParen syms)
    then parseParens syms -- calls reOrder
    else reOrder syms

eval : Expr -> Float
eval ex =
  case ex of
    Plus l r     -> ((eval l) + (eval r))
    Multiply l r -> ((eval l) * (eval r))
    Divide l r   -> ((eval l) / (eval r))
    Power l r    -> ((eval l) ^ (eval r))
    Sin l        -> sin (eval l)
    Cos l        -> cos (eval l)
    Tan l        -> tan (eval l)
    Arcsin l     -> asin (eval l)
    Arccos l     -> acos (eval l)
    Arctan l     -> atan (eval l)
    Log l        -> logBase 10.0 (eval l)
    Ln l         -> logBase e (eval l)
    Floating x   -> x
    _            -> Debug.todo "Should not happen"

getSymbol : String -> Symbol
getSymbol s =
  if String.contains "." s
    then
      case (String.toFloat s) of
        Nothing -> Empty
        Just f  -> FNum f
    else
      case (String.toInt s) of
        Nothing -> Empty
        Just i  -> INum i

assignShift : String -> Msg
assignShift s =
  if s == "6"
    then Build ("^", Op "^")
  else if s == "8"
    then Build ("*", Op "*")
  else if s == "9"
    then Build ("(", LParen)
  else if s == "0"
    then Build (")", RParen)
  else if s == "="
    then Build ("+", Op "+")
  else DoNothing

checkLog : List (String, (Expr, String)) -> List (String, (Expr, String))
checkLog xs =
  if (List.length xs > 5)
    then
      case xs of
        x :: rest -> rest
        ow        -> ow
    else xs

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
