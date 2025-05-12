# New versions:
{ pkgs }:
let
    amdgpuVersion = "6.3.4";
    ubuntuVersion = "22.04";
in rec {
    amdenc = pkgs.callPackage ./amdenc.nix {
        inherit amdgpuVersion ubuntuVersion;
        version = "1.0-2125449";
        sha256 = "IgIcbugJZkiBL2p2xW7C6z/1xgNEgdpmDbo0hHUzP/0=";
    };
    amf = pkgs.callPackage ./amf.nix {
        inherit amdgpuVersion ubuntuVersion amdenc;
        version = "1.4.36-2125449";
        sha256 = "nBi/NpsgsiFrpZ5bkT3iIpbSYvdkQgeyt6khefr5vso=";
    };
    amf-headers = pkgs.callPackage ./amf-headers.nix {
        version = "1.4.36";
        sha256 = "0PgWEq+329/EhI0/CgPsCkJ4CiTsFe56w2O+AcjVUdc=";
    };
}

# Old versions:
# { pkgs }:
# let
#     amdgpuVersion = "6.1.4";
#     ubuntuVersion = "22.04";
# in rec {
#     amdenc = pkgs.callPackage ./amdenc.nix {
#         inherit amdgpuVersion ubuntuVersion;
#         version = "1.0-2002333";
#         sha256 = "SQu6XUQ592UVRUzIOZJda/cZk59D5zbfWe3l7zKD608=";
#     };
#     amf = pkgs.callPackage ./amf.nix {
#         inherit amdgpuVersion ubuntuVersion amdenc;
#         version = "1.4.34-2002333";
#         sha256 = "bcvY2avBnMYJWoOLN73FEfZBxm59B6Ikw+oIg/7ycms=";
#     };
#     amf-headers = pkgs.callPackage ./amf-headers.nix {
#         version = "1.4.34";
#         sha256 = "u6gvdc1acemd01TO5EbuF3H7HkEJX4GUx73xCo71yPY=";
#     };
# }
