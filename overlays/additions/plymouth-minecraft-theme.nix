{ stdenvNoCC, fetchFromGitHub, imagemagick, plymouth }:

stdenvNoCC.mkDerivation {
  name = "plymouth-minecraft-theme";
  version = "unstable";
  description = "Minecraft plymouth theme";

  src = fetchFromGitHub {
    owner = "nikp123";
    repo = "minecraft-plymouth-theme";
    rev = "a4498c6467465e4395335dfa1e57a8a1b8f69616";
    sha256 = "sha256-qSTHlPXvjTDhupDzIXNPBL16yKUNsRwsYZWypcxPKpw=";
  };

  nativeBuildInputs = [ imagemagick ];

  buildPhase = ''
    PLYMOUTH_THEME_BASEDIR=$out/share/plymouth/themes/mc
    FONTS_BASEDIR=$out/share/fonts/OTF

    # Copy font
    mkdir -p $FONTS_BASEDIR
    cp $src/font/Minecraft.otf $FONTS_BASEDIR

    # Copy plymouth theme
    mkdir -p $PLYMOUTH_THEME_BASEDIR
    cp $src/plymouth/mc.script $PLYMOUTH_THEME_BASEDIR
    cp $src/plymouth/mc.plymouth $PLYMOUTH_THEME_BASEDIR
    cp $src/plymouth/progress_bar.png $PLYMOUTH_THEME_BASEDIR
    cp $src/plymouth/progress_box.png $PLYMOUTH_THEME_BASEDIR

    # Create smaller versions of assets
    for j in "padlock" "bar"; do
      for i in $(seq 1 6); do
        ${imagemagick}/bin/magick $src/plymouth/$j.png \
          -interpolate Nearest \
          -filter point \
          -resize "$i"00% \
          $PLYMOUTH_THEME_BASEDIR/$j-"$i".png
      done
    done

    for i in $(seq 1 12); do
      ${imagemagick}/bin/magick $src/plymouth/dirt.png \
        -channel R \
        -evaluate multiply .2509803922 \
        -channel G \
        -evaluate multiply .2509803922 \
        -channel B \
        -evaluate multiply .2509803922 \
        -interpolate Nearest \
        -filter point \
        -resize "$i"00% \
        $PLYMOUTH_THEME_BASEDIR/dirt-"$i".png
    done
  '';
}