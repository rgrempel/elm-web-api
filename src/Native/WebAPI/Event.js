Elm.Native = Elm.Native || {};
Elm.Native.WebAPI = Elm.Native.WebAPI || {};
Elm.Native.WebAPI.Event = Elm.Native.WebAPI.Event || {};

Elm.Native.WebAPI.Event.make = function (localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.WebAPI = localRuntime.Native.WebAPI || {};
    localRuntime.Native.WebAPI.Event = localRuntime.Native.WebAPI.Event || {};

    if (!localRuntime.Native.WebAPI.Event.values) {
        var Task = Elm.Native.Task.make(localRuntime);
        var Utils = Elm.Native.Utils.make(localRuntime);
        var JE = Elm.Native.Json.make(localRuntime);
        var List = Elm.List.make(localRuntime);
        var NL = Elm.Native.List.make(localRuntime);
        var Maybe = Elm.Maybe.make(localRuntime);
        var Basics = Elm.Basics.make(localRuntime);

        var toMaybe = function toMaybe (obj) {
            return obj === null || obj === undefined ? Maybe.Nothing : Maybe.Just(obj);
        };

        // Copied from Native/Json.js
        var crash = function crash (expected, actual) {
            throw new Error(
                'expecting ' + expected + ' but got ' + JSON.stringify(actual)
            );
        };

        localRuntime.Native.WebAPI.Event.values = {
            construct: F3(function (eventClass, eventName, options) {
                var params = JE.encodeObject(options);
                var args;

                return Task.asyncFunction(function (callback) {
                    var event;

                    try {
                        event = new window[eventClass](eventName, params);
                    } catch (ex) {
                        event = document.createEvent(eventClass);

                        // Don't calculate the args unless we need them, but cache
                        // them if we do.
                        if (!args) {
                            var jsList = A2(List.map, Basics.snd, options);
                            args = [eventName].concat(NL.toArray(jsList));
                        }

                        event["init" + eventClass].apply(event, args);
                    }

                    callback(Task.succeed(event));
                });
            }),

            eventType: function (event) {
                return event.type;
            },

            bubbles: function (event) {
                return event.bubbles;
            },

            cancelable: function (event) {
                return event.cancelable;
            },

            timestamp: function (event) {
                return event.timeStamp;
            },

            eventPhase: function (event) {
                return event.eventPhase;
            },

            dispatch: F2(function (target, event) {
                return Task.asyncFunction(function (callback) {
                    try {
                        var performDefaultAction = target.dispatchEvent(event);
                        callback(Task.succeed(performDefaultAction));
                    } catch (ex) {
                        callback(Task.fail(ex.toString()));
                    }
                });
            }),

            target: function (event) {
                return toMaybe(event.target);
            },

            currentTarget: function (event) {
                return toMaybe(event.currentTarget);
            },

            stopPropagation: function (event) {
                return Task.asyncFunction(function (callback) {
                    event.stopPropagation();
                    callback(Utils.Tuple0);
                });
            },

            stopImmediatePropagation: function (event) {
                return Task.asyncFunction(function (callback) {
                    event.stopImmediatePropagation();
                    callback(Utils.Tuple0);
                });
            },

            preventDefault: function (event) {
                return Task.asyncFunction(function (callback) {
                    event.preventDefault();
                    callback(Utils.Tuple0);
                });
            },

            defaultPrevented: function (event) {
                return event.defaultPrevented;
            },

            decoder: F2(function (className, value) {
                if (value instanceof window[className]) {
                    return value;
                }

                crash("an " + className, value);
            })
        };
    }

    return localRuntime.Native.WebAPI.Event.values;
};
