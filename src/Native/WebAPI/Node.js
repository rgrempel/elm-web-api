Elm.Native = Elm.Native || {};
Elm.Native.WebAPI = Elm.Native.WebAPI || {};
Elm.Native.WebAPI.Node = Elm.Native.WebAPI.Node || {};

Elm.Native.WebAPI.Node.make = function (localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.WebAPI = localRuntime.Native.WebAPI || {};
    localRuntime.Native.WebAPI.Node = localRuntime.Native.WebAPI.Node || {};

    if (!localRuntime.Native.WebAPI.Node.values) {
        var Task = Elm.Native.Task.make(localRuntime);
        var Utils = Elm.Native.Utils.make(localRuntime);
        var Maybe = Elm.Maybe.make(localRuntime);

        var toMaybe = function toMaybe (obj) {
            return obj === null ? Maybe.Nothing : Maybe.Just(obj); 
        };

        localRuntime.Native.WebAPI.Node.values = {
            events: function (node) {
                // This is essentially a coercion, as we know that all Nodes
                // are also EventTargets.
                return node;
            },

            baseURI: function (node) {
                return Task.asyncFunction(function (cb) {
                    cb(Task.succeed(node.baseURI));
                });
            },

            childNodes: function (node) {
                return node.childNodes;
            },

            length: function (nodeList) {
                return Task.asyncFunction(function (cb) {
                    cb(Task.succeed(nodeList.length));
                });
            },

            item: function (index, nodeList) {
                return Task.asyncFunction(function (cb) {
                    var item = nodeList.item(index);
                    cb(Task.succeed(toMaybe(item)));
                });
            },

            list: function (nodeList) {
                return Task.asyncFunction(function (cb) {
                    
                });
            }
        };
    }

    return localRuntime.Native.WebAPI.Node.values;
};
