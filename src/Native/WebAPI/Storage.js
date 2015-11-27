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
        var NS = Elm.Native.Signal.make(localRuntime);
        var Utils = Elm.Native.Utils.make(localRuntime);

        var Local = {ctor: 'Local'};
        var Session = {ctor: 'Session'};

        var Disabled = {ctor: 'Disabled'};
        var QuotaExceeded = {ctor: 'QuotaExceeded'};

        var toMaybe = function toMaybe (obj) {
            return obj === null ? Maybe.Nothing : Maybe.Just(obj);
        };

        var quotaWasExceeded = function quotaWasExceeded (e) {
            return e && (e.code == 22 || e.name === 'NS_ERROR_DOM_QUOTA_REACHED');
        };

        var hasStorage = function hasStorage () {
            try {
                // Return a boolean representing whether it's there or not.
                // Will throw an exception if it's disabled.
                return !!window.localStorage;
            } catch (e) {
                return false;
            }
        };

        var toNative = function toNative (storage) {
            if (!hasStorage()) throw Disabled;

            switch (storage.ctor) {
                case 'Local':
                    return window.localStorage;

                case 'Session':
                    return window.sessionStorage;

                default:
                    throw new Error("Incomplete pattern match in Storage.js.");
            }
        };

        var fromNative = function fromNative (storage) {
            if (!hasStorage()) throw Disabled;

            if (storage == window.localStorage) {
                return Local;
            } else if (storage == window.sessionStorage) {
                return Session;
            } else {
                throw new Error("Got unrecognized storage type in Storage.js");
            }
        };

        var handleException = function handleException (ex, callback) {
            var error;

            if (ex == Disabled) {
                error = ex;
            } else if (quotaWasExceeded(ex)) {
                error = QuotaWasExceeded;
            } else {
                error = {
                    ctor: 'Error',
                    _0: ex.toString()
                };
            }

            callback(Task.fail(error));
        };

        var length = function length (storage) {
            return Task.asyncFunction(function (callback) {
                try {
                    var s = toNative(storage);
                    callback(Task.succeed(s.length));
                } catch (ex) {
                    handleException(ex, callback);
                }
            });
        };

        var key = function key (storage, k) {
            return Task.asyncFunction(function (callback) {
                try {
                    var result = null;
                    var s = toNative(storage);

                    // This check needed to avoid a problem in IE9
                    if (k >= 0 && k < s.length) {
                        result = s.key(k);
                    }

                    callback(
                        Task.succeed(
                            toMaybe(result)
                        )
                    );
                } catch (ex) {
                    handleException(ex, callback);
                }
            });
        };

        var getItem = function getItem (storage, k) {
            return Task.asyncFunction(function (callback) {
                try {
                    var s = toNative(storage);
                    var result = s.getItem(k);

                    callback(
                        Task.succeed(
                            toMaybe(result)
                        )
                    );
                } catch (ex) {
                    handleException(ex, callback);
                }
            });
        };

        var setItem = function setItem (storage, k, v) {
            return Task.asyncFunction(function (callback) {
                try {
                    var s = toNative(storage);
                    s.setItem(k, v);
                    callback(Task.succeed(Utils.Tuple0));
                } catch (ex) {
                    handleException(ex, callback);
                }
            });
        };

        var removeItem = function removeItem (storage, k) {
            return Task.asyncFunction(function (callback) {
                try {
                    var s = toNative(storage);
                    s.removeItem(k);
                    callback(Task.succeed(Utils.Tuple0));
                } catch (ex) {
                    handleException(ex, callback);
                }
            });
        };

        var clear = function clear (storage) {
            return Task.asyncFunction(function (callback) {
                try {
                    var s = toNative(storage);
                    s.clear();
                    callback(Task.succeed(Utils.Tuple0));
                } catch (ex) {
                    handleException(ex, callback);
                }
            });
        };

        var enabled = Task.asyncFunction(function (callback) {
            callback(Task.succeed(hasStorage()));
        });

        var events = NS.input('WebAPI.Storage.nativeEvents', Maybe.Nothing);

        localRuntime.addListener([events.id], window, "storage", function (event) {
            var e = {
                key: toMaybe(event.key),
                oldValue: toMaybe(event.oldValue),
                newValue: toMaybe(event.newValue),
                url : event.url,
                storageArea: fromNative(event.storageArea)
            };
            
            localRuntime.notify(events.id, toMaybe(e));
        });

        localRuntime.Native.WebAPI.Storage.values = {
            length: length,
            key: F2(key),
            getItem: F2(getItem),
            setItem: F3(setItem),
            removeItem: F2(removeItem),
            clear: clear,
            enabled: enabled,

            nativeEvents: events
        };
    }
    
    return localRuntime.Native.WebAPI.Storage.values;
};
