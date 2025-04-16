{
  stdenv,
  lib,
  makeDesktopItem,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  xdg-utils,
  lsof,
  libz,
  lttng-ust_2_12,
}:
stdenv.mkDerivation rec {
  pname = "awsvpnclient";
  version = "5.0.0";

  src = fetchurl {
    url = "https://d20adtppz83p9s.cloudfront.net/GTK/${version}/awsvpnclient_amd64.deb";
    sha256 = "sha256-ZFEmtWmMtVDp3IIuWO2Jmlcw0uIE8o9AI+xnGRX92gw=";
  };

  dontBuild = true;

  buildInputs = [
    stdenv.cc.cc.lib
    libz
    lttng-ust_2_12
  ];

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg -x $src ./awsvpnclient-src
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -r awsvpnclient-src/opt "$out/opt"
    cp -r awsvpnclient-src/usr/share "$out/share"

    mkdir -p "$out/bin"
    ln -s "$out/opt/awsvpnclient/AWS VPN Client" "$out/bin/AWS VPN Client"

    substituteInPlace "$out/share/applications/awsvpnclient.desktop" \
      --replace "/opt/" "$out/opt/"

    runHook postInstall
  '';

  propagatedBuildInputs = [xdg-utils lsof];
  meta = with lib; {
    description = "AWS VPN Client";
    homepage = "https://aws.amazon.com/vpn/client/";
    #license = licenses.mit;
    platforms = platforms.linux;
  };
}
