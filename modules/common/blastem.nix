{pkgs, ...}: {
  home-manager.sharedModules = [
    {
      # The fast and accurate Genesis emulator
      home.packages = [pkgs.blastem];

      xdg.configFile."blastem/blastem.cfg".text = ''
        bindings {
          keys {
            - ui.prev_speed
            0 ui.set_speed.0
            1 ui.set_speed.1
            2 ui.set_speed.2
            3 ui.set_speed.3
            4 ui.set_speed.4
            5 ui.set_speed.5
            6 ui.set_speed.6
            7 ui.set_speed.7
            = ui.next_speed
            [ ui.vdp_debug_mode
            ` ui.save_state
            b ui.plane_debug
            c ui.cram_debug
            d gamepads.1.b
            down gamepads.1.down
            e gamepads.1.y
            enter gamepads.1.start
            esc ui.menu
            f gamepads.1.c
            f11 ui.toggle_fullscreen
            f2 cassette.play
            f3 cassette.stop
            f4 cassette.rewind
            f5 ui.reload
            f7 ui.pause
            f8 ui.advance
            g gamepads.1.mode
            i ui.record_video
            l ui.load_state
            left gamepads.1.left
            m ui.vgm_log
            n ui.compositing_debug
            o ui.oscilloscope
            p ui.screenshot
            r gamepads.1.z
            rctrl ui.toggle_keyboard_captured
            right gamepads.1.right
            s gamepads.1.a
            tab ui.soft_reset
            u ui.enter_debugger
            up gamepads.1.up
            v ui.vram_debug
            w gamepads.1.x
            z ui.sms_pause
          }
          mice {
            0 {
              buttons {
                1 mouse.1.left
                2 mouse.1.middle
                3 mouse.1.right
                4 mouse.1.start
              }
              motion mouse.1.motion
            }
            1 {
              buttons {
                1 mouse.1.left
                2 mouse.1.middle
                3 mouse.1.right
                4 mouse.1.start
              }
              motion mouse.1.motion
            }
          }
          pads {
            default {
              axes {
                lefttrigger ui.prev_speed
                leftx.negative gamepads.n.left
                leftx.positive gamepads.n.right
                lefty.negative gamepads.n.up
                lefty.positive gamepads.n.down
                righttrigger ui.next_speed
              }
              buttons {
                a gamepads.n.a
                b gamepads.n.b
                back gamepads.n.mode
                guide ui.menu
                leftshoulder gamepads.n.z
                leftstick ui.save_state
                rightshoulder gamepads.n.c
                start gamepads.n.start
                x gamepads.n.x
                y gamepads.n.y
              }
              dpads {
                0 {
                  down gamepads.n.down
                  left gamepads.n.left
                  right gamepads.n.right
                  up gamepads.n.up
                }
              }
            }
            genesis_6b_bumpers {
              axes {
                lefttrigger ui.menu
                righttrigger gamepads.n.mode
              }
              buttons {
                a gamepads.n.a
                b gamepads.n.b
                back ui.sms_pause
                guide ui.menu
                leftshoulder gamepads.n.z
                rightshoulder gamepads.n.c
                start gamepads.n.start
                x gamepads.n.x
                y gamepads.n.y
              }
              dpads {
                0 {
                  down gamepads.n.down
                  left gamepads.n.left
                  right gamepads.n.right
                  up gamepads.n.up
                }
              }
            }
            ps3_6b_right {
              axes {
                lefttrigger ui.next_speed
                leftx.negative gamepads.n.up
                leftx.positive gamepads.n.down
                lefty.negative gamepads.n.left
                lefty.positive gamepads.n.right
                righttrigger gamepads.n.c
              }
              buttons {
                a gamepads.n.a
                b gamepads.n.b
                back ui.sms_pause
                guide ui.menu
                leftshoulder gamepads.n.mode
                leftstick ui.save_state
                rightshoulder gamepads.n.z
                rightstick ui.prev_speed
                start gamepads.n.start
                x gamepads.n.x
                y gamepads.n.y
              }
              dpads {
                0 {
                  down gamepads.n.down
                  left gamepads.n.left
                  right gamepads.n.right
                  up gamepads.n.up
                }
              }
            }
            ps4_6b_right {
              axes {
                lefttrigger ui.next_speed
                leftx.negative gamepads.n.up
                leftx.positive gamepads.n.down
                lefty.negative gamepads.n.left
                lefty.positive gamepads.n.right
                righttrigger gamepads.n.c
              }
              buttons {
                a gamepads.n.a
                b gamepads.n.b
                back ui.sms_pause
                guide ui.menu
                leftshoulder gamepads.n.mode
                leftstick ui.save_state
                rightshoulder gamepads.n.z
                rightstick ui.prev_speed
                start gamepads.n.start
                x gamepads.n.x
                y gamepads.n.y
              }
              dpads {
                0 {
                  down gamepads.n.down
                  left gamepads.n.left
                  right gamepads.n.right
                  up gamepads.n.up
                }
              }
            }
            saturn_6b_bumpers {
              axes {
                lefttrigger ui.menu
                righttrigger gamepads.n.mode
              }
              buttons {
                a gamepads.n.a
                b gamepads.n.b
                back ui.sms_pause
                guide ui.menu
                leftshoulder gamepads.n.z
                rightshoulder gamepads.n.c
                start gamepads.n.start
                x gamepads.n.x
                y gamepads.n.y
              }
              dpads {
                0 {
                  down gamepads.n.down
                  left gamepads.n.left
                  right gamepads.n.right
                  up gamepads.n.up
                }
              }
            }
            xbone_6b_right {
              axes {
                lefttrigger ui.next_speed
                leftx.negative gamepads.n.up
                leftx.positive gamepads.n.down
                lefty.negative gamepads.n.left
                lefty.positive gamepads.n.right
                righttrigger gamepads.n.c
              }
              buttons {
                a gamepads.n.a
                b gamepads.n.b
                back ui.sms_pause
                guide ui.menu
                leftshoulder gamepads.n.mode
                leftstick ui.save_state
                rightshoulder gamepads.n.z
                rightstick ui.prev_speed
                start gamepads.n.start
                x gamepads.n.x
                y gamepads.n.y
              }
              dpads {
                0 {
                  down gamepads.n.down
                  left gamepads.n.left
                  right gamepads.n.right
                  up gamepads.n.up
                }
              }
            }
            xbox_360_6b_right {
              axes {
                lefttrigger ui.next_speed
                leftx.negative gamepads.n.up
                leftx.positive gamepads.n.down
                lefty.negative gamepads.n.left
                lefty.positive gamepads.n.right
                righttrigger gamepads.n.c
              }
              buttons {
                a gamepads.n.a
                b gamepads.n.b
                back ui.sms_pause
                guide ui.menu
                leftshoulder gamepads.n.mode
                leftstick ui.save_state
                rightshoulder gamepads.n.z
                rightstick ui.prev_speed
                start gamepads.n.start
                x gamepads.n.x
                y gamepads.n.y
              }
              dpads {
                0 {
                  down gamepads.n.down
                  left gamepads.n.left
                  right gamepads.n.right
                  up gamepads.n.up
                }
              }
            }
          }
        }
        clocks {
          m68k_divider 7
          max_cycles 3420
          speeds {
            0 100
            1 150
            2 200
            3 300
            4 400
            5 25
            6 50
            7 75
          }
        }
        io {
          devices {
            1 gamepad6.1
            2 gamepad6.2
          }
          ea_multitap {
            1 gamepad6.1
            2 gamepad6.2
            3 gamepad6.3
            4 gamepad6.4
          }
          sega_multitap.1 {
            1 gamepad6.2
            2 gamepad6.3
            3 gamepad6.4
            4 gamepad6.5
          }
        }
        sms {
          io {
            devices {
              1 gamepad2.1
              2 gamepad2.2
            }
          }
          system {
            model md1va3
          }
        }
        system {
          default_region U
          force_region off
          megawifi off
          model md1va3
          ram_init zero
          sync_source audio
        }
        ui {
          extensions bin gen md smd sms gg sg sc sf7 zip gz cue iso vgm vgz flac wav col 32x
          initial_path $HOME
          remember_path on
          rom menu.bin
          save_path $USERDATA/blastem/$ROMNAME
          screenshot_path $HOME
          screenshot_template blastem_%Y%m%d_%H%M%S.png
          state_format native
          use_native_filechooser off
          vgm_path $HOME
          vgm_template blastem_%Y%m%d_%H%M%S.vgm
        }
        version 13
        video {
          aspect 4:3
          fragment_shader default.f.glsl
          fullscreen off
          gamegear {
            overscan {
              bot 48
              left 61
              right 62
              top 51
            }
          }
          gl on
          integer_scaling off
          npot_textures off
          ntsc {
            overscan {
              bottom 1
              left 13
              right 14
              top 2
            }
          }
          pal {
            overscan {
              bottom 17
              left 13
              right 14
              top 21
            }
          }
          scaling linear
          scanlines off
          vertex_shader default.v.glsl
          vsync off
          width 640
        }
      '';
    }
  ];
}
