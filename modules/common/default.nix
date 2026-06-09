{pkgs, ...}: {
  home-manager.sharedModules = [
    {
      home.packages = [
        ## CORE
        pkgs.bc # GNU arbitrary-precision calculator
        pkgs.binutils # Tools for manipulating binaries. Provides `strings`, etc.
        pkgs.curl # Command line tool for transferring files with URL syntax
        pkgs.file # Determine file type
        pkgs.gnumake # A program for directing recompilation
        pkgs.stow # Symlink farm manager
        pkgs.strace # System call tracer for Linux
        pkgs.time # Runs programs and summarize the system resources they use
        pkgs.tinyxxd # Hex dump utility
        pkgs.trash-cli # Command line interface to the freedesktop.org trashcan
        (pkgs.symlinkJoin {
          # Successor of GNU Wget, a file and recursive website downloader
          name = "wget";
          # Like hell I will willingly type out wget2
          paths = [pkgs.wget2];
          postBuild = ''ln -s $out/bin/wget2 $out/bin/wget'';
          meta.mainProgram = "wget";
        })

        ## MISC
        pkgs.bsdiff # Efficient binary diff/patch tool
        pkgs.ffmpeg # Complete, cross-platform solution to record, convert and stream audio and video
        pkgs.hyperfine # Benchmarking cli tool
        pkgs.imagemagick # Software suite to create, edit, compose, or convert bitmap images
        pkgs.inotify-tools # Inotify toolbox. Provides `inotifywait`.
        pkgs.libreoffice # Office productivity suite
        pkgs.pastel # Command-line tool to generate, analyze, convert and manipulate colors
        pkgs.pciutils # Provides `lspci`
        pkgs.proton-vpn
        pkgs.reuse # Tool for compliance with the REUSE Initiative recommendations
        pkgs.testdisk # Data recovery utilities
        pkgs.tokei # Count your code, quickly
        pkgs.tree # Command to produce a depth indented directory listing
        pkgs.wl-clipboard # Command-line copy/paste utilities for Wayland

        ## CUSTOM
        pkgs.hivepal # Sega Mega Drive palette editor
        pkgs.wasm4 # Build retro games using WebAssembly for a fantasy console
      ];

      home.sessionPath = [
        "$HOME/.local/bin"
      ];
    }
  ];
}
