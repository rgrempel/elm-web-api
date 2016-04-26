module WebAPI.Node
    ( Node
    ) where

{-| Support for DOM nodes, as described in

    https://developer.mozilla.org/en-US/docs/Web/API/Node

This is a low-level module ... normally you would not want to use this module
directly, but instead use other modules that build on it.

In fact, in the usual Elm architecture, you don't want to access or manipulate
the real DOM at all -- instead, your `view` function produces a virtual DOM
that the runtime system efficiently manages.

However, there are cases where actually accessing the DOM is necessary, so
here you are.
-}


import Task exposing (Task)
import WebAPI.Event exposing (Target)

import Native.WebAPI.Node


{-| Opaque type which represents a DOM node.

To obtain a `Node`, see methods such as `WebAPI.Document.node` and
`WebAPI.Window.node`.
-}
type Node = Node


{-| Given a `Node`, obtain a `Target` for `WebAPI.Event`. -}
target : Node -> Target
target = Native.WebAPI.Node.events


{-| Gets the baseURI. Note that the baseURI can change, so this has to be a
`Task` rather than a plain function.
-}
baseURI : Node -> Task x String
baseURI = Native.WebAPI.Node.baseURI


{-| A list of Nodes. Since it is a *live* list, we need a `Task` to turn it
into a `List Node`.-}
type NodeList = NodeList


{-| Gets the length of a NodeList -}
length : NodeList -> Task x Int
length = Native.WebAPI.Node.length


{-| Gets the node at the index. -}
item : Int -> NodeList -> Task x (Maybe Node)
item = Native.WebAPI.Node.item 


{-| Gets an immutable list. -}
{-
list : NodeList -> TaskList Node
list = Native.WebAPI.Node.list
-}

{-| The childNodes. We can obtain them with a normal function call. However,
because the list is *live*, we will need a `Task` to actually extract the
nodes. So, this is an intermediate sort of operation.

To put it another way, the `NodeList` is immutable from Elm's point of view. In
the real world, it changes, but since we only access it via a `Task`, it
doesn't change in terms of its Elm semantics.
-}
childNodes : Node -> NodeList
childNodes = Native.WebAPI.Node.childNodes
