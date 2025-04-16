{
  stdenv,
  lib,
  makeWrapper,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  xdg-utils,
  lsof,
  icu,
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
    icu
    lttng-ust_2_12
  ];

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
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

    wrapProgram "$out/opt/awsvpnclient/Service/ACVC.GTK.Service" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [libz icu lttng-ust_2_12]}"

    wrapProgram "$out/opt/awsvpnclient/AWS VPN Client" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [libz icu lttng-ust_2_12]}"

    mkdir -p "$out/bin"
    ln -s "$out/opt/awsvpnclient/AWS VPN Client" "$out/bin/AWS VPN Client"
    ln -s "$out/opt/awsvpnclient/Service/ACVC.GTK.Service" "$out/bin/ACVC.GTK.Service"

    substituteInPlace "$out/share/applications/awsvpnclient.desktop" \
      --replace-fail "/opt/" "$out/opt/" \
      --replace-fail ".png" ""


    #chmod 000 "$out/opt/awsvpnclient/SQLite.Interop.dll"
    find "$out" -type d -exec chmod 755 {} +

    runHook postInstall
  '';

  propagatedBuildInputs = [xdg-utils lsof icu];
  meta = with lib; {
    description = "AWS VPN Client";
    homepage = "https://aws.amazon.com/vpn/client/";
    #license = licenses.mit;
    platforms = platforms.linux;
  };
}
