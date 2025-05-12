{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  amdgpuVersion,
  ubuntuVersion,
  version,
  sha256
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "amdenc";
  version = version;

  src = fetchurl {
    url = "https://repo.radeon.com/amdgpu/${amdgpuVersion}/ubuntu/pool/proprietary/liba/libamdenc-amdgpu-pro/libamdenc-amdgpu-pro_${finalAttrs.version}.${ubuntuVersion}_amd64.deb";
    sha256 = sha256;
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = [ (lib.getLib stdenv.cc.cc) ];

  installPhase = ''
    runHook preInstall
    install -Dm755 opt/amdgpu-pro/lib/x86_64-linux-gnu/* -t $out/lib
    runHook postInstall
  '';

  meta = {
    description = "AMD Encode Core Library";
    homepage = "https://www.amd.com/en/support/download/drivers.html";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ jopejoe1 ];
  };
})
