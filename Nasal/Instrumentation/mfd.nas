# MFD for the Sparklebug space transport

var mfd_display = [nil, nil];
var mfd = [nil, nil];

var earthRadius = 6371000.0;

var clipElemTo = func (clippee, clipref) {
    var tranRect = clipref.getTransformedBounds();
    var clipRect = sprintf("rect(%dpx,%dpx,%dpx,%dpx)",
            tranRect[1], # 0 ys
            tranRect[2], # 1 xe
            tranRect[3], # 2 ye
            tranRect[0]); #3 xs
    # coordinates are top,right,bottom,left (ys, xe, ye, xs) ref: l621 of simgear/canvas/CanvasElement.cxx
    # debug.dump('clip', id(clippee), id(clipref), clipRect);
    clippee.set("clip", clipRect);
    clippee.set("clip-frame", canvas.Element.GLOBAL);
}

var Page = {
    new: func(canvas_group) {
        var m = { parents: [Page] };
        m.mfd = mfd;
        m.props = {};
        m.elems = {};
        m.keys = [];
        m.listeners = {};
        m.title = '-----';
        m.canvas_group = canvas_group;
        return m;
    },

    init: func() {
        foreach (var key; me.keys) {
            me.elems[key] = me.master.getElementById(key);
            if (me.elems[key] == nil) {
                debug.warn('Element does not exist: ' ~ key);
            }
            else {
                printf("%-30s | %s", key, id(me.elems[key]));
            }
        }
    },

    activate: func () {
        me.canvas_group.show();
    },

    deactivate: func () {
        me.canvas_group.hide();
    },

    update: func () {
    },
};

var OrbitPage = {
    new: func (mfd) {
        var m = Page.new(mfd);
        m.parents = [OrbitPage, Page];
        m.title = 'ORBIT';
        m.props['orbit-a'] = props.globals.getNode('/position/orbit/a');
        m.props['orbit-p'] = props.globals.getNode('/position/orbit/p');
        m.props['orbit-e'] = props.globals.getNode('/position/orbit/e');
        m.props['orbit-nu'] = props.globals.getNode('/position/orbit/nu');
        m.props['orbit-height'] = props.globals.getNode('/position/orbit/height-m');
        m.elems['viz'] = m.canvas_group
                                .createChild('group')
                                .setCenter(512, 256);
        m.elems['major-axis-marker'] = m.elems['viz']
                                .createChild('path')
                                .moveTo(256, 256)
                                .lineTo(768, 256)
                                .setColor(0, 128, 0, 1);
        m.elems['nu-pointer'] = m.elems['viz']
                                .createChild('path')
                                .moveTo(512, 256)
                                .lineTo(256, 256)
                                .setCenter(512, 256)
                                .setColor(255, 255, 0, 1);
        m.elems['karman'] = m.elems['viz']
                                .createChild('path')
                                .setColorFill(0, 255, 255, 0.5)
                                .circle(128 * (earthRadius + 100000.0) / earthRadius, 512, 256);
        m.elems['earth'] = m.elems['viz']
                                .createChild('path')
                                .setColorFill(0, 0, 64, 1)
                                .setColor(0, 0, 255, 1)
                                .circle(128, 512, 256);
        m.elems['orbit'] = m.elems['viz']
                                .createChild('path')
                                .setColor(255, 255, 0, 1);
        m.elems['apogee-digital'] = m.canvas_group
                                .createChild('text')
                                .setFont('LiberationFonts/LiberationMono-Regular.ttf')
                                .setFontSize(16, 1)
                                .setAlignment('left-bottom')
                                .setTranslation(768, 252)
                                .setColor(0, 255, 0, 1);
        m.elems['perigee-digital'] = m.canvas_group
                                .createChild('text')
                                .setFont('LiberationFonts/LiberationMono-Regular.ttf')
                                .setFontSize(16, 1)
                                .setAlignment('right-bottom')
                                .setTranslation(256, 252)
                                .setColor(0, 255, 0, 1);
        m.elems['apogee-agl-digital'] = m.canvas_group
                                .createChild('text')
                                .setFont('LiberationFonts/LiberationMono-Regular.ttf')
                                .setFontSize(16, 1)
                                .setAlignment('left-top')
                                .setTranslation(768, 260)
                                .setColor(0, 192, 0, 1);
        m.elems['perigee-agl-digital'] = m.canvas_group
                                .createChild('text')
                                .setFont('LiberationFonts/LiberationMono-Regular.ttf')
                                .setFontSize(16, 1)
                                .setAlignment('right-top')
                                .setTranslation(256, 260)
                                .setColor(0, 192, 0, 1);
        m.elems['orbital-height-digital'] = m.canvas_group
                                .createChild('text')
                                .setFont('LiberationFonts/LiberationMono-Regular.ttf')
                                .setFontSize(16, 1)
                                .setAlignment('center-bottom')
                                .setTranslation(512, 252)
                                .setColor(255, 255, 0, 1);
        m.elems['orbital-height-agl-digital'] = m.canvas_group
                                .createChild('text')
                                .setFont('LiberationFonts/LiberationMono-Regular.ttf')
                                .setFontSize(16, 1)
                                .setAlignment('center-top')
                                .setTranslation(512, 260)
                                .setColor(255, 255, 0, 1);
        return m;
    },

    update: func () {
        var a = me.props['orbit-a'].getValue();
        var p = me.props['orbit-p'].getValue();
        var e = me.props['orbit-e'].getValue();
        var nu = me.props['orbit-nu'].getValue();
        var height = me.props['orbit-height'].getValue();
        var c = a * e;
        var b = math.sqrt(a * a - c * c);
        me.elems['nu-pointer']
            .setRotation(nu);
        me.elems['orbit']
            .reset()
            .ellipse(
                a * 128 / earthRadius,
                b * 128 / earthRadius,
                512 + c * 128 / earthRadius, 
                256);
        me.elems['perigee-digital'].setText(sprintf('%6.1f', (a - c) / 1000));
        me.elems['perigee-agl-digital'].setText(sprintf('%6.1f', (a - c - earthRadius) / 1000));
        me.elems['apogee-digital'].setText(sprintf('%6.1f', (a + c) / 1000));
        me.elems['apogee-agl-digital'].setText(sprintf('%6.1f', (a + c - earthRadius) / 1000));
        me.elems['orbital-height-digital'].setText(sprintf('%6.1f', height / 1000));
        me.elems['orbital-height-agl-digital'].setText(sprintf('%6.1f', (height - earthRadius) / 1000));
    },
};

