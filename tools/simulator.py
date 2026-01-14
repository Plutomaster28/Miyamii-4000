#!/usr/bin/env python3
"""
Miyamii-4000 Processor Simulator
Simulates the execution of assembled programs for proof of concept

Usage: python3 simulator.py program.hex [--steps N] [--auto]
"""

import sys
import time

class Miyamii4000:
    def __init__(self):
        # 4-bit registers (16 registers)
        self.registers = [0] * 16
        # 4-bit accumulator
        self.acc = 0
        # Carry flag
        self.carry = 0
        # Program counter (12-bit)
        self.pc = 0
        # 4K ROM
        self.rom = [0] * 4096
        # RAM (not fully implemented, just for demo)
        self.ram = [0] * 256
        # Stack for subroutines
        self.stack = []
        # Output buffer
        self.output = []
        # Running flag
        self.running = True
        # Instruction count
        self.inst_count = 0
        
    def load_hex(self, filename):
        """Load hex file into ROM"""
        with open(filename, 'r') as f:
            for line in f:
                if ':' not in line:
                    continue
                parts = line.split(':')
                addr = int(parts[0], 16)
                bytes_str = parts[1].strip().split()
                for i, byte_str in enumerate(bytes_str):
                    self.rom[addr + i] = int(byte_str, 16)
        print(f"✓ Loaded program from {filename}")
        
    def fetch(self):
        """Fetch next instruction"""
        instr = self.rom[self.pc]
        self.pc = (self.pc + 1) & 0xFFF
        return instr
        
    def execute(self, opcode):
        """Execute one instruction"""
        self.inst_count += 1
        
        # Decode opcode
        high_nibble = (opcode >> 4) & 0xF
        low_nibble = opcode & 0xF
        
        mnemonic = "???"
        details = ""
        
        # Single-byte instructions
        if opcode == 0x00:
            mnemonic = "NOP"
            
        elif opcode == 0xF0:  # CLB
            mnemonic = "CLB"
            self.acc = 0
            self.carry = 0
            details = "acc=0, carry=0"
            
        elif opcode == 0xF1:  # CLC
            mnemonic = "CLC"
            self.carry = 0
            details = "carry=0"
            
        elif opcode == 0xF2:  # IAC
            mnemonic = "IAC"
            self.acc = (self.acc + 1) & 0xF
            if self.acc == 0:
                self.carry = 1
            details = f"acc={self.acc}, carry={self.carry}"
            
        elif opcode == 0xF3:  # CMC
            mnemonic = "CMC"
            self.carry = 1 - self.carry
            details = f"carry={self.carry}"
            
        elif opcode == 0xF4:  # CMA
            mnemonic = "CMA"
            self.acc = (~self.acc) & 0xF
            details = f"acc={self.acc}"
            
        elif opcode == 0xF5:  # RAL
            mnemonic = "RAL"
            old_carry = self.carry
            self.carry = (self.acc >> 3) & 1
            self.acc = ((self.acc << 1) | old_carry) & 0xF
            details = f"acc={self.acc}, carry={self.carry}"
            
        elif opcode == 0xF6:  # RAR
            mnemonic = "RAR"
            old_carry = self.carry
            self.carry = self.acc & 1
            self.acc = ((self.acc >> 1) | (old_carry << 3)) & 0xF
            details = f"acc={self.acc}, carry={self.carry}"
            
        elif opcode == 0xF7:  # TCC
            mnemonic = "TCC"
            self.acc = self.carry
            self.carry = 0
            details = f"acc={self.acc}, carry=0"
            
        elif opcode == 0xF8:  # DAC
            mnemonic = "DAC"
            self.acc = (self.acc - 1) & 0xF
            details = f"acc={self.acc}"
            
        elif opcode == 0xFB:  # DAA
            mnemonic = "DAA"
            if self.acc > 9 or self.carry:
                self.acc = (self.acc + 6) & 0xF
                if self.acc < 6:
                    self.carry = 1
            details = f"acc={self.acc}, carry={self.carry}"
            
        elif opcode == 0xE2:  # WRR
            mnemonic = "WRR"
            self.output.append(self.acc)
            details = f"output={self.acc}"
            print(f"    OUTPUT: {self.acc} (0x{self.acc:X})")
            
        # Register operations
        elif high_nibble == 0x6:  # INC
            reg = low_nibble
            mnemonic = f"INC R{reg}"
            self.registers[reg] = (self.registers[reg] + 1) & 0xF
            details = f"R{reg}={self.registers[reg]}"
            
        elif high_nibble == 0x8:  # ADD
            reg = low_nibble
            mnemonic = f"ADD R{reg}"
            result = self.acc + self.registers[reg] + self.carry
            self.carry = 1 if result > 15 else 0
            self.acc = result & 0xF
            details = f"acc={self.acc}, carry={self.carry}"
            
        elif high_nibble == 0x9:  # SUB
            reg = low_nibble
            mnemonic = f"SUB R{reg}"
            result = self.acc - self.registers[reg]
            if result < 0:
                result += 16
                self.carry = 1
            else:
                self.carry = 0
            self.acc = result & 0xF
            details = f"acc={self.acc}, carry={self.carry}"
            
        elif high_nibble == 0xA:  # LD
            reg = low_nibble
            mnemonic = f"LD R{reg}"
            self.acc = self.registers[reg]
            details = f"acc={self.acc}"
            
        elif high_nibble == 0xB:  # XCH
            reg = low_nibble
            mnemonic = f"XCH R{reg}"
            temp = self.acc
            self.acc = self.registers[reg]
            self.registers[reg] = temp
            details = f"acc={self.acc}, R{reg}={self.registers[reg]}"
            
        elif high_nibble == 0xC:  # BBL
            data = low_nibble
            mnemonic = f"BBL {data}"
            if self.stack:
                self.pc = self.stack.pop()
            self.acc = data
            details = f"return, acc={data}"
            
        elif high_nibble == 0xD:  # LDM
            data = low_nibble
            mnemonic = f"LDM {data}"
            self.acc = data
            details = f"acc={data}"
            
        elif high_nibble == 0x4:  # JUN
            addr_high = low_nibble
            addr_low = self.fetch()
            addr = (addr_high << 8) | addr_low
            mnemonic = f"JUN 0x{addr:03X}"
            self.pc = addr
            details = f"jump to 0x{addr:03X}"
            
        elif high_nibble == 0x5:  # JMS
            addr_high = low_nibble
            addr_low = self.fetch()
            addr = (addr_high << 8) | addr_low
            mnemonic = f"JMS 0x{addr:03X}"
            self.stack.append(self.pc)
            self.pc = addr
            details = f"call 0x{addr:03X}"
            
        elif high_nibble == 0x1:  # JCN
            cond = low_nibble
            addr = self.fetch()
            cond_name = ""
            jump = False
            
            if cond & 0x2:  # Zero
                cond_name = "Z" if (cond & 0x1) == 0 else "NZ"
                jump = (self.acc == 0) if (cond & 0x1) == 0 else (self.acc != 0)
            elif cond & 0x4:  # Carry
                cond_name = "C" if (cond & 0x1) == 0 else "NC"
                jump = (self.carry == 1) if (cond & 0x1) == 0 else (self.carry == 0)
                
            mnemonic = f"JCN {cond_name}, 0x{addr:02X}"
            if jump:
                self.pc = addr
                details = f"condition TRUE, jump to 0x{addr:02X}"
            else:
                details = f"condition FALSE, continue"
                
        elif high_nibble == 0x7:  # ISZ
            reg = low_nibble
            addr = self.fetch()
            mnemonic = f"ISZ R{reg}, 0x{addr:02X}"
            self.registers[reg] = (self.registers[reg] + 1) & 0xF
            if self.registers[reg] != 0:
                self.pc = addr
                details = f"R{reg}={self.registers[reg]}, skip to 0x{addr:02X}"
            else:
                details = f"R{reg}=0, continue"
                
        elif high_nibble == 0x2:  # FIM/SRC
            if low_nibble & 1:  # SRC
                pair = (low_nibble >> 1) & 0x7
                mnemonic = f"SRC P{pair}"
                details = "send register control"
            else:  # FIM
                pair = (low_nibble >> 1) & 0x7
                data = self.fetch()
                mnemonic = f"FIM P{pair}, 0x{data:02X}"
                self.registers[pair * 2] = (data >> 4) & 0xF
                self.registers[pair * 2 + 1] = data & 0xF
                details = f"R{pair*2}={self.registers[pair*2]}, R{pair*2+1}={self.registers[pair*2+1]}"
        
        return mnemonic, details
        
    def print_state(self, mnemonic, details):
        """Print current processor state"""
        print(f"\n{'='*70}")
        print(f"Instruction #{self.inst_count}: {mnemonic}")
        if details:
            print(f"  → {details}")
        print(f"PC: 0x{self.pc:03X}  |  ACC: {self.acc} (0x{self.acc:X})  |  CARRY: {self.carry}")
        
        # Print registers in groups of 4
        print("Registers:")
        for i in range(0, 16, 4):
            reg_str = "  "
            for j in range(4):
                r = i + j
                reg_str += f"R{r:2d}={self.registers[r]:X}  "
            print(reg_str)
            
        if self.output:
            print(f"Output Buffer: {[f'0x{x:X}' for x in self.output[-8:]]}")  # Show last 8 outputs
            
    def run_interactive(self):
        """Run in interactive step mode"""
        print("\n" + "="*70)
        print("MIYAMII-4000 SIMULATOR - Interactive Mode")
        print("="*70)
        print("Commands: [Enter]=step, 'r'=run, 'q'=quit")
        
        while self.running and self.pc < 4096:
            opcode = self.fetch()
            
            # Check for halt condition (JUN to self)
            if opcode == 0x40 and self.rom[self.pc] == self.pc - 1:
                print("\nHalt detected (infinite loop)")
                break
                
            mnemonic, details = self.execute(opcode)
            self.print_state(mnemonic, details)
            
            # Get user input
            cmd = input("\n> ").strip().lower()
            if cmd == 'q':
                break
            elif cmd == 'r':
                return self.run_auto()
                
    def run_auto(self, max_steps=1000):
        """Run automatically with delays"""
        print("\n Running automatically...")
        steps = 0
        
        while self.running and self.pc < 4096 and steps < max_steps:
            opcode = self.fetch()
            
            # Check for halt condition
            if opcode == 0x40 and self.rom[self.pc] == self.pc - 1:
                print("\nHalt detected (infinite loop)")
                break
                
            mnemonic, details = self.execute(opcode)
            self.print_state(mnemonic, details)
            
            steps += 1
            time.sleep(0.3)  # Delay for visibility
            
        print(f"\n✓ Execution complete: {steps} steps")
        return steps

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 simulator.py program.hex [--auto] [--steps N]")
        sys.exit(1)
        
    sim = Miyamii4000()
    sim.load_hex(sys.argv[1])
    
    auto_mode = '--auto' in sys.argv
    max_steps = 1000
    
    if '--steps' in sys.argv:
        idx = sys.argv.index('--steps')
        if idx + 1 < len(sys.argv):
            max_steps = int(sys.argv[idx + 1])
    
    if auto_mode:
        sim.run_auto(max_steps)
    else:
        sim.run_interactive()
        
    print("\n" + "="*70)
    print("SIMULATION SUMMARY")
    print("="*70)
    print(f"Total instructions executed: {sim.inst_count}")
    print(f"Final accumulator: {sim.acc} (0x{sim.acc:X})")
    print(f"Final carry: {sim.carry}")
    print(f"Output values: {sim.output}")
    print(f"Final register state: {[f'R{i}={sim.registers[i]:X}' for i in range(16)]}")

if __name__ == '__main__':
    main()
