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
        var Maybe = Elm.Maybe.make(localRuntime);
        var NS = Elm.Native.Signal.make(localRuntime);

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
            // String -> WebAPI.Event.Options -> Task x Event
            event: F2(function (eventType, options) {
                return Task.asyncFunction(function (callback) {
                    var event;

                    try {
                        event = new Event(eventType, options);
                    } catch (ex) {
                        event = document.createEvent('Event');
                        event.initEvent(eventType, options.bubbles, options.cancelable);
                    }

                    callback(Task.succeed(event));
                });
            }),

            // String -> Json.Encode.Value -> WebAPI.Event.Options -> Task x CustomEvent
            customEvent: F3(function (eventType, detail, options) {
                var params = Utils.update(options, {});
                params.detail = detail;

                return Task.asyncFunction(function (callback) {
                    var event;

                    try {
                        event = new CustomEvent(eventType, params);
                    } catch (ex) {
                        event = document.createEvent('CustomEvent');
                        event.initCustomEvent(eventType, options.bubbles, options.cancelable, detail);
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