var MFD = {
    new: func(canvas_group, index = 0) {
        var m = { parents: [MFD] };
        m.pages = [];
        m.activePage = -1;
        m.init(canvas_group, index);
        return m;
    },

    setActivePage: func (i) {
        var activePage = me.pages[me.activePage];
        if (activePage != nil) activePage.deactivate();
        me.activePage = i;
        activePage = me.pages[me.activePage];
        if (activePage != nil) {
            activePage.activate();
            me.titleElem.setText(activePage.title);
        }
        else {
            me.titleElem.setText('-----');
        }
    },

    addPage: func (cls) {
        var page = cls.new(me.master.createChild('group').hide());
        page.init();
        append(me.pages, page);
    },

    init: func(canvas_group, index) {
        var font_mapper = func(family, weight) {
            return 'LiberationFonts/LiberationMono-Regular.ttf';
        };

        var self = me; # for listeners

        me.index = index;

        me.master = canvas_group;

        me.addPage(OrbitPage);
        me.titleElem =
            me.master.createChild('text')
                .setColor(0, 255, 0, 1)
                .setAlignment('center-top')
                .setFont('LiberationFonts/LiberationMono-Regular.ttf')
                .setFontSize(24, 1)
                .setTranslation(512, 8);
        me.setActivePage(0);

        return me;
    },

    update: func () {
        var activePage = me.pages[me.activePage];
        if (activePage != nil) {
            activePage.update();
        }
    }
};

setlistener('sim/signals/fdm-initialized', func {
    for (var i = 0; i <= 0; i += 1) {
        mfd_display[i] = canvas.new({
            'name': 'MFD' ~ i,
            'size': [1024, 512],
            'view': [1024, 512],
            'mipmapping': 1,
            'coverage-samples': 4,
        });
        mfd_display[i].addPlacement({'node': 'MFD' ~ (i + 1)});
        mfd[i] = MFD.new(mfd_display[i].createGroup(), i);
    }

    var timer = maketimer(0.02, func() {
        mfd[0].update();
        # mfd[1].update();
    });
    timer.start();
});

