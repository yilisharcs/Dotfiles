{pkgs, ...}: {
  home-manager.sharedModules = [
    {
      home.packages = [
        pkgs.mediainfo # Supplies technical and tag info about a video or audio file
        pkgs.mpv # General-purpose media player, fork of MPlayer and mplayer2
      ];

      programs.yazi.settings.opener = {
        play = [
          {
            desc = "Open with MPV";
            run = "mpv %s";
            orphan = true;
            for = "unix";
          }
          {
            desc = "Show media info";
            run = "mediainfo %s1 | bat";
            block = true;
            for = "unix";
          }
        ];
      };
    }
  ];
}
