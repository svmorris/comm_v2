include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/d_connectors.scad>
include <NopSCADlib/vitamins/pcbs.scad>
include <NopSCADlib/vitamins/rockers.scad>
include <NopSCADlib/vitamins/rocker.scad>
include <NopSCADlib/utils/core/rounded_rectangle.scad>

include <fw_expansion_card.scad>

e = $preview ? 0.01 : 0;

$fn = $preview ? 6 : 30;

MODULE_MARGIN = 5;
MODULE_W = 90;

KB_ROWS = 5;
KB_COLS = 12;
KB_H = 40;
KB_D = 10;

KB_BTN = button_6mm;
KB_KEY_W = KB_BTN[1];
KB_KEY_H = KB_BTN[2];
KB_KEY_D = 4;
KB_GAP_X = (
    (MODULE_W-2*MODULE_MARGIN-(KB_COLS-1)*KB_KEY_W)
    / (KB_COLS-1)
);

KB_GAP_Y = (
    (KB_H-2*MODULE_MARGIN-(KB_ROWS)*KB_KEY_H)
    / (KB_ROWS-1)
);

KB_MK_W = 7;
KB_MK_H = 5;
KB_MK_COUNT = 6;

KB_MACRO_H = KB_MK_H + MODULE_MARGIN;
KB_MACRO_GAP = (
    (MODULE_W-2*MODULE_MARGIN-(KB_MK_COUNT-1)*KB_MK_W)
    / (KB_MK_COUNT-1)
);

KB_H_TOTAL = KB_H + KB_MK_H;

module Keyboard(cutout=false) {
    w_incr = KB_GAP_X+KB_KEY_W;
    h_incr = KB_GAP_Y+KB_KEY_H;

    color("black")
        translate([0, 0, 0])
        cube([MODULE_W, KB_D, KB_H+KB_MK_H]);
    
    color("gray")
        translate([MODULE_MARGIN, 0, MODULE_MARGIN])
        for (row = [0:KB_ROWS-1]) {
            for (col = [0:KB_COLS-1]) {
                translate([col*w_incr, 0, row*h_incr]) rotate([90, 0, 0]) {
                    if (row == 0 && 3 < col && col < 8) {
                        if (col == 5) translate([(w_incr)/2, 0, 0])
                            square_button(KB_BTN);
                    } else {
                        square_button(KB_BTN);
                    }
                }
            }
        }
    
    color("gray")
        translate([MODULE_MARGIN, 0, MODULE_MARGIN])
        for (col = [0:KB_MK_COUNT-1]) {
            translate([
                col*(KB_MACRO_GAP+KB_MK_W),
                0,
                KB_H - MODULE_MARGIN
            ])
                rotate([90, 0, 0])
                    square_button(KB_BTN);
        }
}

SCR_W = 67.25;
SCR_H = 79.874;
SCR_D = 0.7;

SCR_BEZEL_L = SCR_W * 0.05;
SCR_BEZEL_R = SCR_W * 0.05;
SCR_BEZEL_X = SCR_BEZEL_L + SCR_BEZEL_R;
SCR_BEZEL_T = SCR_H * 0.08;
SCR_BEZEL_B = SCR_H * 0.12;
SCR_BEZEL_Y = SCR_BEZEL_T + SCR_BEZEL_B;

SCR_H_TOTAL = SCR_H;

module Screen() {
    // https://aliexpress.com/item/1005006168560918.html
    translate([0, 0, 0]) {
        difference() {
            color("gray") cube([SCR_W, SCR_D, SCR_H]);
            translate([SCR_BEZEL_L, -1, SCR_BEZEL_B])
                cube([SCR_W-SCR_BEZEL_X, SCR_D+2, SCR_H-SCR_BEZEL_Y]);
        }
        color("black")
            translate([SCR_BEZEL_L, 0, SCR_BEZEL_B])
            cube([SCR_W-SCR_BEZEL_X, SCR_D, SCR_H-SCR_BEZEL_Y]);
    }
}

SPK_MARGIN = 0;
SPK_W = MODULE_W - SCR_W - SPK_MARGIN - SCR_BEZEL_X;
SPK_H = SCR_H - SCR_BEZEL_Y;

module Speaker() {
    hole_d = 2;
    spacing = 3.5;
    margin = 2;

    cols = floor((SPK_W - 2*margin) / spacing) + 1;
    rows = floor((SPK_H - 2*margin) / spacing) + 1;

    x_offset = (SPK_W - (cols-1)*spacing) / 2;
    z_offset = (SPK_H - (rows-1)*spacing) / 2;

    difference() {
        color("silver") cube([SPK_W, 5, SPK_H]);
        for (row = [0:rows-1]) {
            for (col = [0:cols-1]) {
                translate([x_offset + col*spacing, -1, z_offset + row*spacing])
                    rotate([-90, 0, 0])
                    cylinder(d=hole_d, h=7);
            }
        }
    }
}

CASE_THICKNESS = 3;
CASE_RADIUS = 4;
CASE_H = 2*MODULE_MARGIN+2*CASE_THICKNESS+KB_H_TOTAL+SCR_H_TOTAL;
CASE_W = 2*MODULE_MARGIN+MODULE_W+2*CASE_THICKNESS;
CASE_D = 23;

INR_W = CASE_W-CASE_THICKNESS*2+e;
INR_D = CASE_D+e;
INR_H = CASE_H-CASE_THICKNESS*2+e;

