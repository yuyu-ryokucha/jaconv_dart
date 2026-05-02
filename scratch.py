import sys
import os
import json

sys.path.append(os.path.join(os.getcwd(), 'refs/jaconv'))

from jaconv import conv_table

def print_dict(name, d, type_decl="Map<int, String>"):
    print(f"const {type_decl} {name} = {{")
    for k, v in d.items():
        v_escaped = json.dumps(v).replace('$', '\\$')
        if k == ord("'"):
            print(f"  {k}: {v_escaped}, // '")
        elif k == ord("\\"):
            print(f"  {k}: {v_escaped}, // \\")
        else:
            try:
                print(f"  {k}: {v_escaped}, // {chr(k)}")
            except:
                print(f"  {k}: {v_escaped},")
    print("};\n")

print_dict('h2kTable', conv_table.H2K_TABLE)
print_dict('h2hkTable', conv_table.H2HK_TABLE)
print_dict('k2hTable', conv_table.K2H_TABLE)

print_dict('h2zA', conv_table.H2Z_A)
print_dict('h2zAd', conv_table.H2Z_AD)
print_dict('h2zAk', conv_table.H2Z_AK)
print_dict('h2zD', conv_table.H2Z_D)
print_dict('h2zK', conv_table.H2Z_K)
print_dict('h2zDk', conv_table.H2Z_DK)
print_dict('h2zAll', conv_table.H2Z_ALL)

print_dict('z2hA', conv_table.Z2H_A)
print_dict('z2hAd', conv_table.Z2H_AD)
print_dict('z2hAk', conv_table.Z2H_AK)
print_dict('z2hD', conv_table.Z2H_D)
print_dict('z2hK', conv_table.Z2H_K)
print_dict('z2hDk', conv_table.Z2H_DK)
print_dict('z2hAll', conv_table.Z2H_ALL)

print_dict('smallKana2NormalKana', conv_table.SMALL_KANA2NORMAL_KANA)
print_dict('kana2Hep', conv_table.KANA2HEP)
print_dict('hep2Kana', conv_table.HEP2KANA)

