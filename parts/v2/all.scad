include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/pcbs.scad>
include <NopSCADlib/vitamins/rockers.scad>
include <NopSCADlib/vitamins/rocker.scad>

include <modules/screen.scad>
include <modules/keyboard.scad>
include <modules/framework.scad>
include <modules/pins.scad>

// TODO: Pass avail width to modules and let them center themselves

MARGIN = 2.5;
CASE = 1.5;
RADIUS = 3;

FP_DEPTH = 1;

INNER_WIDTH = 81.674+2*MARGIN;
INNER_HEIGHT = 122+2*MARGIN;

FP_WIDTH = INNER_WIDTH;
FP_HEIGHT = INNER_HEIGHT;

WIDTH = FP_WIDTH;
HEIGHT = FP_HEIGHT;
DEPTH = 20;

FW_MARGIN = 8;

module FrameworkGrid() {
    translate([MARGIN + FW_MARGIN, DEPTH - 1, 1]) {
        Grid(
            grid = [2, 1],
            size = [fw_exp[0], fw_exp[2]],
            space = [INNER_WIDTH - 2*(MARGIN + FW_MARGIN), INNER_HEIGHT]
        ) {
            children();
        }
    }
}

module _assembly(cutout) {
    translate([MARGIN, 0, MARGIN]) {
        Keyboard(cutout=cutout);
        translate([0, 0, KB_HEIGHT])
            Screen(cutout=cutout);
    }
}

module Frontplate(cutout=false) {
    color("silver") difference() {
        rounded_cube_xz([WIDTH, FP_DEPTH+(cutout ? 10 : 0)-e, HEIGHT], RADIUS);
        translate([0, FP_DEPTH+e, 0]) _assembly(cutout=true);
    }
}

module Inserts(cutout=false) {
    depth = 18;
    b_cutout = cutout ? 1 : 0;

    // NopSCADlib connector dimensions
    jack_d = 6;
    jack_h = 6;
    usbc_w = 8.94;
    usbc_h = 3.26;

    // Center both ports at the same height on the back wall
    port_z = HEIGHT - CASE - usbc_w/2 - 1;

    translate([0, DEPTH, HEIGHT*0.85])
        Pins(cutout=cutout);

    if (cutout) {
        translate([FW_MARGIN, depth/2, port_z])
            mirror([0, 0, b_cutout])
            rotate([0, 90, 90])
            jack(cutout=cutout);

        translate([FW_MARGIN + jack_d + 4, depth/2, port_z])
            mirror([0, 0, b_cutout])
            rotate([0, 90, 90])
            usb_C(cutout=cutout);
    }

    translate([WIDTH-FW_MARGIN-8, depth/2, HEIGHT])
        rotate([0, 0, 90])
        rocker(micro_rocker, colour="green");

    *FrameworkGrid() {
        color("silver") FrameworkExpansion();
    }
}

module SpeakerCutout(filled=false) {
    length = 4;
    width = 1;
 

    render() translate([-e, 4, HEIGHT*0.51]) rotate([0, 0, 90]) {
        if (filled) {
            mirror([0, 1, 0]) cube([DEPTH/2, 5, HEIGHT*0.35]);
        } else {
            Grid([6, 10], [1, 1], [DEPTH/2, HEIGHT*0.35]) {
                mirror([0, 1, 0]) cube([width, 5, length]);
            }
        }
    }

    render() translate([WIDTH+e, DEPTH/2-6, HEIGHT*0.51]) rotate([0, 0, 90]) {
        if (filled) {
            cube([DEPTH/2, 5, HEIGHT*0.35]);
        } else {
            Grid([6, 10], [1, 1], [DEPTH/2, HEIGHT*0.35]) {
                cube([width, 5, length]);
            }
        }
    }
}

module Core(cutout=false) {
    CORE = 1;
    CORE_MARGIN = 0.2;

    width = WIDTH-2*CASE;
    height = HEIGHT-2*CASE;
    depth = DEPTH-CASE;

    if (cutout) {
        translate([CASE, -RADIUS, CASE])
            Rounded([width, DEPTH+RADIUS-CASE, height], RADIUS-CASE);
    } else {
        let (width = width-CORE_MARGIN*2)
        let (height = height-CORE_MARGIN*2)
        union() {
            render() difference() {
                translate([CASE+CORE_MARGIN, FP_DEPTH+e, CASE+CORE_MARGIN]) union() {
                    Rounded([width, depth-FP_DEPTH, height], RADIUS-CASE-CORE_MARGIN);
                    rounded_cube_xz([width, RADIUS, height], RADIUS-CASE-CORE_MARGIN);
                }

                translate([CASE+CORE_MARGIN+CORE, 0, CASE+CORE_MARGIN+CORE])
                    cube([
                        width-2*CORE,
                        depth-CORE,
                        height-2*CORE
                    ]);

                Inserts(cutout=true);
                SpeakerCutout(filled=true);
                FrameworkGrid() { FrameworkVolume(); }
            }

            render() difference() {
                intersection() {
                    translate([CASE+CORE_MARGIN, FP_DEPTH, CASE+CORE_MARGIN])
                        Rounded([width, depth-FP_DEPTH, height], RADIUS-CASE-CORE_MARGIN);

                    translate([0, DEPTH-2, 0])
                        mirror([0, 1, 0])
                        cube([WIDTH, fw_exp[2]+1, fw_exp[1]+2]);
                }

                FrameworkGrid() { FrameworkVolume(); }
            }
        }
    }
}

module Shell() {
    color("white") render() difference() {
            translate([0, -RADIUS, 0])
            Rounded([WIDTH, DEPTH+RADIUS, HEIGHT], RADIUS);

        Core(cutout=true);

        translate([0, -10+e, 0])
            cube([FP_WIDTH+e, 10+FP_DEPTH, FP_HEIGHT+e]);

        FrameworkGrid() { FrameworkVolume(); }

        Inserts(cutout=true);
        SpeakerCutout();
    }
}

union() {
    Shell();
    Core();

    union() {
        *Inserts();
        Frontplate();

        *translate([0, FP_DEPTH, 0])
            _assembly(cutout=false);
    }
}
