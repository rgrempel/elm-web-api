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
        var NS = Elm.Native.Signal.make(localRuntime);

        var Listener = function Listener (phase, eventName, responder, target, callback) {
            this.phase = phase;
            this.eventName = eventName;
            this.responder = responder;
            this.target = target;
            this.callback = callback;

            this.useCapture = (this.phase.ctor == 'Capture');
        };

        Listener.prototype.addEventListener = function () {
            this.target.addEventListener(this.eventName, this, this.useCapture);
        };

        Listener.prototype.removeEventListener = function () {
            this.target.removeEventListener(this.eventName, this, this.useCapture);
        };

        Listener.prototype.handleEvent = function (evt) {
            var responses = A2(this.responder, evt, this);

            this.applyResponses(evt, responses);

            if (this.callback) {
                // If we have a callback, then we're supposed to stop listening,
                // and use the callback
                this.removeEventListener();
                this.callback(Task.succeed(evt));

                // Just in case, get rid of the callback ...
                this.callback = null;
            }
        };

        Listener.prototype.applyResponses = function (evt, responseList) {
            while (responseList.ctor !== '[]') {
                this.applyResponse(evt, responseList._0);
                responseList = responseList._1;
            }
        };

        Listener.prototype.applyResponse = function (evt, response) {
            switch (response.ctor) {
                case "PreventDefault":
                    evt.preventDefault();
                    break;

                case "StopPropagation":
                    evt.stopPropagation();
                    break;

                case "StopImmediatePropagation":
                    evt.stopImmediatePropagation();
                    break;

                case "Set":
                    evt[response._0] = response._1;
                    break;

                case "Send":
                    NS.sendMessage(response._0);
                    break;

                case "PerformTask":
                    Task.perform(response._0);
                    break;

                case "Remove":
                    this.removeEventListener();
                    break;

                default:
                    throw new Error("Incomplete pattern match in Native.WebAPI.Event");
            }
        };

        localRuntime.Native.WebAPI.Event.values = {
            addListener: F4(function (phase, eventName, responder, target) {
                return Task.asyncFunction(function (callback) {
                    var listener = new Listener(phase, eventName, responder, target, null);
                    listener.addEventListener();
                    callback(Task.succeed(listener));
                });
            }),

            addListenerOnce: F4(function (phase, eventName, responder, target) {
                return Task.asyncFunction(function (callback) {
                    var listener = new Listener(phase, eventName, responder, target, callback);
                    listener.addEventListener();
                });
            }),

            removeListener: function (listener) {
                return Task.asyncFunction(function (callback) {
                    listener.removeEventListener();
                    callback(Task.succeed(Utils.Tuple0));
                });
            }
        };
    }

    return localRuntime.Native.WebAPI.Event.values;
};
