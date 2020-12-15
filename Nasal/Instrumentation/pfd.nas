# PFD for the Sparklebug space transport

var pfd_display = [nil, nil];
var pfd = [nil, nil];

var clipElemTo = func (clippee, clipref) {
    var tranRect = clipref.getTransformedBounds();
    var clipRect = sprintf("rect(%dpx,%dpx,%dpx,%dpx)",
            tranRect[1], # 0 ys
            tranRect[2], # 1 xe
            tranRect[3], # 2 ye
            tranRect[0]); #3 xs
    # coordinates are top,right,bottom,left (ys, xe, ye, xs) ref: l621 of simgear/canvas/CanvasElement.cxx
    debug.dump('clip', id(clippee), id(clipref), clipRect);
    clippee.set("clip", clipRect);
    clippee.set("clip-frame", canvas.Element.GLOBAL);
}

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
                'orbitalv': props.globals.getNode('/instrumentation/pfd/orbitalv-kms'),
                'sat': props.globals.getNode('/environment/temperature-degc'),
                'tat': props.globals.getNode('/fdm/jsbsim/propulsion/tat-c'),
                'wind-dir': props.globals.getNode('/environment/wind-from-heading-deg'),
                'wind-speed': props.globals.getNode('/environment/wind-speed-kt'),
                'groundspeed': props.globals.getNode('/velocities/groundspeed-kt'),
                'vs': props.globals.getNode('/instrumentation/pfd/vs-fpm'),
                'vs-needle': props.globals.getNode('/instrumentation/pfd/vs-needle-deg'),
                'bank': props.globals.getNode('/orientation/roll-deg'),
                'pitch': props.globals.getNode('/orientation/pitch-deg'),
                'fpv-v': props.globals.getNode('/instrumentation/pfd/fpv/v-deg'),
                'fpv-w': props.globals.getNode('/instrumentation/pfd/fpv/w-deg'),
                'gs-u': props.globals.getNode('/instrumentation/pfd/ground-track/u'),
                'gs-v': props.globals.getNode('/instrumentation/pfd/ground-track/v'),
                'pitch-left': props.globals.getNode('/surface-positions/left-engine-pitch-norm'),
                'pitch-right': props.globals.getNode('/surface-positions/right-engine-pitch-norm'),
                'gear-status-0': props.globals.getNode('/instrumentation/pfd/gear-status[0]'),
                'gear-status-1': props.globals.getNode('/instrumentation/pfd/gear-status[1]'),
                'gear-status-2': props.globals.getNode('/instrumentation/pfd/gear-status[2]'),
                'gear-status-3': props.globals.getNode('/instrumentation/pfd/gear-status[2]'),

                'n1-0': props.globals.getNode('/engines/engine[0]/n1'),
                'n2-0': props.globals.getNode('/engines/engine[0]/n2'),
                'cutoff-0': props.globals.getNode('/engines/engine[0]/cutoff'),
                'augment-0': props.globals.getNode('/engines/engine[0]/augmentation'),
                'n1-1': props.globals.getNode('/engines/engine[1]/n1'),
                'n2-1': props.globals.getNode('/engines/engine[1]/n2'),
                'cutoff-1': props.globals.getNode('/engines/engine[1]/cutoff'),
                'augment-1': props.globals.getNode('/engines/engine[1]/augmentation'),
            };

        me.master = canvas_group;
        canvas.parsesvg(me.master, file, {'font-mapper': font_mapper});

        var keys = [
                'horizon',
                'horizon-pitch',
                'fpv',
                'airspeed.digital',
                'airspeed.knots.tape',
                'airspeed.bug',
                'airspeed.selected.digital',
                'orbitalv.digital',
                'mach.digital',
                'altitude.digital.major',
                'altitude.digital.minor',
                'altitude.tape',
                'altitude.tape.current',
                'altitude.tape.next',
                'altitude.bug',
                'altitude.selected.digital',
                'radioAlt.digital',
                'vspeed.digital.positive',
                'vspeed.digital.negative',
                'vsi.needle',
                'vsi.scale',
                'vs.bug',
                'vs.selected.digital',
                'heading.digital',
                'heading.tape',
                'heading.bug',
                'engine.right.arrow',
                'engine.left.arrow',
                'stardrive.status',
                'pitchLaw.arrow',
                'pitchLaw.label',
                'bankLaw.arrow',
                'bankLaw.label',
                'yawLaw.arrow',
                'yawLaw.label',
                'gear.0.indicator',
                'gear.1.indicator',
                'gear.2.indicator',
                'gear.3.indicator',
                'clip.speedtape',
                'clip.alttape',
                'clip.headingtape',
                'clip.hsi',
                'clip.vsi',
                'hsi.compass',
                'hsi.groundspeed.track',
                'hsi.groundspeed-u.line',
                'hsi.groundspeed-u.excess-pos',
                'hsi.groundspeed-u.excess-neg',
                'hsi.groundspeed-u.line',
                'hsi.groundspeed-v.line',
                'hsi.groundspeed-v.excess-pos',
                'hsi.groundspeed-v.excess-neg',
                'engine0.n1.pointer',
                'engine0.n1.digital',
                'engine0.n2.digital',
                'engine0.off',
                'engine0.augment',
                'engine1.n1.pointer',
                'engine1.n1.digital',
                'engine1.n2.digital',
                'engine1.off',
                'engine1.augment',
            ];
        foreach (var key; keys) {
            me.elems[key] = me.master.getElementById(key);
            if (me.elems[key] == nil) {
                debug.warn('Element does not exist: ' ~ key);
            }
            else {
                printf("%-30s | %s", key, id(me.elems[key]));
            }
        }

        clipElemTo(
            me.elems['altitude.tape'],
            me.elems['clip.alttape']);
        clipElemTo(
            me.elems['heading.tape'],
            me.elems['clip.headingtape']);
        clipElemTo(
            me.elems['airspeed.knots.tape'],
            me.elems['clip.speedtape']);
        clipElemTo(
            me.elems['hsi.groundspeed-u.line'],
            me.elems['clip.hsi']);
        clipElemTo(
            me.elems['hsi.groundspeed-v.line'],
            me.elems['clip.hsi']);
        clipElemTo(
            me.elems['vsi.scale'],
            me.elems['clip.vsi']);
        clipElemTo(
            me.elems['vsi.needle'],
            me.elems['clip.vsi']);

        me.elems['clip.speedtape'].setColorFill(0, 0, 0, 0);
        me.elems['clip.alttape'].setColorFill(0, 0, 0, 0);
        me.elems['clip.headingtape'].setColorFill(0, 0, 0, 0);
        me.elems['clip.hsi'].setColorFill(0, 0, 0, 0);
        me.elems['clip.vsi'].setColorFill(0, 0, 0, 0);

        me.elems['horizon'].setCenter(512, 256);

        setlistener(
            '/fcs/pitch-law',
            func (law) { me.elems['pitchLaw.label'].setText(lawText[law.getValue()]); },
            1, 0);
        setlistener(
            '/fcs/bank-law',
            func (law) { me.elems['bankLaw.label'].setText(lawText[law.getValue()]); },
            1, 0);
        setlistener(
            '/fcs/yaw-law',
            func (law) { me.elems['yawLaw.label'].setText(lawText[law.getValue()]); },
            1, 0);
        setlistener(
            '/instrumentation/pfd/alttape/current-major',
            func (node) {
                var value = node.getValue();
                me.elems['altitude.tape.current'].setText(sprintf("%4.0f", value));
                me.elems['altitude.tape.next'].setText(sprintf("%4.0f", value + 10));
            },
            1, 0);
        setlistener(
            '/instrumentation/pfd/alttape/offset-ft',
            func (node) {
                var value = node.getValue();
                me.elems['altitude.tape'].setTranslation(0, value * 0.32);
            },
            1, 0);

        setlistener(
            '/controls/autoflight/altitude-select',
            func (node) {
                var value = node.getValue();
                me.elems['altitude.bug'].setTranslation(0, value * -0.32);
                me.elems['altitude.selected.digital'].setText(sprintf("%6.0f", value));
            },
            1, 0);
        setlistener(
            '/controls/autoflight/speed-select',
            func (node) {
                var value = node.getValue();
                me.elems['airspeed.bug'].setTranslation(0, value * -1.6);
                me.elems['airspeed.selected.digital'].setText(sprintf("%3.0f", value));
            },
            1, 0);
        setlistener(
            '/controls/autoflight/heading-select',
            func (node) {
                var value = math.periodic(0, 360, node.getValue() or 0);
                me.elems['heading.bug'].setTranslation(value * 6.4, 0);
                # me.elems['heading.selected.digital'].setText(sprintf("%3.0f", value));
            },
            1, 0);
        setlistener(
            '/controls/autoflight/vertical-speed-select',
            func (node) {
                var value = node.getValue();
                me.elems['vs.bug'].hide();
                me.elems['vs.selected.digital'].setText(sprintf("%+4.0f", value));
            },
            1, 0);

        setlistener(
            me.props['cutoff-0'],
            func (node) {
                var visible = node.getBoolValue();
                me.elems['engine0.off'].setVisible(visible);
            },
            1, 0);
        setlistener(
            me.props['augment-0'],
            func (node) {
                var visible = node.getBoolValue();
                me.elems['engine0.augment'].setVisible(visible);
            },
            1, 0);
        setlistener(
            me.props['cutoff-1'],
            func (node) {
                var visible = node.getBoolValue();
                me.elems['engine1.off'].setVisible(visible);
            },
            1, 0);
        setlistener(
            me.props['augment-1'],
            func (node) {
                var visible = node.getBoolValue();
                me.elems['engine1.augment'].setVisible(visible);
            },
            1, 0);

        for (var i = 0; i < 4; i = i + 1) {
            (func (i) {
                var elem = me.elems['gear.' ~ i ~ '.indicator'];
                setlistener(
                    '/instrumentation/pfd/gear-status[' ~ i ~ ']',
                    func (n) {
                        var status = n.getValue();
                        if (status == 0) {
                            elem.hide();
                        }
                        else if (status == 1) {
                            elem.setColorFill(255, 255, 0, 128)
                                .setColor(255, 255, 0, 255)
                                .show();
                        }
                        else if (status == 2) {
                            elem.setColorFill(0, 255, 0, 128)
                                .setColor(0, 255, 0, 255)
                                .show();
                        }
                        else {
                            elem.setColorFill(255, 0, 0, 128)
                                .setColor(255, 0, 0, 255)
                                .show();
                        }
                    },
                    1, 0);
            })(i);
        }

        return me;
    },

    update: func () {
        var bank = me.props['bank'].getValue() or 0;
        var pitch = me.props['pitch'].getValue() or 0;
        var fpvV = me.props['fpv-v'].getValue() or 0;
        var fpvW = me.props['fpv-w'].getValue() or 0;
        var gsU = me.props['gs-u'].getValue() or 0;
        var gsV = me.props['gs-v'].getValue() or 0;
        var airspeed = me.props['ias'].getValue() or 0;
        var groundspeed = me.props['groundspeed'].getValue() or 0;
        var orbitalv = me.props['orbitalv'].getValue() or 0;
        var mach = me.props['mach'].getValue() or 0;
        var vspeed = me.props['vs'].getValue() or 0;
        var vsNeedleDeg = me.props['vs-needle'].getValue() or 0;
        var altitude = me.props['altitude'].getValue() or 0;
        var agl = me.props['altitude-agl'].getValue() or 0;
        var heading = me.props['heading'].getValue() or 0;
        var track = me.props['track'].getValue() or 0;

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
        me.elems['vsi.needle'].setRotation(vsNeedleDeg * D2R);
        if (agl <= 9999) {
            me.elems['radioAlt.digital'].setText(sprintf('%4.0f', agl)).show();
        }
        else {
            me.elems['radioAlt.digital'].hide();
        }
        me.elems['airspeed.digital'].setText(sprintf('%4.0f', airspeed));
        me.elems['airspeed.knots.tape'].setTranslation(0, airspeed * 1.6);
        me.elems['orbitalv.digital'].setText(sprintf('%5.2f', orbitalv));
        var ovdX = math.min(168, math.max(-168, fpvV * 6.4));
        var ovdY = math.min(186, math.max(-186, fpvW * 6.4 - 16));
        me.elems['orbitalv.digital'].setTranslation(ovdX, ovdY);
        me.elems['mach.digital'].setText(sprintf('%5.2fM', mach));

        me.elems['hsi.groundspeed-u.line'].setTranslation(0, gsU * -3.2)
                                          .setVisible(math.abs(groundspeed) < 50);
        me.elems['hsi.groundspeed-v.line'].setTranslation(gsV * 3.2, 0)
                                          .setVisible(math.abs(groundspeed) < 50);
        me.elems['hsi.groundspeed-u.excess-pos'].setVisible(gsU >= 20.0);
        me.elems['hsi.groundspeed-u.excess-neg'].setVisible(gsU <= -20.0);
        me.elems['hsi.groundspeed-v.excess-pos'].setVisible(gsV >= 20.0);
        me.elems['hsi.groundspeed-v.excess-neg'].setVisible(gsV <= -20.0);

        me.elems['heading.digital'].setText(sprintf('%03.0f', heading));
        me.elems['heading.tape'].setTranslation(math.periodic(-180, 180, heading) * -6.4, 0);
        me.elems['hsi.compass'].setRotation(-heading * D2R);
        me.elems['hsi.groundspeed.track'].setRotation((track-heading) * D2R)
                                         .setVisible(math.abs(groundspeed) > 1);

        me.elems['engine.left.arrow'].setRotation((me.props['pitch-left'].getValue() or 0) * -math.pi);
        me.elems['engine.right.arrow'].setRotation((me.props['pitch-right'].getValue() or 0) * math.pi);

        for (var i = 0; i < 2; i += 1) {
            var n1 = me.props['n1-' ~ i].getValue();
            var n2 = me.props['n2-' ~ i].getValue();
            me.elems['engine' ~ i ~ '.n1.pointer'].setRotation(n1 * 270 / 100 * D2R);
            me.elems['engine' ~ i ~ '.n1.digital'].setText(sprintf('%3.0f', n1));
            me.elems['engine' ~ i ~ '.n2.digital'].setText(sprintf('%3.0f', n2));
        }
    },
};

setlistener('sim/signals/fdm-initialized', func {
    for (var i = 0; i <= 0; i += 1) {
        pfd_display[i] = canvas.new({
            'name': 'PFD' ~ i,
            'size': [1024, 512],
            'view': [1024, 512],
            'mipmapping': 1,
            'coverage-samples': 4,
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
