# Hardware Cabling

## Scope
- Records the current desk video and keyboard/mouse cabling that affects display-layout behavior.
- Uses `Monitor` for physical screens. `display` remains the Hammerspoon/macOS/displayplacer terminology.
- The hardware KVM is the `4 computers share 2 monitors` class: 4 DP/HDMI/USB input groups and 2 monitor outputs.
- `pc-z490m` bypasses the KVM and connects directly to Monitor 2. The exact Monitor 2 input for `pc-z490m` is pending verification (`HDMI1` or `DP1`), but this does not affect the device-group topology or cable-count relationship.
- Topology diagram: `docs/diagrams/hardware_cabling.puml`.

## Device Names
| Canonical name | Role |
|---|---|
| `pc-b760m` | Dual-monitor desktop through KVM IN4 |
| `pc-z490m` | Monitor 2 direct desktop, bypasses KVM |
| `pve-gw` | Single-video source through KVM IN1 |
| `pve-nas` | Single-video source through KVM IN2 |
| Macbook via Dell Thunderbolt dock | Dual-monitor source through KVM IN3 |

## Topology
- `pve-gw`, `pve-nas`, `pc-b760m`, and the Macbook dock feed the hardware KVM.
- Macbook feeds the hardware KVM through the Dell Thunderbolt dock.
- Hardware KVM feeds both monitors and the shared Keyboard1/Mouse1 path.
- `pc-z490m` bypasses the hardware KVM and connects only to Monitor 2.

## KVM Inputs
| KVM input | Device | Video into KVM | USB into KVM |
|---|---|---|---|
| IN1 | `pve-gw` | HDMI -> HDMI1 | USB -> USB1 |
| IN2 | `pve-nas` | HDMI -> HDMI2 | USB -> USB2 |
| IN3 | Macbook via Dell Thunderbolt dock | DP -> DP3, HDMI -> HDMI3 | USB -> USB3 |
| IN4 | `pc-b760m` | DP -> DP4, HDMI -> HDMI4 | USB -> USB4 |

## Monitor And Keyboard Outputs
| Output path | Connection |
|---|---|
| KVM OUT DP1 | Monitor 1 DP1 |
| KVM OUT HDMI1 | Monitor 2 HDMI2 |
| KVM console USB | Keyboard1 + Mouse1 |
| `pc-z490m` video | Monitor 2 direct input, pending verification (`HDMI1` or `DP1`) |

## Operating Implications
- `pc-b760m` and Macbook can use both monitors through the KVM.
- `pve-gw` and `pve-nas` use the shared KVM keyboard/mouse path and the KVM HDMI output to Monitor 2; Monitor 1 may have no signal for these single-video sources.
- `pc-z490m` is independent of KVM switching. Switching the KVM does not move `pc-z490m` video.
- The designed path uses native DP or HDMI links only. There is no required DP-to-HDMI or HDMI-to-DP protocol conversion in the recorded cabling.
