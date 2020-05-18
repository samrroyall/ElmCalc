module CalcHelpers.ViewHelpers exposing (..)

import CalcHelpers.CalcTypes exposing (..)

import Html exposing (..)
import Html.Events
import Html.Attributes
import List
import String

--------------------------------------------------------------------------------
------------------------------ Helpers for view ------------------------------
--------------------------------------------------------------------------------

class : String -> List (Attribute Msg)
class s =
  if s == "calculator"
    then ( List.map (\(k, v) -> Html.Attributes.style k v)
           [ ("position", "fixed")
           , ("top", "50%")
           , ("left", "50%")
           , ("transform", "translate(-50%, -50%)")
           , ("background-color", "#253147")
           , ("min-width", "350px")
           , ("width", "auto")
           , ("min-height", "50px")
           , ("height", "auto")
           , ("border-radius", "15px 15px 80px 80px")
           , ("border", "1px solid black")
           , ("padding", "0px 15px 100px 15px")
           ]
         )
  else if s == "log"
    then ( List.map (\(k, v) -> Html.Attributes.style k v)
           [ ("background-color", "#808780")
           , ("width", "auto")
           , ("min-width", "300")
           , ("border", "1px solid black")
           , ("box-shadow", "inset 0px 1px 0px 1px")
           , ("padding", "15px")
           , ("height", "200px")
           , ("text-align", "left")
           ]
         )
  else if s == "title"
    then ( List.map (\(k, v) -> Html.Attributes.style k v)
           [ ("text-align", "center")
           , ("color", "#838587")
           , ("font-weight", "900")
           , ("font-size", "20px")
           , ("padding-bottom", "40px")
           ]
         )
  else if s == "screenWrapper"
    then ( List.map (\(k, v) -> Html.Attributes.style k v)
           [ ("background-color", "#e5e5de")
           , ("min-width", "350px")
           , ("width", "auto")
           , ("min-height", "50px")
           , ("height", "auto")
           , ("border-radius", "0px 0px 15px 15px")
           , ("border", "1px solid black")
           , ("padding", "40px 30px 50px 30px")
           , ("font-family", "Consolas,monaco,monospace")
           ]
         )
  else if s == "logExpr"
    then ( List.map (\(k, v) -> Html.Attributes.style k v)
           [("text-align", "left")]
         )
  else if s == "logAns"
    then ( List.map (\(k, v) -> Html.Attributes.style k v)
           [("text-align", "right")]
         )
  else if s == "entry"
    then ( List.map (\(k, v) -> Html.Attributes.style k v)
           [ ("background-color", "#808780")
           , ("text-align", "left")
           , ("width", "auto")
           , ("min-width", "300px")
           , ("border", "1px solid black")
           , ("box-shadow", "inset 0px 0px 0px 1px")
           , ("padding", "5px 5px 5px 15px")
           , ("height", "auto")
           , ("min-height", "20px")
           ]
         )
  else if s == "buttons"
    then ( List.map (\(k, v) -> Html.Attributes.style k v)
           [ ("height", "200px")
           , ("padding", "30px 0px 0px 0px")
           , ("text-align", "center")
           ]
         )
  else if s == "row"
    then ( List.map (\(k, v) -> Html.Attributes.style k v)
           [ ("height", "40px")
           , ("margin-bottom", "10px")
           , ("margin-left", "10px")
           ]
         )
  else if s == "hiddenButton"
    then ( List.map (\(k, v) -> Html.Attributes.style k v)
           [ ("background-color", "#253147")
           , ("border", "none")
           , ("color", "#212c3d")
           , ("padding", "5px")
           , ("border-radius", "15px 15px 30px 30px")
           , ("height", "30px")
           , ("width", "60px")
           , ("margin-right", "10px")
           ]
         )
  else if s == "numButton"
    then ( List.map (\(k, v) -> Html.Attributes.style k v)
           [ ("background-color", "#e5e5de")
           , ("border", "none")
           , ("color", "#212c3d")
           , ("padding", "5px")
           , ("border-radius", "15px 15px 30px 30px")
           , ("height", "40px")
           , ("width", "60px")
           , ("font-weight", "900")
           , ("font-size", "20px")
           , ("margin-right", "10px")
           ]
         )
  else if s == "opButton"
    then ( List.map (\(k, v) -> Html.Attributes.style k v)
           [ ("background-color", "#212c3d")
           , ("border", "none")
           , ("color", "#e5e5de")
           , ("padding", "5px")
           , ("border-radius", "15px 15px 30px 30px")
           , ("height", "30px")
           , ("width", "60px")
           , ("line-height", "-5px")
           , ("font-weight", "900")
           , ("font-size", "17px")
           , ("margin-right", "10px")
           ]
         )
  else if s == "ctrlButton"
    then ( List.map (\(k, v) -> Html.Attributes.style k v)
           [ ("background-color", "#a3d1a3")
           , ("color", "#e5e5de")
           , ("border", "none")
           , ("padding", "5px")
           , ("border-radius", "15px 15px 30px 30px")
           , ("height", "30px")
           , ("width", "60px")
           , ("font-weight", "900")
           , ("font-size", "13px")
           , ("margin-right", "10px")
           ]
         )
  else if s == "errors"
    then ( List.map (\(k, v) -> Html.Attributes.style k v)
           [ ("background-color", "yellow")
           , ("text-align", "center")
           ]
         )
  else
    Debug.todo "Should not happen"

