self: super:

{
  kakounePlugins = super.kakounePlugins // {
    kakeidoscope = super.callPackage ../../packages/kakounePlugins.kakeidoscope { };
  };
}
