#!/usr/bin/env python3
"""Build the coat-of-arms relief height map from the plaque STL.

Project config for the relief-pipeline skill: the generic stages
(align, rasterize, segment, marks, export) live in
../../relief-pipeline/scripts/relief_lib.py. This file holds only what
is specific to this plaque. Coordinates are pixels of the 2400-wide
height map.

Input : assets/coat_of_arms_plaque.stl  (frame, textured field, rock
        mound, bear, ash tree, fox)
Output: assets/coat_of_arms_relief.png  (bear, tree and fox only;
        0 = plate face, 255 = relief peak)
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', '..', 'relief-pipeline', 'scripts'))
from relief_lib import run_build

A = lambda *p: os.path.join(HERE, '..', 'assets', *p)

# cut boundary, left to right (x, y); everything below it is removed.
# Left of the tree it is not the mound top: it hugs the bear's rear leg,
# heel and toes, because the mound sliver in front of them sits at the
# same height as the feet and no threshold separates them. The dip at
# x 534-708 kept a generous mound patch under the front hind leg; the
# hand marks below now shape that area, so these vertices stay put.
MOUND = [(0,1150),(363,1150),(360,1176),(366,1188),(378,1196),(395,1201),
         (425,1205),(460,1207),(500,1208),(516,1205),(524,1197),(526,1188),
         (524,1165),(520,1150),(534,1160),(542,1178),(548,1195),(560,1205),
         (580,1209),(620,1209),(670,1202),(695,1188),(706,1160),(708,1138),
         (700,1118),(780,1103),(860,1088),(1000,1075),(1140,1075),
         (1170,1068),(1230,1068),(1260,1075),(1330,1075),(1400,1078),
         (1470,1075),(1520,1085),(1560,1112),(1600,1128),(1660,1135),
         (1700,1120),(1760,1122),(1860,1142),(1900,1152),(1950,1160),
         (2030,1170),(2100,1195),(2200,1205),(2399,1205)]

# ((x0, x1, y0, y1), threshold relative to the field level): inside the
# box, keep pixels above the threshold instead of the default rule.
# None means the global field_lift.
ZONES = [((640, 940, 490, 865), 0.025),     # background web around the
                                            # forepaws; the far foreleg
                                            # plateau and the branch stay
         ((815, 840, 505, 572), 0.008),     # fur fringe under the upper
                                            # paw's toes, stopping short
                                            # of the leaf at x 880+
         ((1940, 2040, 1150, 1162), None),  # fox's rear ankle: no mound yet
         ((1940, 2040, 1162, 1172), 0.075), # ankle over the mound's slope
         ((1880, 2040, 1172, 1185), 0.090), # fox's rear foot on the mound
         ((1880, 2040, 1185, 1193), 0.095)]

# (polygon, floor) patches applied after all cuts: the sculpt's
# leg-to-mound crease dips to field level, so these tie the bear's legs,
# ground and toes into one surface; pixels already taller keep their
# height
RESTORE = [([(520,1160),(560,1140),(620,1128),(700,1116),(712,1140),
             (706,1180),(680,1200),(640,1207),(570,1208),(535,1200),
             (522,1180)], 0.030),
           ([(348,1196),(420,1200),(460,1204),(500,1206),(540,1204),
             (566,1204),(566,1214),(348,1214)], 0.030)]

CONFIG = dict(
    src=A('coat_of_arms_plaque.stl'),
    out=A('coat_of_arms_relief.png'),
    marks=A('user-marks.json'),
    territory=A('territory.png'),
    raster_w=2400,
    field_lift=0.012,
    rect=(130, 2271, 125, 1216),   # inside the plaque's frame
    min_blob=400,                  # the paw's claw tuft is a ~600 px island
    out_w=720,                     # ~0.1 mm/px at 72 mm wide
    pad=4,
    keep_floor=0.025,
    field_window=(150, 1150, 150, 2250),
    field_range=(-0.06, 0.02),
    # fill quantization; must never change while saved marks exist
    h_min=-0.09558,
    h_range=0.23266,
    mound=MOUND,
    zones=ZONES,
    restore=RESTORE,
)

if __name__ == '__main__':
    run_build(CONFIG)
