import sys
from opcodes import dict_opcodes
from iic2343 import Basys3

def read_assembly_file(file_path):
    with open(file_path, "r") as file:
        lineas = file.readlines()
    return lineas

def parse_assembly(linea):
    pass

def assemble(lineas):
    cod_maq = []
    sec_code = False
    for linea in lineas:
        linea = linea.strip()
        if linea == "CODE:":
            sec_code = True
            continue
        if sec_code and linea:
            opcode = parse_assembly(linea)
            if opcode:
                cod_maq.append(opcode)
    return cod_maq

def programar_rom(cod_maq):
    instance = Basys3()
    instance.begin(port_number=1)
    for i, code in enumerate(cod_maq):
        code_int = int(code, 2)
        code_to_bytes = code_int.to_bytes(5, "big")
        instance.write(i, bytearray(code_to_bytes))
    instance.end()

# Despues (a modo de ejemplo) se escribiran 0s en todas las lineas de la ROM y una instruccion a partir de un string
# i = 0
# while i < 2**12:
#     # Opcion 1:
#     instance.write(i, bytearray([0x00, 0x00, 0x00, 0x00, 0x00])) # Se puede escribir los bytes directamente

#     # Opcion 2:
#     inst = "111000100010011010101111010100010101"  # Tenemos la instruccion en un string
#     inst_to_int = int(inst, 2) # Se interpreta toda la instruccion como un numero entero
#     inst_to_bytes = inst_to_int.to_bytes(5, "big") # Se interpreta el numero en 5 bytes, es importante que sea de este largo
#     instance.write(i, bytearray(inst_to_bytes)) # Se crea un bytearray de la instruccion y se escribe en la placa

#     i += 1

# # Se termina la instancia de la Basys3
# instance.end()