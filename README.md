# Miyamii-4000

yeah so this is a 4-bit processor i guess. like it does processor things but with 4 bits at a time lmao

## what even is this

its basically a tiny cpu that runs on 4 bits. inspired by the intel 4004 cuz that was also 4-bit and apparently good enough to send people to the moon or whatever. this one probably cant do that but it can count and do math i think

- 4-bit data path (so like... 0-15 max)
- 45 something instructions
- has registers and stuff
- can jump around in code
- made in verilog for some reason

## quick start i guess

wanna run it? just do this:

```bash
make sim      # runs the thing
make view     # look at some waveforms
make lint     # check if i messed up
```

for the openlane asic flow thing just run `./run_openlane.sh` and pray it works

## where to find actual info

look i cant be bothered to write everything here so just check these out:

- [docs/README.md](docs/README.md) - has all the detailed architecture stuff
- [docs/INSTRUCTION_SET.md](docs/INSTRUCTION_SET.md) - lists all the instructions and what they do
- [docs/ARCHITECTURE_DIAGRAM.md](docs/ARCHITECTURE_DIAGRAM.md) - pretty pictures of how things connect
- [docs/OPENLANE_GUIDE.md](docs/OPENLANE_GUIDE.md) - if you wanna make an actual chip
- [QUICKSTART.md](QUICKSTART.md) - getting started guide
- [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) - summary of the whole thing
- [CHECKLIST.md](CHECKLIST.md) - checklist for openlane flow

## examples

theres some assembly examples in the `examples/` folder:
- fibonacci.asm - makes fibonacci numbers
- bcd_counter.asm - counts in bcd i think

use the assembler in `tools/assembler.py` to turn them into machine code or whatever

## the important bits

```
src/              - all the verilog files
openlane/         - config for making chips
docs/             - where the real documentation lives
examples/         - example programs
tools/            - assembler and stuff
```

## does it work

yeah mostly. probably. i mean it runs in simulation so thats something

## license

do whatever you want with it idk. its for learning or whatever

---

made for a high school project that got way too complicated