module Case(hollow=true) {
    difference() {
        rounded_cube_xy([CASE_W, CASE_D, CASE_H], CASE_RADIUS);
        translate([CASE_THICKNESS+e, 0, CASE_THICKNESS+e]) {
            translate([0, -1, 0]) cube([
                MODULE_W+2*MODULE_MARGIN+e,
                FPT_D+1+e,
                KB_H_TOTAL+SCR_H_TOTAL+2*MODULE_MARGIN+e
            ]);
            if (hollow)
                translate([0, -FPT_D, 0]) cube([INR_W, INR_D, INR_H]);
        }
    }
}

FPT_D = 1.5;

module Frontplate() {
    r = CASE_RADIUS-CASE_THICKNESS;
    cut_depth = FPT_D+2;

    difference() {
        translate([1, 0, 1])
        cube([
            MODULE_W+2*MODULE_MARGIN-2,
            FPT_D+e,
            KB_H_TOTAL+SCR_H_TOTAL+2*MODULE_MARGIN-2
        ]);

        x = MODULE_MARGIN;
        y = MODULE_MARGIN;

        translate([0, -1, 0]) {
            translate([x, 0, y])
                cube([MODULE_W, cut_depth, KB_H_TOTAL]);

            // Screen
            let(x = x+SCR_BEZEL_L)
            let(y = y+KB_H_TOTAL+SCR_BEZEL_B) {
                translate([x, e, y])
                cube([SCR_W-SCR_BEZEL_X, cut_depth, SCR_H-SCR_BEZEL_Y]);

            // Indicator
            let(x = x+SCR_W+SPK_MARGIN) {
                translate([x, 0, y])
                cube([SPK_W, cut_depth, SPK_H]);
            }}
        }
    }
}

FWB_D = fw_exp[2]+2;
FWB_INSET = 1;

module ExpansionBay(cutout=false) {
    count = 2;
    gap = 10;
    w = CASE_W-2*CASE_THICKNESS;
    space = w - count*fw_exp[0] - (count-1)*gap;

    translate([CASE_THICKNESS, FWB_D+FPT_D+KB_D+2-FWB_INSET, 0])
    difference() {
        if (!cutout) {
            translate([0, -FWB_D, 0])
                cube([w, FWB_D+FWB_INSET, fw_exp[1]+1]);
        }

        for (i = [0:count-1]) {
            translate([space/2+(gap+fw_exp[0])*i, 0, 0]) {
                translate([0, 1+FWB_INSET, -e])
                    rotate([90, 0, 0])
                        cube([fw_exp[0], fw_exp[1], fw_exp[2]+FWB_INSET]);

                translate([0, 1, -e])
                    rotate([90, 0, 0])
                        translate([fw_exp[0]/2, fw_exp[1], usb_c_r + usb_c_h])
                            usb_c_cutout(false);
            }
        }
    }
}

module Externals(cutout=false) {
    translate([CASE_W/2 - 4, CASE_D/2, CASE_H-8])
        rotate([0, 90, 0])
        mirror([1, 0, 0])
        jack(cutout=cutout);

    translate([3.6, (CASE_D-3.26)/2, 125])
        mirror([1, 0, 0])
        rotate([-90, 0, 0])
        usb_C(cutout=cutout);

    *translate([CASE_THICKNESS+MODULE_MARGIN-1, FPT_D, CASE_THICKNESS+MODULE_MARGIN-1]) color("green") {
        translate([0, KB_D, 0]) cube([MODULE_W+2, 2, 65]);
        translate([0, SCR_D, 60]) cube([MODULE_W+2, 10, 60]);
    }
        
    translate([0, CASE_D/2-e, 85])
        mirror([1, 0, 0])
        rotate([0, 90, 0])
        d_socket(DCONN25, pcb=true);

    translate([CASE_W-18, CASE_D/2, CASE_H+e])
        rotate([0, 0, 90])
        rocker(micro_rocker, colour="green");

    translate([CASE_W-38, CASE_D/2, CASE_H+e])
        rotate([0, 0, 90])
        rocker(micro_rocker);

    translate([CASE_W-8, (CASE_D-3)/2, 65])
        color("silver") cube([8+e, 3, 60]);

    translate([CASE_W-1, 11.5, 80+e])
        rotate([0, 90, 0])
        cylinder(2, 1.5, 1.5);
}

CORE_THICKNESS = 0.5;
CORE_MARGIN = 0.1;

module Internals(cutout=false) {
    core_d = CASE_D - FPT_D - 2*CORE_MARGIN;
    w = CASE_W-2*CASE_THICKNESS-2*CORE_MARGIN;

    translate([CASE_THICKNESS+CORE_MARGIN, CORE_MARGIN, CASE_THICKNESS+CORE_MARGIN]) {
        translate([0, CASE_D-FWB_D-CORE_MARGIN-CASE_THICKNESS, 0])
            cube([w, FWB_D+FWB_INSET, fw_exp[1]+1]);

        difference() {
            cube([INR_W-CORE_MARGIN*2, core_d, INR_H-CORE_MARGIN*2]);
            translate([CORE_THICKNESS, -e, CORE_THICKNESS])
                cube([
                    INR_W-2*CORE_THICKNESS-CORE_MARGIN*2,
                    core_d-CORE_THICKNESS+e,
                    INR_H-2*CORE_THICKNESS-CORE_MARGIN*2,
                ]);
        }
    }

    
}

/*

*/
