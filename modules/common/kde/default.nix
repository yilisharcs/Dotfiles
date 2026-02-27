{ config, lib, pkgs, ... }: let
    inherit (lib) disabled enabled mkIf;
in {
    imports = [ ../fonts.nix ];

    services.displayManager.sddm = enabled {
        settings.Theme = {
            Current = "breeze";
            CursorSize = 42;
            CursorTheme = "Breeze_Light";
            Font = "Iosevka Nerd Font,13,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
        };
    };
    services.desktopManager.plasma6 = enabled;

    environment.systemPackages = [
        pkgs.kdePackages.kmail            # email client
        pkgs.kdePackages.kmail-account-wizard
        pkgs.kdePackages.isoimagewriter   # Optional: Program to write hybrid ISO files onto USB disks
        pkgs.kdePackages.partitionmanager # Optional: Manage the disk devices, partitions and file systems on your computer
    ];

    environment.plasma6.excludePackages = [
        pkgs.kdePackages.kate    # GUI text editor? Ew
        pkgs.kdePackages.konsole # Already have xterm for secondary terminal
    ];

    # <https://nix-community.github.io/plasma-manager/options.xhtml>
    home-manager.sharedModules = [{
        programs.elisa  = enabled {}; # TODO: configure?
        programs.okular = enabled {}; # TODO: configure?

        programs.plasma = enabled {
            immutableByDefault = true;
            # overrideConfig = true; # NOTE: occasionally breaks
            configFile = {
                kded_device_automounterrc."Devices/\\/org\\/freedesktop\\/UDisks2\\/block_devices\\/sdb1" = {
                    EverMounted = true;
                    ForceLoginAutomount = true;
                    Icon = "drive-removable-media-usb";
                    LastNameSeen = "Saturn";
                };
                kded_device_automounterrc."General" = {
                    AutomountEnabled = true;
                    AutomountOnPlugin = true;
                };
                kdeglobals.General.AccentColor = "61,212,37";
                kdeglobals.KDE.widgetStyle = "Windows"; # MS Windows 9x style
                # kdeglobals."KFileDialog Settings"."Show hidden files" = true;
                # kdeglobals."KFileDialog Settings"."Sort directories first" = true;
                # kdeglobals."KFileDialog Settings"."Sort hidden files last" = false;
                klipperrc.General.IgnoreImages = false;
                krunnerrc.Plugins.baloosearchEnabled = true;
                krunnerrc.Plugins.browserhistoryEnabled = false;
                plasmaparc.General.RaiseMaximumVolume = true;
            };
            fonts = {
                fixedWidth = {
                    family = "Hack";
                    pointSize = 12;
                    styleStrategy.antialiasing = "prefer";
                };
                general     =                 {
                    family = "Iosevka Nerd Font";
                    pointSize = 13;
                    styleStrategy.antialiasing = "prefer";
                };
                menu        =                 {
                    family = "Iosevka Nerd Font";
                    pointSize = 13;
                    styleStrategy.antialiasing = "prefer";
                };
                small = {
                    family = "Iosevka Nerd Font";
                    pointSize = 11;
                    styleStrategy.antialiasing = "prefer";
                };
                toolbar     =                 {
                    family = "Iosevka Nerd Font";
                    pointSize = 13;
                    styleStrategy.antialiasing = "prefer";
                };
                windowTitle =                 {
                    family = "Iosevka Nerd Font";
                    pointSize = 13;
                    styleStrategy.antialiasing = "prefer";
                };
            };
            input = {
                keyboard.repeatDelay = 300;
                # touchpads."*" =
                # mkIf (config.networking.hostName != "ouro") (enabled {
                #     disableWhileTyping = true;
                #     rightClickMethod = "twoFingers";
                # });
                # touchpads = mkIf (config.networking.hostName != "ouro") [
                #     (enabled {
                #         disableWhileTyping = true;
                #         rightClickMethod = "twoFingers";
                #     })
                # ];
            };
            krunner = {
                activateWhenTypingOnDesktop = true;
                historyBehavior = "disabled";
                position = "center";
            };
            kscreenlocker.appearance.alwaysShowClock = true;
            kwin = {
                effects = {
                    desktopSwitching.navigationWrapping = true;
                    dimAdminMode = enabled;
                    dimInactive = enabled;
                    hideCursor = enabled {
                        hideOnTyping = true;
                    };
                    minimization.animation = "squash";
                };
                nightLight = disabled {
                    mode = "times";
                    temperature = {
                        day = null;
                        night = null;
                    };
                    time = {
                        morning = "05:30";
                        evening = "20:30";
                    };
                    transitionTime = 6;
                };
            };
            powerdevil = {
                AC = {
                    autoSuspend.action = "nothing";
                    dimDisplay = enabled;
                    powerButtonAction = "shutDown";
                    powerProfile = "performance";
                    turnOffDisplay.idleTimeout = "never";
                    whenLaptopLidClosed = "lockScreen";
                };
                # Two laptops, both batteries gone
                battery = {};
            };
            shortcuts = {
                kwin = {
                    "Switch One Desktop to the Left"                        = "Meta+-";
                    "Switch One Desktop to the Right"                       = "Meta += ";
                    "Window to Next Desktop"                                = "Meta++";
                    "Window to Previous Desktop"                            = "Meta+_";
                    "Window to Next Screen"                                 = "Meta+Shift+Right";
                    "Window to Previous Screen"                             = "Meta+Shift+Left";
                    "Walk Through Windows"                                  = "Alt+Tab";
                    "Walk Through Windows (Reverse)"                        = "Alt+Shift+Tab";
                    "Walk Through Windows Alternative"                      = "Alt+Esc";
                    "Walk Through Windows Alternative (Reverse)"            = [ ];
                    "Walk Through Windows of Current Application"           = "Alt+`";
                    "Walk Through Windows of Current Application (Reverse)" = "Alt+~";
                };
                plasmashell = {
                    cycleNextAction = "Meta+.";  # Next clipboard item
                    cyclePrevAction = "Meta+\\"; # Prev clipboard item
                };
                "services/com.mitchellh.ghostty.desktop"._launch  = "Meta+Return"; # Launch terminal
                "services/org.kde.plasma.emojier.desktop"._launch = "Meta+/";      # Launch emoji thing
            };
            # TODO: what is spectacle?
            # spectacle.shortcuts = {
            #     captureRectangularRegion = "Meta+Shift+S";
            #     captureWindowUnderCursor = "Meta+Shift+S";
            # };

            panels = [{
                location = "top";
                floating = false;
                height = 46;
                widgets = [
                    "org.kde.plasma.kickoff"
                    {
                        name = "org.kde.plasma.icontasks";
                        config.launchers = [
                            "applications:com.mitchellh.ghostty.desktop"
                            "applications:brave-browser.desktop"
                            "applications:org.kde.kmail2.desktop"
                            "preferred://filemanager"
                            "applications:systemsettings.desktop"
                            "applications:Fightcade.desktop"
                        ];
                    }
                    "org.kde.plasma.marginsseparator"
                    {
                        name = "org.kde.plasma.systemmonitor.net";
                        config.Appearance.updateRateLimit = 2000;
                    }
                    {
                        name = "org.kde.plasma.systemmonitor.diskusage";
                        config = {
                            Appearance = {
                                chartFace = "org.kde.ksysguard.piechart";
                                updateRateLimit = 2000;
                            };
                            Sensors = {
                                highPrioritySensorIds = ''["disk/(?!all).*/free"]'';
                                lowPrioritySensorIds = ''["disk/all/total"]'';
                                totalSensors = ''["disk/all/free"]'';
                            };
                            SensorColors = {
                                "disk/991c140a-3cc9-4ec9-89c5-61dbf94fd745/free" = "155,33,147"; # ouro sda2
                                "disk/13678003-881a-434b-9072-1dd10045b7ad/free" = "155,33,147"; # gato sda3
                            };
                        };
                    }
                    {
                        name = "org.kde.plasma.systemmonitor.cpu";
                        config.Appearance.updateRateLimit = 2000;
                    }
                    {
                        name = "org.kde.plasma.systemmonitor.memory";
                        config.Appearance.updateRateLimit = 2000;
                    }
                    "org.kde.plasma.systemtray"
                    {
                        name = "org.kde.plasma.lock_logout";
                        config = {
                            show_lockScreen = false;
                            show_requestReboot = true;
                            show_requestShutDown = true;
                        };
                    }
                    {
                        name = "org.kde.plasma.digitalclock";
                        config.Appearance = {
                            showDate = true;
                            dateDisplayFormat = "BelowTime";
                        };
                    }
                    "org.kde.plasma.showdesktop"
                ];
            }];
            windows.allowWindowsToRememberPositions = true;
            workspace = {
                enableMiddleClickPaste = false;
                clickItemTo = "open";
                colorScheme = "BreezeDark";
                cursor = {
                    size = 42;
                    theme = "Breeze_Light";
                };
                # lookAndFeel = "org.kde.breezedark.desktop"; # NOTE: overrides widgetStyle
                theme = "breeze-dark";
                wallpaper = ./__sonic_shadow_silver__drawn_by_spacedawgspace.jpg;
                wallpaperFillMode = "preserveAspectFit";
            };
        };
    }];
}
