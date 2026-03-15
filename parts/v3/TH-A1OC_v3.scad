$fn = 15;

include <NopSCADlib/core.scad>

include <modules/screen.scad>
include <modules/keyboard.scad>
include <modules/body.scad>

//incr = -20;
incr = 0;

union() {
    color("gray") translate([0, incr*0, 0])
        Body();

    color("white") translate([0, incr*1.4, 0])
        Core();

    color("silver") translate([0, incr*3, 0])
        Frontplate();

    translate([0, incr*2.5 + BODY_T+FP_D, 0]) {
        translate([0, 0, BODY_T+CORE_T+CORE_M])
            Keyboard(BODY_W);

        translate([0, 0, BODY_H-SCR_H-BODY_T-CORE_T-CORE_M-0.9])
            Screen(BODY_W);

    }

    _Inserts();
}
