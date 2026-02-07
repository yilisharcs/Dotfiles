#!/usr/bin/env luajit

local sys = {
        dry_run = false,
        id = {
                home = os.getenv("HOME"),
                user = os.getenv("USER"),
                -- C14CU51
                -- S500C
                hostname = io.lines("/etc/hostname")():match("%S+"),
        },
}

--- Executes a command and returns SUCCESS or FAILURE status.
---
---@param cmd string The command to execute.
---@return boolean success True if the command returned exit_code 0, or if in dry-run mode.
function sys._exec(cmd)
        if sys.dry_run then
                print("[simulate] " .. cmd)
                return true
        end

        return os.execute(cmd) == 0
end

--- Executes a command and asserts success.
---
---@param cmd string The command to execute.
function sys.run(cmd)
        assert(sys._exec(cmd), "[error]: Command failed: " .. cmd)
end

--- Checks if a binary exists in the current PATH.
---
---@param bin string The binary name to check.
---@return boolean exists True if the binary is found.
function sys.has(bin)
        return sys._exec(("command -v %s >/dev/null 2>&1"):format(bin))
end

--- Checks if a path exists.
---
--- @param path string The path to check.
--- @return boolean exists True if the path exists.
function sys.exists(path)
        local f = io.open(path, "r")
        if f then
                f:close()
        end
        return f ~= nil
end

--- Checks if a package is whitelisted for the current host.
--- @param pkg table The package definition.
--- @return boolean whitelisted True if the package should be installed on this host.
function sys.whitelisted(pkg)
        if not pkg.hosts then
                return true
        end
        for _, host in ipairs(pkg.hosts) do
                if host == sys.id.hostname then
                        return true
                end
        end
        return false
end

sys.managers = {
        apt = {
                deps = {},
                query_pkgs = function()
                        local packages = {}
                        local f = assert(io.popen("dpkg-query -f '${Package}\n' -W 2>/dev/null"))
                        -- stylua: ignore
                        for line in f:lines() do packages[line] = true end
                        f:close()
                        return packages
                end,
                install = function(name, _)
                        sys.run("sudo apt install -y " .. name)
                end,
                uninstall = function(name, _)
                        sys.run("sudo apt purge -y --autoremove " .. name)
                end,
        },
        cargo = { -- `rustup` from apt
                deps = { "apt" },
                bootstrap = function()
                        if not sys.has("cargo") then
                                -- stylua: ignore
                                print("rust installation not configured, bootstrapping via rustup...")
                                sys.run("rustup default stable")
                        end
                end,
                install = function(name, pkg)
                        local flags = pkg.flags or ""
                        sys.run(("cargo install %s %s"):format(name, flags))
                end,
                uninstall = function(name, _)
                        sys.run("cargo uninstall " .. name)
                end,
        },
        gh = {
                deps = { "apt" },
                is_installed = function(name, pkg)
                        local check_path = ("%s/.local/share/gh/extensions/%s"):format(
                                sys.id.home,
                                pkg.bin or name:match("/([^/]+)$")
                        )
                        return sys.exists(check_path)
                end,
                -- stylua: ignore start
                install =   function(name, _) sys.run("gh extension install " .. name) end,
                uninstall = function(name, _) sys.run("gh extension remove "  .. name) end,
                -- stylua: ignore end
        },
        luarocks = {
                deps = { "apt" },
                install = function(name, pkg)
                        local flags = pkg.flags or ""
                        sys.run(("luarocks install %s %s"):format(flags, name))
                end,
                uninstall = function(name, _)
                        sys.run("luarocks remove " .. name)
                end,
        },
        npm = { -- `fnm` from cargo
                deps = { "cargo" },
                bootstrap = function()
                        if not sys.has("npm") then
                                print("npm not found, bootstrapping via fnm...")
                                sys.run("fnm install --latest")
                        end
                end,
                install = function(name, pkg)
                        local flags = pkg.flags or ""
                        sys.run(("npm install -g %s %s"):format(name, flags))
                end,
                uninstall = function(name, _)
                        sys.run("npm uninstall -g " .. name)
                end,
        },
        uv = {
                deps = { "cargo" },
                install = function(name, pkg)
                        local flags = pkg.flags or ""
                        sys.run(("uv tool install %s %s"):format(name, flags))
                end,
                uninstall = function(name, _)
                        sys.run("uv tool uninstall " .. name)
                end,
        },
}

