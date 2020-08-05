### Information about Project

#### What I have made
  I have made a browser calculator app that is powered by Elm!

#### What I did to make it

**The model: initial thoughts**
  I began by building the skeleton of my program, I devised a model infrastructure,
a set of messages that would be needed, and an outline for how those messages would
be treated by the `update()` function. I figured I would need a `Build` message of
some kind, which would build up the expression as it was typed, or buttoned-in.
I figured I would also need a `Calculate` message which would evaluate the expression
and output the answer. Finally, I decided I should have a `Clear` message, which
would wipe the current computation string, which would be stored in the model.
Based on these considerations, I figured the model would need to store an input
string, and I also decided I wanted a log so that past computations could be shown
as well. Next, i decided on how the `subscriptions()` function would work.

**Symbols: initial thoughts**
  I began by grabbing key inputs, which I assumed would be harder to do than button
inputs. I was right. Since a message is sent on every single key stroke, I had to
come up with ways to fix a few problems. Firstly, it is not trivial to parse numbers
out of the input stream per-character. What I had to do was build the numbers up:
'1', followed by '2', followed by '3', followed by '+', had to become ['123', '+'].
Because of this problem, I decided to turn characters into symbols. Operators became
`Op String` symbols, numbers became `INum Int` symbols, and floating point numbers
became `FNum Float` symbols. This last step was done by splitting numbers into the
two groups based on whether or not they contained a '.' character. Left parentheses
and right parentheses both had their own symbol (because of PEMDAS) concerns. I
realized these symbols could be parsed out of the string input on the fly, so I
added a current symbols list to the model, instead of only having the current
string. This means that each key stroke would either be building up a number,
using the `AddSymbol` message, and then finally pushing the number to the current
symbols list with the `PushSymbol` message; building the expression, both the
current string and the current symbols list, with the `Build` message; clearing
the expression (`Clear`); or calculating it (`Calculate`). The final hurdle I
ran into was that sometimes, if the shift key was pressed slightly too early,
the '9' would be inputted instead of '(', and so on. I therefore had to essentially
build up operators and parentheses by waiting for the next character input when the
shift key is pressed. Because of this I added a `WaitForChar` message.

**Expressions: initial thoughts**
  Since computation needed to be done eventually, I figured an `Expr` type was
needed. The symbols would be converted into a recursively defined expression
tree. '(1+2)+(3+4)' would become `Expr Plus (Expr Plus 1 2) (Expr Plus 3 4)`,
and so on. These expressions would then be evaluated by recursing into the left
and right branches until reaching the numbers, and then doing all of the operations
afterward.

**Combining Symbols and Expressions**
  The most difficult part of this project was figuring out how to turn a list of
symbols into an expression that follows PEMDAS. I had to go through the expression
list in pairs of three turning `Num Op Num` in to `Expr Op Num Num`; however, I
had to split the expression up by parentheses pairs, transform that sublist into
an expression, and then continue with the rest of the list. Furthermore, I had
to traverse these sublists in rounds, first transforming the exponential operator
expressions, then the multiplication and division operators, and then the subtraction
and multiplication operators. Furthermore, I had to do error checking. This led me
to create an `Invalid` option for an expression. However, since I was transforming
these symbol lists in-line, I had to create `Ex Symbol Symbol Symbol` and `Empty`
analogs to `Expr Op Expr Expr` and `Invalid` because I needed the lists to be of
uniform type. However, once this was done, I only had to create a simple function
to convert the symbol `Ex` to an `Expr`. The evaluation function was pretty
simple too.

**Remaining Work Done**
  The next thing I did was to design the graphics using CSS. After having done
this, I added button functionality. This was relatively simple given the messages
and the functions that assigned keyboard input to messages.

**Further Work**
  The initial changes made were to add log, trigonometry, and square root functionality, where were very easy to change to my parser. I also included a backspace feature, which popped either the last character off of a number or the last symbol off of the `currSymbols` list. The final change was to parse different meaning of the '-' character. If it was next to a number or a parenthesis, it was a minus sign. If it was next to an operation or the first letter of the string, it was a negative sign.
