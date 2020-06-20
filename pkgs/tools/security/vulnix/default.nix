{ stdenv, fetchpatch, python3Packages, nix, ronn }:

python3Packages.buildPythonApplication rec {
  pname = "vulnix";
  version = "1.9.4";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "06dpdsnz1ih0syas3x25s557qpw0f4kmypvxwaffm734djg8klmi";
  };

  patches = [
    # https://github.com/flyingcircusio/vulnix/pull/64 -- flake8 fix
    (fetchpatch {
      url = "https://github.com/flyingcircusio/vulnix/commit/10c96d48d14d73cc27a22551c684e5bf5bedf884.patch";
      sha256 = "080dnyq7ab2kg61z3zkf5y8yb1glqj1n6c032n8zw212v5kj4cxg";
    })
  ];

  outputs = [ "out" "doc" "man" ];
  nativeBuildInputs = [ ronn ];

  checkInputs = with python3Packages; [
    freezegun
    pytest
    pytestcov
    pytest-flake8
  ];

  propagatedBuildInputs = [
    nix
  ] ++ (with python3Packages; [
    click
    colorama
    pyyaml
    requests
    setuptools
    toml
    zodb
  ]);

  postBuild = "make -C doc";

  checkPhase = "py.test src/vulnix";

  postInstall = ''
    install -D -t $doc/share/doc/vulnix README.rst CHANGES.rst
    gzip $doc/share/doc/vulnix/*.rst
    install -D -t $man/share/man/man1 doc/vulnix.1
    install -D -t $man/share/man/man5 doc/vulnix-whitelist.5
  '';

  dontStrip = true;

  meta = with stdenv.lib; {
    description = "NixOS vulnerability scanner";
    homepage = "https://github.com/flyingcircusio/vulnix";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ckauhaus ];
  };
}
