Elm.Native = Elm.Native || {};
Elm.Native.WebAPI = Elm.Native.WebAPI || {};
Elm.Native.WebAPI.Storage = Elm.Native.WebAPI.Storage || {};

Elm.Native.WebAPI.Storage.make = function (localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.WebAPI = localRuntime.Native.WebAPI || {};
    localRuntime.Native.WebAPI.Storage = localRuntime.Native.WebAPI.Storage || {};

    if (!localRuntime.Native.WebAPI.Storage.values) {
        var Task = Elm.Native.Task.make(localRuntime);
        var Maybe = Elm.Maybe.make(localRuntime);
        var Utils = Elm.Native.Utils.make(localRuntime);
    
        var length = function (storage) {
            return Task.asyncFunction(function (callback) {
                callback(Task.succeed(storage.length));
            });
        };

        var key = function (storage, k) {
            return Task.asyncFunction(function (callback) {
                var result = storage.key(k);
                callback(
                    Task.succeed(
                        result == null ? Maybe.Nothing : Maybe.Just(result)
                    )
                );
            });
        };

        var getItem = function (storage, k) {
            return Task.asyncFunction(function (callback) {
                var result = storage.getItem(k);
                callback(
                    Task.succeed(
                        result == null ? Maybe.Nothing : Maybe.Just(result)
                    )
                );
            });
        };

        var setItem = function (storage, k, v) {
            return Task.asyncFunction(function (callback) {
                try {
                    storage.setItem(k, v);
                    callback(Task.succeed(Utils.Tuple0));
                } catch (ex) {
                    callback(Task.fail(ex.message));
                }
            });
        };

        var removeItem = function (storage, k) {
            return Task.asyncFunction(function (callback) {
                storage.removeItem(k);
                callback(Task.succeed(Utils.Tuple0));
            });
        };

        var clear = function (storage) {
            return Task.asyncFunction(function (callback) {
                storage.clear();
                callback(Task.succeed(Utils.Tuple0));
            });
        };

        localRuntime.Native.WebAPI.Storage.values = {
            localStorage: window.localStorage,
            sessionStorage: window.sessionStorage,

            length: length,
            key: F2(key),
            getItem: F2(getItem),
            setItem: F3(setItem),
            removeItem: F2(removeItem),
            clear: clear
        };
    }
    
    return localRuntime.Native.WebAPI.Storage.values;
};
