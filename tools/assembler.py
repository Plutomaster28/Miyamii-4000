#!/usr/bin/env python3
"""
Simple assembler for Miyamii-4000 Processor
Converts assembly mnemonics to binary opcodes

Usage: python3 assembler.py input.asm output.hex
"""

import sys
import re

# Instruction opcodes
OPCODES = {
    # Single byte instructions
    'NOP': 0x00,
    'CLB': 0xF0, 'CLC': 0xF1, 'IAC': 0xF2, 'CMC': 0xF3,
    'CMA': 0xF4, 'RAL': 0xF5, 'RAR': 0xF6, 'TCC': 0xF7,
    'DAC': 0xF8, 'TCS': 0xF9, 'STC': 0xFA, 'DAA': 0xFB,
    'KBP': 0xFC, 'DCL': 0xFD,
    
    # I/O instructions
    'WRM': 0xE0, 'WMP': 0xE1, 'WRR': 0xE2, 'WPM': 0xE3,
    'WR0': 0xE4, 'WR1': 0xE5, 'WR2': 0xE6, 'WR3': 0xE7,
    'SBM': 0xE8, 'RDM': 0xE9, 'RDR': 0xEA, 'ADM': 0xEB,
    'RD0': 0xEC, 'RD1': 0xED, 'RD2': 0xEE, 'RD3': 0xEF,
    
    # Two-byte instruction prefixes
    'JCN': 0x10, 'FIM': 0x20, 'SRC': 0x21, 'FIN': 0x30,
    'JIN': 0x31, 'JUN': 0x40, 'JMS': 0x50, 'INC': 0x60,
    'ISZ': 0x70, 'ADD': 0x80, 'SUB': 0x90, 'LD': 0xA0,
    'XCH': 0xB0, 'BBL': 0xC0, 'LDM': 0xD0,
}

# Condition codes for JCN
CONDITIONS = {
    'NZ': 0x1,   # Not zero (invert zero check)
    'Z': 0x2,    # Zero
    'NC': 0x5,   # No carry (invert carry check)
    'C': 0x4,    # Carry
    'NT': 0x9,   # Not test (invert test check)
    'T': 0x8,    # Test
}

def parse_line(line):
    """Parse a single line of assembly code"""
    # Remove comments
    if ';' in line:
        line = line[:line.index(';')]
    
    # Strip whitespace
    line = line.strip()
    
    if not line:
        return None
    
    # Check for label
    label = None
    if ':' in line:
        label, line = line.split(':', 1)
        label = label.strip()
        line = line.strip()
    
    if not line:
        return {'type': 'label', 'label': label}
    
    # Parse instruction
    parts = re.split(r'[,\s]+', line)
    mnemonic = parts[0].upper()
    operands = parts[1:] if len(parts) > 1 else []
    
    return {
        'type': 'instruction',
        'label': label,
        'mnemonic': mnemonic,
        'operands': operands
    }

def assemble_instruction(instr, labels, address):
    """Convert instruction to machine code"""
    mnemonic = instr['mnemonic']
    operands = instr['operands']
    
    # Single-byte instructions without operands
    if mnemonic in ['NOP', 'CLB', 'CLC', 'IAC', 'CMC', 'CMA', 'RAL', 'RAR',
                    'TCC', 'DAC', 'TCS', 'STC', 'DAA', 'KBP', 'DCL',
                    'WRM', 'WMP', 'WRR', 'WPM', 'SBM', 'RDM', 'RDR', 'ADM',
                    'WR0', 'WR1', 'WR2', 'WR3', 'RD0', 'RD1', 'RD2', 'RD3']:
        return [OPCODES[mnemonic]]
    
    # Instructions with register operand
    if mnemonic in ['INC', 'ADD', 'SUB', 'LD', 'XCH']:
        reg = int(operands[0])
        return [OPCODES[mnemonic] | (reg & 0xF)]
    
    # LDM and BBL with immediate
    if mnemonic in ['LDM', 'BBL']:
        imm = parse_number(operands[0])
        return [OPCODES[mnemonic] | (imm & 0xF)]
    
    # JCN - conditional jump
    if mnemonic == 'JCN':
        cond = CONDITIONS.get(operands[0].upper(), 0)
        addr = parse_address(operands[1], labels)
        return [OPCODES[mnemonic] | cond, addr & 0xFF]
    
    # JUN, JMS - unconditional jump/call
    if mnemonic in ['JUN', 'JMS']:
        addr = parse_address(operands[0], labels)
        return [OPCODES[mnemonic] | ((addr >> 8) & 0xF), addr & 0xFF]
    
    # FIM - fetch immediate to register pair
    if mnemonic == 'FIM':
        pair = int(operands[0])
        imm = parse_number(operands[1])
        return [0x20 | ((pair & 0x7) << 1), imm & 0xFF]
    
    # SRC - send register control
    if mnemonic == 'SRC':
        pair = int(operands[0])
        return [0x20 | ((pair & 0x7) << 1) | 1]
    
    # JIN, FIN
    if mnemonic in ['JIN', 'FIN']:
        pair = int(operands[0])
        base = 0x30 if mnemonic == 'FIN' else 0x30
        offset = 0 if mnemonic == 'FIN' else 1
        return [base | ((pair & 0x7) << 1) | offset]
    
    # ISZ - increment and skip if zero
    if mnemonic == 'ISZ':
        reg = int(operands[0])
        addr = parse_address(operands[1], labels)
        return [0x70 | (reg & 0xF), addr & 0xFF]
    
    raise ValueError(f"Unknown instruction: {mnemonic}")

def parse_number(s):
    """Parse a number (decimal or hex)"""
    s = s.strip()
    if s.startswith('0x') or s.startswith('0X'):
        return int(s, 16)
    elif s.startswith('0b') or s.startswith('0B'):
        return int(s, 2)
    else:
        return int(s)

def parse_address(s, labels):
    """Parse an address (number or label)"""
    s = s.strip()
    if s in labels:
        return labels[s]
    return parse_number(s)

def assemble(input_file, output_file):
    """Main assembler function"""
    # First pass: collect labels
    labels = {}
    instructions = []
    address = 0
    
    with open(input_file, 'r') as f:
        for line_num, line in enumerate(f, 1):
            parsed = parse_line(line)
            if not parsed:
                continue
            
            if parsed['type'] == 'label':
                labels[parsed['label']] = address
            elif parsed['type'] == 'instruction':
                if parsed['label']:
                    labels[parsed['label']] = address
                instructions.append((address, parsed, line_num))
                
                # Estimate instruction size
                if parsed['mnemonic'] in ['JCN', 'JUN', 'JMS', 'FIM', 'ISZ']:
                    address += 2
                else:
                    address += 1
    
    # Second pass: generate machine code
    machine_code = [0] * 4096  # 4K ROM
    
    for addr, instr, line_num in instructions:
        try:
            bytes_out = assemble_instruction(instr, labels, addr)
            for i, byte in enumerate(bytes_out):
                machine_code[addr + i] = byte
        except Exception as e:
            print(f"Error on line {line_num}: {e}")
            sys.exit(1)
    
    # Write output in hex format
    with open(output_file, 'w') as f:
        for i in range(0, len(machine_code), 16):
            hex_bytes = ' '.join(f'{b:02X}' for b in machine_code[i:i+16])
            f.write(f'{i:04X}: {hex_bytes}\n')
    
    print(f"Assembly complete!")
    print(f"Labels: {labels}")
    print(f"Output written to {output_file}")

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: python3 assembler.py input.asm output.hex")
        sys.exit(1)
    
    assemble(sys.argv[1], sys.argv[2])
