# Add patches.

self: super:

{
  kakoune-unwrapped = super.kakoune-unwrapped.overrideAttrs (attrs: {
    patches = (attrs.patches or [ ]);
  });
}
