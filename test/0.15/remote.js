// Definition of browsers to test remotely

module.exports = function remote (rev) {
    return [{
/*        browserName: 'iphone',
        platform: 'OS X 10.10',
        version: '9.0',
        deviceName: 'iPhone 6',
        deviceOrientation: 'portrait',
        build: rev,
        name: 'iphone 6 ' + rev
    },{ */
        browserName: 'safari',
        version: '6.0',
        platform: 'OS X 10.8',
        build: rev,
        name: 'Safari Mountain Lion ' + rev
    },{
        browserName: 'safari',
        version: '7.0',
        platform: 'OS X 10.9',
        build: rev,
        name: 'Safari Mavericks ' + rev
    },{
        browserName: 'safari',
        version: '8.0',
        platform: 'OS X 10.10',
        build: rev,
        name: 'Safari El Yosemite ' + rev
    },{
        browserName: 'safari',
        version: '9.0',
        platform: 'OS X 10.11',
        build: rev,
        name: 'Safari El Capitan ' + rev
    }];
};
