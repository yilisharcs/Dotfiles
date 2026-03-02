{ stdenv, fetchzip }:

{
    fc2json = import ./fc2json.nix { inherit stdenv fetchzip; };
    sf3-training-grouflon = import ./sf3-training-grouflon.nix { inherit stdenv fetchzip; };
}