-- stylua: ignore
sys.state = {
        apt = {
                ensure = {
                        -- Dev tools and dependencies
                        ["blueprint-compiler"]        = {},                                                          -- (DEPS: `ghostty`) Compiler for GNOME Blueprint files
                        ["build-essential"]           = {},                                                          -- Informational list of build-essential packages
                        ["clang"]                     = {
                                deps = { apt = { ["clang-format"] = {} } },
                        }, -- C, C++ and Objective-C compiler
                        ["extra-cmake-modules"]       = {},                                                          -- (DEPS: `raylib-rs`) Extra modules for CMake
                        ["libadwaita-1-dev"]          = {},                                                          -- (DEPS: `ghostty`) Development files for libadwaita
                        ["libcurl4-openssl-dev"]      = {},                                                          -- (DEPS: `sonic3air-beta`)  Development files and documentation for libcurl
                        ["libfontconfig1-dev"]        = {},                                                          -- (DEPS: `aseprite`) Generic font configuration library - development
                        ["libfuse2t64"]               = {},                                                          -- (DEPS: Fightcade, FUSE AppImage) Filesystem in Userspace (FUSE) library
                        ["libgl1-mesa-dev"]           = {},                                                          -- (DEPS: `aseprite`, `sonic3air-beta`) Free implementation of the GL API -- development files
                        ["libglfw3-dev"]              = {},                                                          -- (DEPS: `raylib-rs`) GLFW library - development files
                        ["libglu1-mesa-dev"]          = {},                                                          -- (DEPS: `sonic3air-beta`) Mesa OpenGL Utility library -- development files
                        ["libgtk-4-dev"]              = {},                                                          -- (DEPS: `ghostty`) Development files for the GTK library
                        ["libgtk4-layer-shell-dev"]   = {},                                                          -- (DEPS: `ghostty`) Development files for gtk4-layer-shell
                        ["libpulse-dev"]              = {},                                                          -- (DEPS: `sonic3air-beta`) PulseAudio client development headers and libraries
                        ["libudev-dev"]               = {},                                                          -- libudev development files
                        ["libwayland-dev"]            = {},                                                          -- Wayland compositor infrastructure - development files
                        ["libxcomposite-dev"]         = {},                                                          -- (DEPS: `sonic3air-beta`) X11 Composite extension library (development headers)
                        ["libxcursor-dev"]            = {},                                                          -- (DEPS: `aseprite`) X cursor management library (development headers)
                        ["libxi-dev"]                 = {},                                                          -- (DEPS: `aseprite`) X11 Input extension library (development headers)
                        ["libxkbcommon-dev"]          = {},                                                          -- library interface to the XKB compiler - development files
                        ["libxxf86vm-dev"]            = {},                                                          -- (DEPS: `sonic3air-beta`) X11 Video Mode extension library (development headers)
                        ["lua5.4"]                    = {},                                                          -- (DEPS: `bootstrap.lua`, `skdisasm` build script) Simple, extensible, embeddable programming language
                        ["luajit"]                    = {
                                deps = { apt = { ["lua5.1-doc"] = {} } },
                        }, -- Just-In-Time compiled Lua 5.1
                        ["luarocks"]                  = {},                                                          -- Package manager for Lua modules
                        ["python-is-python3"]         = {},                                                          -- Symlinks /usr/bin/python to /usr/bin/python3
                        ["rustup"]                    = {
                                deps = { apt = { ["sccache"] = {} } },
                        }, -- The Rust toolchain installer
                        ["tcc"]                       = {},                                                          -- Tiny C Compiler
                        ["uuid-dev"]                  = {},                                                          -- Universally Unique ID library - headers and static libraries
                        ["wayland-protocols"]         = {},                                                          -- (DEPS: `raylib-rs`) Wayland protocols that add functionality to the core protocol
                        ["wine"]                      = {
                                deps = {
                                        apt = {
                                                ["firejail"] = {},
                                                ["wine32:i386"] = { bin = "/usr/lib/wine/wineserver32" },
                                                ["winetricks"] = {},
                                        },
                                },
                        }, -- (DEPS: Fightcade) Windows compatibility layer, 64-bit

                        -- Normal user packages
                        ["apt-file"]                  = {},                                                          -- Search for files within Debian packages
                        ["aptitude"]                  = {},                                                          -- High-level package manager interface
                        ["bat"]                       = { bin = "batcat"       },                                    -- `cat` with syntax highlighting
                        ["brave-browser"]             = {},                                                          -- Privacy-oriented web browser with built-in adblocking
                        ["bsdiff"]                    = {},                                                          -- Binary patch tools
                        ["btop"]                      = {},                                                          -- Resource monitor
                        ["cmus"]                      = {},                                                          -- Terminal music player
                        ["curl"]                      = {},                                                          -- URL transfer tool
                        ["czkawka-cli"]               = { bin = "czkawka_cli"  },                                    -- Duplicate file finder
                        ["entr"]                      = {},                                                          -- Run arbitrary commands when files change
                        ["extrepo"]                   = {},                                                          -- External repository manager
                        ["libimage-exiftool-perl"]    = { bin = "exiftool"     },                                    -- Read/write meta information in files
                        ["fastfetch"]                 = {},                                                          -- System information fetcher
                        ["fd-find"]                   = { bin = "fdfind"       },                                    -- Better `find`
                        ["ffmpeg"]                    = {},                                                          -- Multimedia framework
                        ["ffmpegthumbnailer"]         = {},                                                          -- Video thumbnailer
                        ["file"]                      = {},                                                          -- Determine file type
                        ["firejail"]                  = {},                                                          -- Security sandbox
                        ["fonts-noto-cjk"]            = {},                                                          -- CJK fonts
                        ["fonts-noto-color-emoji"]    = {},                                                          -- Color emoji font
                        ["fzf"]                       = {},                                                          -- Command-line fuzzy finder
                        ["gcc-doc"]                   = {},                                                          -- GCC documentation
                        ["gdu"]                       = {},                                                          -- Disk usage analyzer
                        ["gettext-doc"]               = {},                                                          -- GNU gettext documentation
                        ["gimp"]                      = {
                                deps = { apt = { ["gimp-help-en"] = {} } },
                        }, -- Image manipulation program
                        ["git"]                       = {
                                deps = {
                                        apt = { ["git-filter-repo"] = {} },
                                        gh = { ["dlvhdr/gh-dash"] = { bin = "gh-dash/gh-dash" } },
                                },
                        }, -- Version control system
                        ["hunspell-pt-br"]            = {},                                                          -- Brazilian Portuguese dictionary for hunspell
                        -- ["hyperfine"]              = {},                                                          -- Command-line benchmarking tool
                        ["imagemagick"]               = { bin = "magick"       },                                    -- Image suite (v7 unified binary)
                        -- ["inkscape"]               = {},                                                          -- Vector graphics editor
                        ["inotify-tools"]             = { bin = "inotifywait"  },                                    -- Inotify utilities
                        ["keyd"]                      = { bin = "keyd.rvaiya"  },                                    -- Key remapping daemon
                        -- ["krita"]                  = {},                                                          -- Digital painting program
                        ["less"]                      = {},                                                          -- Pager
                        ["libreoffice"]               = { bin = "libreoffice"  },                                    -- Office productivity suite
                        ["mesa-utils"]                = { bin = "glxinfo"      },                                    -- Mesa GL utilities
                        ["neovim"]                    = {
                                bin = "nvim",
                                deps = {
                                        apt = {
                                                ["build-essential"] = {},
                                                ["cmake"] = {},
                                                ["curl"] = {},
                                                ["gettext"] = {},
                                                ["git"] = {},
                                                ["jq"] = {}, -- Command-line JSON processor
                                                ["ninja-build"] = {},
                                                ["universal-ctags"] = { bin = "ctags" }, -- Generate tag files for code
                                                ["xxd"] = {}, -- Hex dump utility
                                        },
                                        cargo = {
                                                ["neovide"] = {
                                                        deps = {
                                                                apt = {
                                                                        ["cmake"] = {},
                                                                        ["git"] = {},
                                                                        ["libasound2-dev"] = {},
                                                                        ["libfontconfig1-dev"] = {},
                                                                        ["libfreetype-dev"] = {},
                                                                        ["libssl-dev"] = {},
                                                                        ["libxcursor-dev"] = {},
                                                                        ["pkg-config"] = {},
                                                                },
                                                        },
                                                },
                                                ["tree-sitter-cli"] = { bin = "tree-sitter", flags = "--locked" },
                                        },
                                },
                        }, -- Terminal text editor
                        ["nushell"]                   = {
                                bin = "nu",
                                deps = {
                                        apt = {
                                                ["starship"] = {},
                                                ["zoxide"] = {},
                                        },
                                },
                        },
                        ["obs-studio"]                = { bin = "obs"          },                                    -- Video recording and streaming
                        ["ocrmypdf"]                  = {
                                deps = { apt = { ["ocrmypdf-doc"] = {} } },
                        }, -- Add OCR layer to PDF files
                        ["pandoc"]                    = {},                                                          -- Universal document converter
                        ["pass"]                      = {},                                                          -- Password manager
                        ["pciutils"]                  = { bin = "lspci"        },                                    -- PCI utilities
                        ["picard"]                    = {},                                                          -- Music tagger
                        ["pinentry-qt"]               = {},                                                          -- Qt-based pinentry dialog
                        -- ["pulseaudio"]             = {},                                                          -- Sound system
                        ["qbittorrent"]               = {},                                                          -- BitTorrent client
                        ["ripgrep"]                   = { bin = "rg"           },                                    -- Search tool
                        ["rsync"]                     = {},                                                          -- Fast, versatile, remote (and local) file-copying tool
                        ["stow"]                      = {},                                                          -- Symlink farm manager
                        ["strace"]                    = {},                                                          -- System call tracer
                        ["syncthing"]                 = {},                                                          -- Continuous file synchronization
                        ["testdisk"]                  = {},                                                          -- Data recovery tool
                        ["time"]                      = {},                                                          -- Measure resource usage
                        ["timeshift"]                 = {},                                                          -- System restore utility
                        ["tmux"]                      = {
                                deps = { apt = { ["xclip"] = {} } },
                        }, -- Terminal multiplexer
                        ["tokei"]                     = {},                                                          -- Code statistics
                        ["trash-cli"]                 = { bin = "trash"        },                                    -- Command-line trashcan tools
                        -- ["ttf-mscorefonts-installer"] = {},                                                       -- Microsoft TrueType core fonts
                        ["vlc"]                       = {
                                deps = { apt = { ["vlc-plugin-fluidsynth"] = {} } },
                        }, -- Multimedia player
                        ["w3m"]                       = {},                                                          -- Text-based web browser
                        ["wget"]                      = {},                                                          -- Network downloader
                        ["xclip"]                     = {},                                                          -- Command-line interface to X selections
                        ["yt-dlp"]                    = {},                                                          -- Download videos from YouTube and other sites
                        ["zenity"]                    = {},                                                          -- Display graphical dialog boxes from shell
                },
                remove = {
                        ["dconf-editor"]              = {},                                                          -- Gnome configuration editor
                        ["firefox-esr"]               = { bin = "firefox"       },                                   -- firefox browser
                        ["just"]                      = { bin = "/usr/bin/just" },                                   -- v1.40.0. It's old
                        ["pipx"]                      = {},                                                          -- Contained Python package manager
                },
        },
        -- From <https://crates.io>
        cargo = {
                ensure = {
                        ["bob-nvim"]                  = { bin = "bob"                                             }, -- Neovim version manager
                        -- ["cargo-audit"]            = {},                                                          -- Audit Cargo.lock for crates with security vulnerabilities
                        -- ["cargo-auditable"]        = {},                                                          -- Make production Rust binaries auditable
                        -- ["cargo-binstall"]         = {},                                                          -- Binary installation for rust projects
                        -- ["cargo-modules"]          = {},                                                          -- Show crate modules in tree format
                        -- ["cargo-nextest"]          = {},                                                          -- A next-generation test runner for Rust
                        -- ["cargo-sweep"]            = {},                                                          -- Clean up unused `cargo` build files
                        ["cargo-update"]              = { bin = "cargo-install-update"                            }, -- Check and apply updates to installed executables
                        -- ["dioxus-cli"]             = {},                                                          -- Dioxus CLI
                        ["fnm"]                       = {},                                                          -- Fast Node Manager
                        ["jj-cli"]                    = { bin = "jj",          flags = "--locked"                 }, -- Modern version control system
                        ["just"]                      = {},                                                          -- CLI task runner, the better make
                        ["lspmux"]                    = {},                                                          -- rust-analyzer LSP server
                        -- ["mprocs"]                 = {},                                                          -- Multiple process runner
                        ["ouch"]                      = {
                                deps = {
                                        apt = {
                                                ["unrar-free"] = {},
                                                ["zip"] = {},
                                                ["zstd"] = {},
                                        },
                                },
                        }, -- Compression and decompression utility
                        ["pastel"]                    = {},                                                          -- CLI color tool
                        ["porsmo"]                    = {},                                                          -- CLI pomodoro app
                        -- ["ripgrep_all"]            = {
                        --      bin = "rga",
                        --      flags = "--locked",
                        --      deps = { apt = { ["poppler-utils"] = {} } },
                        -- }, -- ripgrep extension
                        ["stylua"]                    = {                      flags = "--features luajit,lua54"  }, -- Formatter for Lua
                        ["typst-cli"]                 = { bin = "typst",       flags = "--locked"                 }, -- Markup-based typesetting system
                        ["uv"]                        = {                      flags = "--locked"                 }, -- The best Python package installer and resolver
                        -- ["wasm-pack"]              = {},                                                          -- WebAssembly bundler tool
                },
        },
        -- From <https://github.com/cli/cli>
        gh = {
                ensure = {
                        ["dlvhdr/gh-dash"]            = { bin = "gh-dash/gh-dash" },                                 -- Terminal dashboard for GitHub pull requests
                },
        },
        -- From <https://luarocks.org>
        luarocks = {
                ensure = {
                        ["busted"]                    = { flags = "--local" },                                       -- Testing framework for Lua
                },
        },
        -- From <https://www.npmjs.com>
        npm = {
                ensure = {
                        ["opencode-ai@1.1.51"]        = { bin = "opencode" },                                        -- AI-powered open source assistant
                        ["wasm4"]                     = { bin = "w4"       },                                        -- WASM-4 game engine CLI
                },
        },
        -- From <https://pypi.org>
        uv = {
                ensure = {
                        ["json-spec"]                 = { bin = "json" },                                            -- CLI JSON validator
                        ["reuse"]                     = {},                                                          -- Software licensing compliance tool
                },
        },
}

