// Resolution for milling:
$fa            = 1;    // Minimum angle
$fs            = 0.1;  // Minimum size
delta          = 0.001;

a_step         =  1; // Resolution for circle
knob_radius    = 10;   //
knob_height    = 18;
knob_scale     =  0.85;
knob_fluting   =  0.4;
n_flutes       = 20;
arrow_x        =  2.5;
arrow_y        =  1.5;
arrow_base     =  2;
h_r1           =  6.1; // Höhe unterer Ring
d_r1           = 14.2; // Durchmesser unterer Ring
h_r2           =  4.0; // Höhe mittlerer Ring
d_r2           =  8.2; // Durchmesser mittlerer Ring
d_r3           = 12.2; // Durchmesser oberer Ring
h_r4           =  0.2; // Höhe der Einrückung oben
d_r4           = 15.0; // Durchmesser der Einrückung
rounding       =  1.0; // Abrundung oben

function f_x(x, a) = x + cos(a) 
                     * (knob_fluting * cos(a*n_flutes));

function f_y(x, a) = x + sin(a) 
                     * (knob_fluting * cos(a*n_flutes));

module knob_shape(order = 360 / a_step, r = knob_radius)
{
    angles=[ for (i = [0:order-1]) i*(360/order) ];
    coords=[ for (th=angles) [
        f_x(r*cos(th), th), 
        f_y(r*sin(th), th)
    ]];
    polygon(coords);
    // Pfeil:
    translate([knob_radius-0.5, 0])
    {
        polygon(points = [
            [-arrow_base,          -arrow_y],
            [0,                    -arrow_y],
            [arrow_x,               0      ],
            [0,                     arrow_y],
            [-arrow_base,           arrow_y]
        ]);
    }    
}

module knob_base()
{
    linear_extrude(height = knob_height, 
                    scale = knob_scale)
    {
        knob_shape();
    };
}

module knob_unsmooth() {
    difference() {
        knob_base();
        translate([0, 0, -delta])
        {
            // Durchgehendes Loch (Mittlerer Ring):
            cylinder(r = d_r2/2, h = 50);
            // Unterer Ring:
            cylinder(r = d_r1/2, h = h_r1 + delta);
            // Oberer Ring:
            translate([0, 0, h_r1 + h_r2 + delta])
                cylinder(r = d_r3/2, h = 10);
            // Einrückung oben:
            translate([0, 0, knob_height - h_r4 + delta])
                cylinder(r = d_r4/2, h = 10);
        }
    }
}

module smooth()
{
    translate([0, 0, knob_height - rounding])
        difference() {
            cylinder(h = knob_radius / 2,
                     r = knob_radius + arrow_y + 5);
            translate([0, 0, -delta])
                scale([1, 1, rounding / knob_radius])
                    sphere(r = knob_radius * knob_scale 
                           + knob_fluting * knob_scale);
    }
}

module knob()
{
    difference() {
        knob_unsmooth();
        smooth();
    }
}

knob();
//knob_shape();
//smooth();
