{
  lib,
  stdenv,
  fetchFromGitHub,
  version,
  sha256
}:

stdenv.mkDerivation {
  pname = "amf-headers";
  version = version;

  src = fetchFromGitHub {
    owner = "GPUOpen-LibrariesAndSDKs";
    repo = "AMF";
    rev = "v${version}";
    sha256 = sha256;
  };

  installPhase = ''
    mkdir -p $out/include/AMF
    cp -r amf/public/include/* $out/include/AMF
  '';

  meta = with lib; {
    description = "Headers for The Advanced Media Framework (AMF)";
    homepage = "https://github.com/GPUOpen-LibrariesAndSDKs/AMF";
    license = licenses.mit;
    maintainers = with maintainers; [ devusb ];
    platforms = platforms.unix;
  };
}
