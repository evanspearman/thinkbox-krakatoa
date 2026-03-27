{ lib
, stdenv
, src
, cmake
, ninja
, pkg-config
, thinkboxlibrary
, boost
, zlib
, tinyxml-2
, openexr
, tbb
}:

stdenv.mkDerivation rec {
  pname = "krakatoa";
  version = "0.1.0";

  inherit src;

  sourceRoot = "${src.name}/Krakatoa";

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs =
    [
      thinkboxlibrary
      boost
      zlib
      tinyxml-2
      openexr
      tbb
    ];
    
  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  meta = with lib; {
    description = "Krakatoa volumetric particle renderer";
    platforms = platforms.unix;
  };
}
