# Orbital calculations

# See
# https://space.stackexchange.com/questions/1904/how-to-programmatically-calculate-orbital-elements-using-position-velocity-vecto

var mu = 3.986004418e14;
var epsilon = 0.0000000001;

var sqr = func (a) { return a * a; }

var cross = func (a, b) {
    return [
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0],
    ]
};

var dot = func (a, b) {
    return 
        a[0] * b[0] +
        a[1] * b[1] +
        a[2] * b[2];
};

var smul = func (s, a) {
    return [
        s * a[0],
        s * a[1],
        s * a[2],
    ];
};

var vplus = func (a, b) {
    return [
        a[0] + b[0],
        a[1] + b[1],
        a[2] + b[2],
    ]
};

var vminus = func (a, b) {
    return [
        a[0] - b[0],
        a[1] - b[1],
        a[2] - b[2],
    ]
};


var magSqr = func (a) {
    return sqr(a[0]) + sqr(a[1]) + sqr(a[2]);
};

var mag = func (a) {
    return math.sqrt(magSqr(a));
};

var elementsFromState = func (r, v) {
    var h = cross(r, v);
    var dotRV = dot(r, v);
    var magH = mag(h);
    var magR = mag(r);
    var nhat = cross([0,0,1], h);
    var energy = magSqr(v) / 2 - mu / magR;
    var evec =
            smul(1.0 / mu,
                vminus(
                    smul(magSqr(v) - mu / magR, r),
                    smul(dotRV, v)
                )
            );
    var e = mag(evec);
    var p = 0;
    var a = 0; # report as -1 even though infinity would be more accurate
    if (math.abs(e - 1.0) > epsilon) {
        var a = -mu/(2.0 * energy);
        p = a * (1 - sqr(e));
    }
    else {
        p = magSqr(h) / mu;
        a = -1;
    }
    var i = (magH > epsilon) ? math.acos(h[2] / mag(h)) : 0.0;
    var cosNu = (magR > epsilon and math.abs(e) > epsilon) ? (dot(evec,r) / (magR * e)) : 0.0;
    cosNu = math.min(1, math.max(-1, cosNu));
    var nu = math.acos(cosNu);
    if (dotRV < 0) {
        nu = 2.0 * math.pi - nu;
    }
    return {
        'e': e,
        'a': a,
        'p': p,
        'i': i,
        'nu': nu,
        'h': h,
    };
};

var updateElements = func () {
    var r = [
        getprop('/position/orbit/eci-x'),
        getprop('/position/orbit/eci-y'),
        getprop('/position/orbit/eci-z'),
    ];
    var v = [
        getprop('/position/orbit/eci-vx'),
        getprop('/position/orbit/eci-vy'),
        getprop('/position/orbit/eci-vz'),
    ];
    if (r[0] == nil or r[1] == nil or r[2] == nil or v[0] == nil or v[1] == nil or v[2] == nil) {
        return;
    }
    var elements = elementsFromState(r, v);
    setprop('/position/orbit/e', elements.e);
    setprop('/position/orbit/a', elements.a);
    setprop('/position/orbit/p', elements.p);
    setprop('/position/orbit/i', elements.i);
    setprop('/position/orbit/nu', elements.nu);
    setprop('/position/orbit/h/eci-x', elements.h[0]);
    setprop('/position/orbit/h/eci-y', elements.h[1]);
    setprop('/position/orbit/h/eci-z', elements.h[2]);
};

var timer = maketimer(0.1, func { updateElements(); });
timer.start();
