{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  libdrm,
  amdenc,
  autoPatchelfHook,
  amdgpuVersion,
  ubuntuVersion,
  version,
  sha256
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "amf";
  version = version;

  src = fetchurl {
    url = "https://repo.radeon.com/amdgpu/${amdgpuVersion}/ubuntu/pool/proprietary/a/amf-amdgpu-pro/amf-amdgpu-pro_${finalAttrs.version}.${ubuntuVersion}_amd64.deb";
    sha256 = sha256;
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = [
    libdrm
    amdenc
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 opt/amdgpu-pro/lib/x86_64-linux-gnu/* -t $out/lib
    runHook postInstall
  '';

  preFixup = ''
    patchelf $out/lib/* --add-needed libamdenc64.so
  '';

  meta = {
    description = "AMD's closed source Advanced Media Framework (AMF) driver";
    homepage = "https://www.amd.com/en/support/download/drivers.html";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ jopejoe1 ];
  };
})
