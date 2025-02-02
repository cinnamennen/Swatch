include <geometry_diff.scad>
include <recreation.scad>

// Colored visualizations of differences
module show_differences() {
  color("green", 1) recreation();
//   color("grey", .7) translate([-82.75, -86.5, 0])
//       import("../assets/Sample-B.stl");
  //   color("red", 0.7) extra();
  //   color("blue", 1) missing();
}

show_differences();