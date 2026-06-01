{
  lib,
  fetchFromSourcehut,
  python314,
}:

let
  python = python314;
in
python.pkgs.buildPythonApplication rec {
  pname = "leccaper";
  version = "1.0.2";
  pyproject = true;

  src = fetchFromSourcehut {
    owner = "~orchid";
    repo = "leccaper";
    rev = "v${version}";
    sha256 = "sha256-bFQz9VyO7dbMOyaYwyzeBPwSXTTw8rEG89u1DFG7sMM=";
    vc = "git";
  };

  build-system = [ python.pkgs.uv-build ];
  dependencies = with python.pkgs; [
    requests
    selenium
    tqdm
  ];

  meta = with lib; {
    description = "A download tool for Leccap";
    homepage = "https://git.sr.ht/~orchid/leccaper";
    license = licenses.bsd0;
    platforms = platforms.all;
    maintainers = with maintainers; [ mackeye ];
  };
}
