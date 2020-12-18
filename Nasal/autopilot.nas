var autothrottleModeNames = [
        'ALT',
        'AGL',
        'V/S',
        'IAS',
        'CLB',
        'DES',
    ];

var lateralModeNames = [
        'LEVEL',
        'N/A',
        'HDG',
        'LNAV',
    ];

var verticalModeNames = [
        'ALT',
        'AGL',
        'V/S',
        'IAS',
    ];


var propAutothrottleMode = props.globals.getNode('/controls/autoflight/autothrottle-mode');
var propLateralMode = props.globals.getNode('/controls/autoflight/lateral-mode');
var propVerticalMode = props.globals.getNode('/controls/autoflight/vertical-mode');

updateAutothrottleModeName = func () {
    var mode = propAutothrottleMode.getValue();
    var armed = nil;
    if (mode == 2) {
        armed = 0;
    }
    if (mode == 4 or mode == 5) {
        armed = 3;
    }
    var modeName = '';
    var armedName = '';
    if (mode != nil) {
        modeName = autothrottleModeNames[mode] or '???';
    }
    if (armed != nil) {
        armedName = autothrottleModeNames[armed] or '???';
    }
    setprop('/autopilot/textual/autothrottle-mode', modeName);
    setprop('/autopilot/textual/autothrottle-armed', armedName);
}

setlistener(
    '/controls/autoflight/autothrottle-mode',
    updateAutothrottleModeName,
    1, 0);

updateVerticalModeName = func (node) {
    var mode = propVerticalMode.getValue();
    var armed = nil;
    if (mode == 2 or mode == 3) {
        armed = 0;
    }
    var modeName = '';
    var armedName = '';
    if (mode != nil) {
        modeName = verticalModeNames[mode] or '???';
    }
    if (armed != nil) {
        armedName = verticalModeNames[armed] or '???';
    }
    setprop('/autopilot/textual/vertical-mode', modeName);
    setprop('/autopilot/textual/vertical-armed', armedName);
}

setlistener(
    '/controls/autoflight/vertical-mode',
    updateVerticalModeName,
    1, 0);
updateLateralModeName = func (node) {
    var mode = propLateralMode.getValue();
    var armed = nil;
    # TODO: detect armed mode
    var modeName = '';
    var armedName = '';
    if (mode != nil) {
        modeName = lateralModeNames[mode] or '???';
    }
    if (armed != nil) {
        armedName = lateralModeNames[armed] or '???';
    }
    setprop('/autopilot/textual/lateral-mode', modeName);
    setprop('/autopilot/textual/lateral-armed', armedName);
}

setlistener(
    '/controls/autoflight/lateral-mode',
    updateLateralModeName,
    1, 0);

