include <recreation.scad>

module overlap() {
  intersection() {
    import("../assets/sample.stl");
    translate([ 0, 0, 0 ]) recreation();
  }
}

module extra() {
  difference() {
    recreation();
    import("../assets/sample.stl");
    overlap();
  }
}

module missing() {
  difference() {
    import("../assets/sample.stl");
    recreation();
    overlap();
  }
}