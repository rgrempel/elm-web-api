Elm.Native = Elm.Native || {};
Elm.Native.WebAPI = Elm.Native.WebAPI || {};
Elm.Native.WebAPI.Json = Elm.Native.WebAPI.Json || {};

Elm.Native.WebAPI.Json.make = function (localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.WebAPI = localRuntime.Native.WebAPI || {};
    localRuntime.Native.WebAPI.Json = localRuntime.Native.WebAPI.Json || {};

    if (!localRuntime.Native.WebAPI.Json.values) { 
        localRuntime.Native.WebAPI.Json.values = {
            instanceOf: F2(function (func, value) {
                return value instanceof func;
            }),

            nativeTypeOf: function (value) {
                // We deal with null specially
                if (value === null) return 'null';
                return typeof value;
            },

            isString: function (value) {
                switch (typeof value) {
                    case 'string': return true;
                    case 'object': return value instanceof String;
                }

                return false;
            },

            isNumber: function (value) {
                switch (typeof value) {
                    case 'number': return true;
                    case 'object': return value instanceof Number;
                }

                return false;
            },

            isBoolean: function (value) {
                switch (typeof value) {
                    case 'boolean': return true;
                    case 'object': return value instanceof Boolean;
                }

                return false;
            },

            debox: function (value) {
                if (
                    typeof value === 'object' &&
                    (
                        value instanceof String ||
                        value instanceof Number ||
                        value instanceof Boolean
                    )
                ) {
                    return value.valueOf();
                } else {
                    return value;
                }
            },

            unsafeCoerce: function (value) {
                return value;
            }
        };
    }

    return localRuntime.Native.WebAPI.Json.values;
};
