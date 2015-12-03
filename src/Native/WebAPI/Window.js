Elm.Native = Elm.Native || {};
Elm.Native.WebAPI = Elm.Native.WebAPI || {};
Elm.Native.WebAPI.Window = Elm.Native.WebAPI.Window || {};

Elm.Native.WebAPI.Window.make = function (localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.WebAPI = localRuntime.Native.WebAPI || {};
    localRuntime.Native.WebAPI.Window = localRuntime.Native.WebAPI.Window || {};

    if (!localRuntime.Native.WebAPI.Window.values) {
        var Task = Elm.Native.Task.make(localRuntime);
        var Utils = Elm.Native.Utils.make(localRuntime);
        var NS = Elm.Native.Signal.make(localRuntime);
    
        var elmAlert = function (message) {
            return Task.asyncFunction(function (callback) {
                window.alert(message);
                callback(Task.succeed(Utils.Tuple0));
            });
        };
    
        var elmConfirm = function (message) {
            return Task.asyncFunction(function (callback) {
                var result = window.confirm(message);
                callback(
                    result ? Task.succeed(Utils.Tuple0)
                           : Task.fail(Utils.Tuple0)
                );
            });
        };

        var elmPrompt = function (message, defaultResponse) {
            return Task.asyncFunction(function (callback) {
                var result = window.prompt(message, defaultResponse);
                callback(
                    // Safari returns "" when you press cancel, so
                    // we need to check for that.
                    /* jshint laxbreak: true */
                    result === null || result === ""
                        ? Task.fail(Utils.Tuple0)
                        : Task.succeed(result)
                );
            });
        };

        var isOnline = Task.asyncFunction(function (callback) {
            if (!('onLine' in navigator)) {
                throw new Error("navigator.onLine was null");
            } else {
                callback(Task.succeed(navigator.onLine));
            }
        });

        var online = NS.input('WebAPI.Window.online', navigator.onLine);

        localRuntime.addListener([online.id], window, 'online', function (event) {
            localRuntime.notify(online.id, true);
        });

        localRuntime.addListener([online.id], window, 'offline', function (event) {
            localRuntime.notify(online.id, false);
        });
 
        localRuntime.Native.WebAPI.Window.values = {
            encodeURIComponent: function (component) {
                return encodeURIComponent(component);
            },

            decodeURIComponent: function (component) {
                return decodeURIComponent(component);
            },

            alert: elmAlert,
            confirm: elmConfirm,
            prompt: F2(elmPrompt),
            events: window,
            isOnline: isOnline,
            online: online
        };
    }
    
    return localRuntime.Native.WebAPI.Window.values;
};
