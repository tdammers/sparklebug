var pfd_display = [nil, nil];
var pfd = [nil, nil];

var lawText = [
    'DIRECT',
    'HOLD',
    'STAB',
];

var PFD = {
    new: func(canvas_group, file, index = 0) {
        var m = { parents: [PFD] };
        m.init(canvas_group, file, index);
        return m;
    },

    init: func(canvas_group, file, index) {
        var font_mapper = func(family, weight) {
            return 'LiberationFonts/LiberationMono-Regular.ttf';
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
                'wind-dir': props.globals.getNode('/environment/wind-from-heading-deg'),
                'wind-speed': props.globals.getNode('/environment/wind-speed-kt'),
                'groundspeed': props.globals.getNode('/velocities/groundspeed-kt'),
                'vs': props.globals.getNode('/instrumentation/vertical-speed-indicator/indicated-speed-fpm'),
                'bank': props.globals.getNode('/orientation/roll-deg'),
                'pitch': props.globals.getNode('/orientation/pitch-deg'),
                'fpv-v': props.globals.getNode('/instrumentation/pfd/fpv/v-deg'),
                'fpv-w': props.globals.getNode('/instrumentation/pfd/fpv/w-deg'),
                'pitch-left': props.globals.getNode('/surface-positions/left-engine-pitch-norm'),
                'pitch-right': props.globals.getNode('/surface-positions/right-engine-pitch-norm'),
            };

        me.master = canvas_group;
        canvas.parsesvg(me.master, file, {'font-mapper': font_mapper});

        var keys = [
                'horizon',
                'horizon-pitch',
                'fpv',
                'airspeed.digital',
                'altitude.digital.major',
                'altitude.digital.minor',
                'radioAlt.digital',
                'vspeed.digital.positive',
                'vspeed.digital.negative',
                'heading.digital',
                'engine.right.arrow',
                'engine.left.arrow',
                'stardrive.status',
                'pitchLaw.arrow',
                'pitchLaw.label',
                'bankLaw.arrow',
                'bankLaw.label',
                'yawLaw.arrow',
                'yawLaw.label',
            ];
        foreach (var key; keys) {
            me.elems[key] = me.master.getElementById(key);
            if (me.elems[key] == nil) {
                debug.warn('Element does not exist: ' ~ key);
            }
        }

        me.elems['horizon'].setCenter(512, 256);

        setlistener(
            '/fcs/pitch-law',
            func (law) { me.elems['pitchLaw.label'].setText(lawText[law.getValue()]); },
            1);
        setlistener(
            '/fcs/bank-law',
            func (law) { me.elems['bankLaw.label'].setText(lawText[law.getValue()]); },
            1);
        setlistener(
            '/fcs/yaw-law',
            func (law) { me.elems['yawLaw.label'].setText(lawText[law.getValue()]); },
            1);

        return me;
    },

    update: func () {
        var bank = me.props['bank'].getValue() or 0;
        var pitch = me.props['pitch'].getValue() or 0;
        var fpvV = me.props['fpv-v'].getValue() or 0;
        var fpvW = me.props['fpv-w'].getValue() or 0;
        var airspeed = me.props['ias'].getValue() or 0;
        var vspeed = me.props['vs'].getValue() or 0;
        var altitude = me.props['altitude'].getValue() or 0;
        var agl = me.props['altitude-agl'].getValue() or 0;
        var heading = me.props['heading'].getValue() or 0;

        me.elems['horizon-pitch'].setTranslation(0, pitch * 6.4);
        me.elems['horizon'].setRotation(-bank * D2R);
        me.elems['fpv'].setTranslation(fpvV * 6.4, fpvW * 6.4);
        me.elems['altitude.digital.major'].setText(sprintf('%3.0f', altitude / 100));
        if (vspeed > 1) {
            me.elems['vspeed.digital.positive'].setText(sprintf('%+04.0f', vspeed)).show();
            me.elems['vspeed.digital.negative'].hide();
        }
        else if (vspeed < -1) {
            me.elems['vspeed.digital.negative'].setText(sprintf('%+04.0f', vspeed)).show();
            me.elems['vspeed.digital.positive'].hide();
        }
        else {
            me.elems['vspeed.digital.positive'].hide();
            me.elems['vspeed.digital.negative'].hide();
        }
        me.elems['airspeed.digital'].setText(sprintf('%4.0f', airspeed));
        if (agl <= 9999) {
            me.elems['radioAlt.digital'].setText(sprintf('%4.0f', agl)).show();
        }
        else {
            me.elems['radioAlt.digital'].hide();
        }

        me.elems['heading.digital'].setText(sprintf('%03.0f', heading));

        me.elems['engine.left.arrow'].setRotation(me.props['pitch-left'].getValue() * -math.pi);
        me.elems['engine.right.arrow'].setRotation(me.props['pitch-right'].getValue() * math.pi);
    },
};

setlistener('sim/signals/fdm-initialized', func {
    for (var i = 0; i <= 0; i += 1) {
        pfd_display[i] = canvas.new({
            'name': 'PFD' ~ i,
            'size': [1024, 512],
            'view': [1024, 512],
            'mipmapping': 1
        });
        pfd_display[i].addPlacement({'node': 'PFD' ~ (i + 1)});
        pfd[i] =
            PFD.new(
                pfd_display[i].createGroup(),
                'Aircraft/sparklebug/Models/Instruments/pfd.svg',
                i);
    }

    var timer = maketimer(0.02, func() {
        pfd[0].update();
        # pfd[1].update();
    });
    timer.start();
});