function sys.main()
        -- The orchestrator. Start with removing any unwanted packages, then install the others.
        for name, state in pairs(sys.state) do
                -- If a manager doesn't have an uninstall function and packages to remove, skip
                local manager = sys.managers[name]
                if not (manager.uninstall and state.remove) then
                        goto next
                end

                -- Some managers require extra configuration before they can work:
                --      - `cargo` : requires a Rust toolchain
                --      - `npm`   : requires a Node toolchain
                if manager.bootstrap then
                        manager.bootstrap()
                end

                -- Some managers make it comfortable (and necessary) to query their database. Some
                -- don't; instead of forcing a dummy function upon them, return a table if missing.
                --      - `apt`
                local installed = (manager.query_pkgs or function()
                        return {}
                end)()
                -- stylua: ignore
                assert(type(installed) == "table", ("[manager:%s] query_pkgs must return a table"):format(name))

                for key, pkg in pairs(state.remove) do
                        -- Any package whose hosts table is NOT nil AND does not list the hostname
                        -- of the machine running this script is to be skipped, no questions asked.
                        if not sys.whitelisted(pkg) then
                                goto continue
                        end

                        -- Is the package in the manager's database? No? What of the manager's own
                        -- way to check installations? No? Is it in PATH then? No?
                        -- stylua: ignore
                        local exists = installed[key]
                                or (manager.is_installed and manager.is_installed(key, pkg))
                                or sys.has(pkg.bin or key)

                        if exists then
                                print(("[enforce:%s] removing %s..."):format(name, key))
                                manager.uninstall(key, pkg)
                        end
                        ::continue::
                end
                ::next::
        end

        -- Prepare padding value
        local max_len = 0
        for k in pairs(sys.state) do
                max_len = math.max(max_len, #k)
        end

        -- Ensure managers are called in order, their dependencies being installed first:
        --      - `cargo`    : apt
        --      - `gh`       : apt
        --      - `luarocks` : apt
        --      - `fnm`      : cargo
        --      - `uv`       : cargo
        local processed = {}
        local pending = {}
        for k in pairs(sys.state) do
                if sys.state[k].ensure then
                        pending[k] = true
                end
        end

        local package_done = {}

        local caches = {}
        local function get_cache(m_name)
                if caches[m_name] then
                        return caches[m_name]
                end
                local m_mgr = sys.managers[m_name]
                if m_mgr.bootstrap then
                        m_mgr.bootstrap()
                end
                local m_installed = (m_mgr.query_pkgs or function()
                        return {}
                end)()
                -- stylua: ignore
                assert(type(m_installed) == "table", ("[manager:%s] query_pkgs must return a table"):format(m_name))
                caches[m_name] = m_installed
                return m_installed
        end

        local function enforce_package(m_name, p_key, p_data)
                package_done[m_name] = package_done[m_name] or {}
                if package_done[m_name][p_key] then
                        return
                end

                if not sys.whitelisted(p_data) then
                        return
                end

                -- Keep a registry of all package definitions and, if a dependency has no metadata
                -- but a matching key exists, prefer that version to maintain awareness
                local registry = sys.state[m_name]
                        and sys.state[m_name].ensure
                        and sys.state[m_name].ensure[p_key]
                if registry and next(registry) and not next(p_data) then
                        p_data = registry
                end

                if p_data.deps then
                        for d_mgr_name, d_packages in pairs(p_data.deps) do
                                for d_key, d_pkg in pairs(d_packages) do
                                        enforce_package(d_mgr_name, d_key, d_pkg)
                                end
                        end
                end

                local m_mgr = sys.managers[m_name]
                local cache = get_cache(m_name)
                local exists = cache[p_key]
                        or (m_mgr.is_installed and m_mgr.is_installed(p_key, p_data))
                        or sys.has(p_data.bin or p_key)

                if not exists then
                        -- stylua: ignore
                        print(("[enforce:%s] installing %s..."):format(m_name, p_key))
                        m_mgr.install(p_key, p_data)
                        cache[p_key] = true
                end

                package_done[m_name][p_key] = true
        end

        while next(pending) do
                -- Simple check for circular dependencies. Alternatively, learn to read.
                -- Did we finish at least one manager in this loop? Yes? Next pass.
                local made_progress = false

                for name in pairs(pending) do
                        local manager = sys.managers[name]

                        -- `apt` has no dependencies, hence the empty table
                        for _, dep in ipairs(manager.deps or {}) do
                                -- If foundation isn't ready, jump to the next manager in the list
                                if not processed[dep] then
                                        goto skip_manager
                                end
                        end

                        local padding = string.rep(" ", max_len - #name)
                        -- stylua: ignore
                        print(("[manager:%s]%s processing..."):format(name, padding))

                        local packages = sys.state[name].ensure or {}

                        for key, pkg in pairs(packages) do
                                enforce_package(name, key, pkg)
                        end

                        processed[name] = true
                        pending[name] = nil
                        made_progress = true

                        ::skip_manager::
                end

                assert(made_progress, "[error]: circular dependency or missing manager detected")
        end
end

sys.main()
