{ lib
, stdenv
, src
, cmake
, ninja
, pkg-config
, thinkboxlibrary
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
}:

stdenv.mkDerivation {
  pname = "krakatoa";
  version = "0.1.0";

  inherit src;

  sourceRoot = "source/Krakatoa";

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
      libb2
      bzip2
      eigen
      glog
      utf8cpp
      xxHash
      icu
    ];
    
  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  meta = with lib; {
    description = "Krakatoa volumetric particle renderer";
    platforms = platforms.unix;
  };
}
