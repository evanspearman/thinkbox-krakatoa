{ lib
, stdenv
, src
, cmake
, ninja
, pkg-config
, thinkboxlibrary
, krakatoa
, boost
, zlib
, openexr
, tbb
, xxHash
, openimageio
}:

stdenv.mkDerivation rec {
  pname = "krakatoasr";
  version = "0.1.0";

  inherit src;

  sourceRoot = "${src.name}/KrakatoaSR";

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs =
    [
      thinkboxlibrary
      krakatoa
      boost
      zlib
      openexr
      tbb
      xxHash
      openimageio
    ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  meta = with lib; {
    description = "KrakatoaSR library";
    platforms = platforms.unix;
  };
}
