{ pkgs, ... }: {
    home-manager.sharedModules = [{
        home.packages = [
            ## CORE
            pkgs.bc                 # GNU arbitrary-precision calculator
            pkgs.curl               # Command line tool for transferring files with URL syntax
            pkgs.file               # Determine file type
            pkgs.gnumake            # A program for directing recompilation
            pkgs.stow               # Symlink farm manager
            pkgs.strace             # System call tracer for Linux
            pkgs.time               # Runs programs and summarize the system resources they use
            pkgs.tinyxxd            # Hex dump utility
            pkgs.trash-cli          # Command line interface to the freedesktop.org trashcan
            (pkgs.symlinkJoin {     # Successor of GNU Wget, a file and recursive website downloader
                name = "wget";
                # Like hell I will willingly type out wget2
                paths = [ pkgs.wget2 ];
                postBuild = ''ln -s $out/bin/wget2 $out/bin/wget'';
                meta.mainProgram = "wget";
            })

            ## MISC
            # pkgs.entr               # Run arbitrary commands when files change
            pkgs.ffmpeg             # Complete, cross-platform solution to record, convert and stream audio and video
            # pkgs.hyperfine          # Benchmarking cli tool
            pkgs.imagemagick        # Software suite to create, edit, compose, or convert bitmap images
            pkgs.inotify-tools      # Inotify toolbox. Provides `inotifywait`.
            # pkgs.mprocs
            # pkgs.ocrmypdf
            pkgs.pastel             # Command-line tool to generate, analyze, convert and manipulate colors
            pkgs.pciutils           # Provides `lspci`
            pkgs.porsmo             # Pomodoro cli app in Rust with timer and countdown
            pkgs.protonvpn-gui
            # pkgs.reuse              # Tool for compliance with the REUSE Initiative recommendations
            # pkgs.speedtest-rs       # Check your internet speed
            # pkgs.testdisk           # Data recovery utilities
            pkgs.tokei              # Count your code, quickly

            ## CUSTOM
            pkgs.tafsk              # Organize tasks like a file system
            pkgs.wasm4              # Build retro games using WebAssembly for a fantasy console
        ];

        home.sessionPath = [
            "$HOME/.local/bin"
        ];

        home.sessionVariables = {
            XDG_CONFIG_HOME = "$HOME/.config";
        };
    }];
}