makeButton : String -> Html Msg
makeButton s =
  if s == ""
    then
      Html.button
        ( class "hiddenButton" )
        [ ]
  else if String.contains s "0123456789"
    then
      Html.button
        (( class "numButton") ++ [Html.Events.onClick (AddSymbol s)])
        [ Html.text s ]
  else if (String.contains s) "^/*+"
    then
      Html.button
        (( class "opButton") ++ [Html.Events.onClick (Build (s, Op s))])
        [ Html.text s ]
  else if s == "."
    then
     Html.button
        (( class "opButton") ++ [Html.Events.onClick (AddSymbol s)])
        [ Html.text s ]
  else if s == "("
    then
     Html.button
        (( class "opButton") ++ [Html.Events.onClick (Build (s, LParen))])
        [ Html.text s ]
  else if s == ")"
    then
      Html.button
        (( class "opButton") ++ [Html.Events.onClick (Build (s, RParen))])
        [ Html.text s ]
  else if s == "-"
    then
      Html.button
        (( class "opButton") ++ [Html.Events.onClick (HandleMinus)])
        [ Html.text s ]
  else if s == "\u{221A}"
    then
      Html.button
        (( class "opButton") ++ [Html.Events.onClick (Build (s, Op "r"))])
        [ Html.text s ]
  else if (s == "sin") || (s == "cos") || (s == "tan")
    then
      Html.button
        (( class "opButton") ++ [Html.Events.onClick (Trig s)])
        [ Html.text s ]
  else if String.contains "\u{207b}\u{00b9}" s
    then
      let name = "arc" ++ (String.slice 0 3 s) in
      Html.button
        (( class "opButton") ++ [Html.Events.onClick (Trig name)])
        [ Html.text s ]
  else if s == "ln"
    then
      Html.button
        (( class "opButton") ++ [Html.Events.onClick (Trig "ln")])
        [ Html.text s ]
  else if s == "log"
    then
      Html.button
        (( class "opButton") ++ [Html.Events.onClick (Trig "log")])
        [ Html.text s ]
  else if s == "CLEAR"
    then
      Html.button
        (( class "ctrlButton") ++ [Html.Events.onClick Clear ])
        [ Html.text s ]
  else if s == "DEL"
    then
      Html.button
        (( class "ctrlButton") ++ [Html.Events.onClick Backspace ])
        [ Html.text s ]
  else if s == "ENTER"
    then
      Html.button
        (( class "ctrlButton") ++ [Html.Events.onClick Calculate ])
        [ Html.text s ]
  else Debug.todo "Should not happen"

displayLog : List (String, (Expr, String)) -> List (Html Msg)
displayLog exes =
  case exes of
    (exString, (_, exAns)) :: rest ->
       [ Html.div (class "logExpr") [Html.text (exString)]
         , Html.div (class "logAns")  [Html.text (exAns)]
       ]
       ++ displayLog rest
    []        -> []

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
