$fn=75;

card_width = 54;
card_length = 85;

lip_thickness = .2;
card_thickness = lip_thickness + 3;

long_edge_thickness = 1;
short_edge_thickness = 2;

// https://economy-finance.ec.europa.eu/euro/euro-coins-and-notes/euro-coins/common-sides-euro-coins_en
one_euro = 23.25;
two_euro = 25.75;
fifty_cent = 24.25;

finger_hole_dia = 14;
offset_finger_hole_lip = 1;

coins = [two_euro,   fifty_cent,
         two_euro,   one_euro,
         two_euro,   one_euro];

diameter_sums_1 = [ for (j=len(coins)-1, d=coins[j]; j>-1; j=j-2, d=d+(coins[j]==undef?0:coins[j])) d];
diameter_sums_2 = [ for (j=len(coins)-2, d=coins[j]; j>-1; j=j-2, d=d+(coins[j]==undef?0:coins[j])) d];
diameter_sum_1 = diameter_sums_1[len(diameter_sums_1)-1];
diameter_sum_2 = diameter_sums_2[len(diameter_sums_2)-1];
inter_hole_spacing_1 = (card_length-diameter_sum_1-2*short_edge_thickness)/2;
inter_hole_spacing_2 = (card_length-diameter_sum_2-2*short_edge_thickness)/2;

inter_hole_spacings = [inter_hole_spacing_1, inter_hole_spacing_2];

module base(thickness=4, rounding=3.18) {
    translate([rounding,rounding,0])
    minkowski() {
        cube([card_length-rounding*2, card_width-rounding*2, thickness/2]);
        cylinder(r=rounding, h=thickness/2);
    }
}

module coin(dia, thickness=4, rot=45) {
    h=lip_thickness;
    // translate([short_edge_thickness,-card_width/2+dia/2+long_edge_thickness,0])
    translate([short_edge_thickness,-card_width/4,0])
        translate([dia/2,0,0]) {
            translate([0,0,h])
                cylinder(r=dia/2, h=thickness-h);
            finger_hole_dia = min(finger_hole_dia, dia-2);
            cylinder(r=finger_hole_dia/2, h=thickness);
            rotate([0,0,rot])
                translate([dia/2-5,0,h+offset_finger_hole_lip])
                    cylinder(r=finger_hole_dia/2, h=thickness-(h+offset_finger_hole_lip));
        }
}


module just_coins() {
    difference(){
        base();
        translate([0,card_width/2,0]) {

            for (i = [0:len(coins)-1]) {
                if (i < 2) {
                    mirror([0,i%2,0]) coin(coins[i]);
                } else {
                    distances = [ for (j=i-2, d=coins[j]; j>-1; j=j-2, d=d+(coins[j]==undef?0:coins[j])) d];
                    distance = distances[len(distances)-1];
                    echo("distance", distance);

                    translate([distance+inter_hole_spacings[(i+1)%2]*(i/2-i%2*.5), 0, 0])
                        mirror([0,i%2,0])
                            coin(coins[i], rot=45+90);
                }

            }
        }
    }
}

just_coins();
