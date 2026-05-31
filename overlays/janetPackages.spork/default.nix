self: super:

{
  janetPackages = (super.janetPackages or { }) // {
    spork = super.callPackage ../../packages/janetPackages.spork { };
  };
}
