{ lib, ... }: let
    inherit (lib) enabled;
in {
    home-manager.sharedModules = [{
        # More advanced file pager than 'more'
        programs.less = enabled {
            # With these extra keybinds, less can approach heaVim
            config = ''
                #command

                #line-edit
                ^A         home
                ^E         end
                ^B         left
                ^F         right
                ^P         up
                ^N         down
                ^D         delete
                ^W         word-backspace

                #env
                LESS=-FRX
            '';
        };
    }];
}
