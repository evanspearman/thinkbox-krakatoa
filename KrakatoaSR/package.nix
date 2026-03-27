{ lib
, stdenv
, src
, cmake
, ninja
, pkg-config
, thinkboxlibrary
, krakatoa
, boost
, bzip2
, eigen
, glog
, utf8cpp
, xxHash
, icu
, zlib
, tinyxml-2
, openexr
, tbb
, libb2
, openimageio
}:

stdenv.mkDerivation {
  pname = "krakatoasr";
  version = "0.1.0";

  inherit src;

  sourceRoot = "source/KrakatoaSR";

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
      tinyxml-2
      openexr
      tbb
      libb2
      bzip2
      eigen
      glog
      utf8cpp
      xxHash
      icu
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
