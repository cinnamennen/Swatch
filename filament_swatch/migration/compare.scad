include <geometry_diff.scad>
include <recreation.scad>

// Colored visualizations of differences
module show_differences() {
  recreation();
  // color("grey", 1) translate([-82.75, -86.5, 0])
  //     import("../assets/sample.stl");
  //   color("red", 0.7) extra();
  //   color("blue", 1) missing();
}


show_differences();