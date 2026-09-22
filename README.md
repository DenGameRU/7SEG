# 7-Segment Display Visual Bitmask Calculator (7SEG)

A smart, GUI-driven Delphi utility designed for hardware developers and embedded engineers to visually generate font tables, hexadecimal codes, and binary arrays for 8-port (7 segments + decimal point) LED displays.

## Features
- **Color Mask Click-Mapping:** Utilizes a pixel-perfect background color map wrapper (`click_map.bmp`) to detect direct user mouse clicks over skewed or custom-shaped display vector segments instantly.
- **Dynamic Bit Index Pinout Remapping:** Reads custom physical wiring schemes directly from a local configuration bundle (`config.ini`) to map internal structural segment registers (`A, B, C, D, E, F, G, DP`) to specific micro-controller hardware data registers.
- **Real-Time Register Translation:** Automatically re-calculates active states through bitwise shifting routines (`1 shl BitIndex`), outputting correctly formatted binary indicators (`0b00000000`) and matching hex codes (`0x00`) on the fly.
- **Code Generation Sheet:** Features a tracking table frame buffer (**Add** button) that records generated codes into a formatted C-style sequence array ready for rapid integration into Arduino, AVR, or PIC codebases.

## Software Architecture Design Loop
The framework coordinates rendering and register tracking using a synchronous three-tiered cycle:
1. **Mouse Tracking Boundary Eval:** Catches pointer locations via `Pixels[X, Y]` against the reference color mask to toggle local node flags (`Segments[i].State`).
2. **Buffer Paint Layering:** Reloads clean baseline background layouts (`bg.bmp`) and blends active indicator fragments using bright overlay filters.
3. **Array Translation Parse:** Converts live segment status indexes into a single collective programmatic byte string payload.

## Usage
1. Place a configured `config.ini`, along with the mandatory display asset files (`bg.bmp` and `click_map.bmp`), into the compiled workspace directory.
2. Launch the utility framework. By default, all display segments are initialized in an active state.
3. Use the Left Mouse Button to click directly on display elements to turn individual segments ON or OFF.
4. Click **Add** to export the live binary-hex string directly into the historical tracking log frame. Copy the block dump code when your custom character font table is ready.

## Original Credits
Developed by **DenGame**. Released under an open-source license to preserve custom micro-hardware testing utilities.
