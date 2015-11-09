Elm.Native = Elm.Native || {};
Elm.Native.WebAPI = Elm.Native.WebAPI || {};
Elm.Native.WebAPI.Cookie = Elm.Native.WebAPI.Cookie || {};

Elm.Native.WebAPI.Cookie.make = function (localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.WebAPI = localRuntime.Native.WebAPI || {};
    localRuntime.Native.WebAPI.Cookie = localRuntime.Native.WebAPI.Cookie || {};

    if (!localRuntime.Native.WebAPI.Cookie.values) {
        var Task = Elm.Native.Task.make(localRuntime);
        var Utils = Elm.Native.Utils.make(localRuntime);

        var disabled = {
            ctor: 'Disabled'
        };

        var error = function (string) {
            return {
                ctor: 'Error',
                _0: string.toString()
            };
        };

        localRuntime.Native.WebAPI.Cookie.values = {
            getString: Task.asyncFunction(function (callback) {
                try {
                    if (navigator.cookieEnabled == false) {
                        callback(Task.fail(disabled));
                    } else {
                        callback(Task.succeed(document.cookie));
                    }
                } catch (ex) {
                    callback(Task.fail(error(ex)));
                }
            }),

            setString: function (cookie) {
                return Task.asyncFunction(function (callback) {
                    try {
                        if (navigator.cookieEnabled == false) {
                            callback(Task.fail(disabled));
                        } else {
                            document.cookie = cookie;
                            callback(Task.succeed(Utils.Tuple0));
                        }
                    } catch (ex) {
                        callback(Task.fail(error(ex)));
                    }
                });
            },

            dateToUTCString: function (date) {
                return date.toUTCString();
            },

            uriEncode: function (string) {
                return encodeURIComponent(string);
            },

            uriDecode: function (string) {
                return decodeURIComponent(string);
            },

            enabled: Task.asyncFunction(function (callback) {
                if (navigator.cookieEnabled == null) {
                    throw new Error("navigator.cookieEnabled was not defined");
                } else {
                    callback(Task.succeed(navigator.cookieEnabled));
                }
            })
        };
    }

    return localRuntime.Native.WebAPI.Cookie.values;
};
