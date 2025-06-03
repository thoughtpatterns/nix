{
  lib,
  rustPlatform,
  fetchFromSourcehut,
}:

rustPlatform.buildRustPackage rec {
  pname = "kakeidoscope";
  version = "1.0.0";

  src = fetchFromSourcehut {
    owner = "~orchid";
    repo = "kakeidoscope";
    rev = "v${version}";
    sha256 = "sha256-h4sE7HkVf4wuojJ0vATCyu5Cb7cnFqhvZm5cClAOnHk=";
    vc = "git";
  };

  cargoHash = "sha256-h8zgGLShsOohh9unH6CM+TtQg2Taiblf9aAbjFYTZ30=";

  meta = with lib; {
    description = "A rainbow bracket highlighter for Kakoune";
    homepage = "https://git.sr.ht/~orchid/kakeidoscope";
    license = licenses.bsd0;
    platforms = platforms.all;
    maintainers = with maintainers; [ mackeye ];
  };
}
