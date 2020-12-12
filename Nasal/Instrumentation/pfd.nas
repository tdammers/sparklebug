var pfd_display = [nil, nil];
var pfd = [nil, nil];

var PFD = {
    new: func(canvas_group, file, index = 0) {
        var m = { parents: [PFD] };
        m.init(canvas_group, file, index);
        return m;
    },

    init: func(canvas_group, file, index) {
        var font_mapper = func(family, weight) {
            return "LiberationFonts/LiberationMono-Regular.ttf";
        };

        var self = me; # for listeners

        me.index = index;
        me.elems = {};
        me.props = {
                'altitude-amsl': props.globals.getNode('/position/altitude-ft'),
                'altitude-agl': props.globals.getNode('/position/gear-agl-ft'),
                'altitude': props.globals.getNode('/instrumentation/altimeter/indicated-altitude-ft'),
                'heading': props.globals.getNode('/orientation/heading-deg'),
                'heading-mag': props.globals.getNode('/orientation/heading-magnetic-deg'),
                'track': props.globals.getNode('/orientation/track-deg'),
                'track-mag': props.globals.getNode('/orientation/track-magnetic-deg'),
                'tas': props.globals.getNode('/instrumentation/airspeed-indicator/true-speed-kt'),
                'ias': props.globals.getNode('/instrumentation/airspeed-indicator/indicated-speed-kt'),
                'mach': props.globals.getNode('/instrumentation/airspeed-indicator/indicated-mach'),
                'sat': props.globals.getNode('/environment/temperature-degc'),
                'tat': props.globals.getNode('/fdm/jsbsim/propulsion/tat-c'),
                'wind-dir': props.globals.getNode("/environment/wind-from-heading-deg"),
                'wind-speed': props.globals.getNode("/environment/wind-speed-kt"),
                'groundspeed': props.globals.getNode("/velocities/groundspeed-kt"),
                'vs': props.globals.getNode("/instrumentation/vertical-speed-indicator/indicated-speed-fpm"),
                'bank': props.globals.getNode("/orientation/roll-deg"),
                'pitch': props.globals.getNode("/orientation/pitch-deg"),
                'fpv-v': props.globals.getNode("/instrumentation/pfd/fpv/v-deg"),
                'fpv-w': props.globals.getNode("/instrumentation/pfd/fpv/w-deg"),
            };

        me.master = canvas_group;
        canvas.parsesvg(me.master, file, {'font-mapper': font_mapper});

        var keys = [
                'horizon',
                'horizon-pitch',
                'fpv',
            ];
        foreach (var key; keys) {
            me.elems[key] = me.master.getElementById(key);
            if (me.elems[key] == nil) {
                debug.warn("Element does not exist: " ~ key);
            }
        }

        me.elems["horizon"].setCenter(512, 256);
        return me;
    },

    update: func () {
        var bank = me.props['bank'].getValue();
        var pitch = me.props['pitch'].getValue();
        var fpvV = me.props['fpv-v'].getValue();
        var fpvW = me.props['fpv-w'].getValue();
        me.elems["horizon-pitch"].setTranslation(0, pitch * 6.4);
        me.elems["horizon"].setRotation(-bank * D2R);
        me.elems["fpv"].setTranslation(fpvV * 6.4, fpvW * 6.4);
    },
};

setlistener("sim/signals/fdm-initialized", func {
    for (var i = 0; i <= 0; i += 1) {
        pfd_display[i] = canvas.new({
            "name": "PFD" ~ i,
            "size": [1024, 512],
            "view": [1024, 512],
            "mipmapping": 1
        });
        pfd_display[i].addPlacement({"node": "PFD" ~ (i + 1)});
        pfd[i] =
            PFD.new(
                pfd_display[i].createGroup(),
                "Aircraft/sparklebug/Models/Instruments/pfd.svg",
                i);
    }

    var timer = maketimer(0.02, func() {
        pfd[0].update();
        # pfd[1].update();
    });
    timer.start();
});
