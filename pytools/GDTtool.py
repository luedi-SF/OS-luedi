class GDT:
    def __init__(self, base=0, limit=0xFFFFF, segment_type="data",
                 dpl=0, present=True, granularity="4KB",
                 operation_size=32, long_mode=False, avl=0):
        """
        Initialize a GDT descriptor with customizable parameters

        Parameters:
        base (int)          : Linear base address (default 0)
        limit (int)         : Segment limit value (default 0xFFFFF)
        segment_type (str)  : "code", "data", or "system"
        dpl (int)           : Privilege level (0-3, default 0)
        present (bool)      : Segment presence (default True)
        granularity (str)   : "byte" or "4KB" (default "4KB")
        operation_size (int): 16 or 32 (default 32) D/B
        long_mode (bool)    : 64-bit mode (default False)
        avl (int)           : Available bit (0 or 1, default 0)

        For system segments, additional parameters can be set via setSYSTEM()
        """
        # Validate inputs
        if not (0 <= base <= 0xFFFFFFFF):
            raise ValueError("Base must be between 0 and 0xFFFFFFFF")
        if not (0 <= limit <= 0xFFFFF):
            raise ValueError("Limit must be between 0 and 0xFFFFF (20-bit value)")
        if segment_type not in ["code", "data", "system"]:
            raise ValueError("Segment type must be 'code', 'data', or 'system'")
        if dpl not in [0, 1, 2, 3]:
            raise ValueError("DPL must be 0, 1, 2, or 3")
        if operation_size not in [16, 32]:
            raise ValueError("Operation size must be 16 or 32")

        # Set binary fields directly
        self.AVL = str(avl)
        self.L = "1" if long_mode else "0"
        self.G = "1" if granularity == "4KB" else "0"
        self.P = "1" if present else "0"
        self.S = "1" if segment_type in ["code", "data"] else "0"
        self.DB = "1" if operation_size == 32 else "0"

        # Convert DPL to 2-bit representation
        self.DPL = format(dpl, '02b')

        # Set base and limit
        self.BASE = format(base, '032b')
        self.LIMIT = format(limit, '020b')

        # Set defaults for access byte based on segment type
        if segment_type == "code":
            # Default: Execute-only, non-conforming
            self.TYPE = "0000"  # Will be set in setCODE()
            self.setCODE(E="1", DC="0", RW="0", A="0")
        elif segment_type == "data":
            # Default: Read-only, expand-up
            self.TYPE = "0000"  # Will be set in setDATA()
            self.setDATA(E="0", DC="0", RW="0", A="0")
        else:  # system
            # Default: Reserved type
            self.TYPE = "0000"
    AVL="0"                                          # Available for User
    BASE="00000000000000000000000000000000" #32-0    # A 32-bit value containing the linear address where the segment begins.
    LIMIT="00000000000000000000" #20-0               # A 20-bit value, tells the maximum addressable unit, either in 1 byte units, or in 4KiB pages. Hence, if you choose page granularity and set the Limit value to 0xFFFFF the segment will span the full 4 GiB address space in 32-bit mode.
    DB="0"                                           # Size flag. If clear (0), the descriptor defines a 16-bit protected mode segment. If set (1) it defines a 32-bit protected mode segment. A GDT can have both 16-bit and 32-bit selectors at once.
    DPL="00"                                         # Descriptor privilege level field. Contains the CPU Privilege level of the segment. 0 = highest privilege (kernel), 3 = lowest privilege (user applications).
    G="0"                                            # Granularity flag, indicates the size the Limit value is scaled by. If clear (0), the Limit is in 1 Byte blocks (byte granularity). If set (1), the Limit is in 4 KiB blocks (page granularity).
    P="0"                                            # Present bit. Allows an entry to refer to a valid segment. Must be set (1) for any valid segment.
    S="0"                                            # Descriptor type bit. If clear (0) the descriptor defines a system segment (eg. a Task State Segment). If set (1) it defines a code or data segment.
    TYPE="0000"                                      # Access Byte
    L="0"                                            # Long-mode code flag. If set (1), the descriptor defines a 64-bit code segment. When set, DB should always be clear. For any other type of segment (other code types or any data segment), it should be clear (0).
    def parseBIN(self,f,s):
        f=f[::-1]
        s=s[::-1]
        self.AVL=s[20:21]
        self.BASE=f[16:32]+s[0:8]+s[24:32]
        self.LIMIT=f[0:16]+s[16:20]
        self.DB=s[22:23]
        self.DPL=s[13:15]
        self.G=s[23:24]
        self.P=s[15:16]
        self.S=s[12:13]
        self.TYPE=s[8:12]
        self.L=s[21:22]
        return
    def parseHEX(self,s1,s2):
        dic={"0":"0000",
             "1":"0001",
             "2":"0010",
             "3":"0011",
             "4":"0100",
             "5":"0101",
             "6":"0110",
             "7":"0111",
             "8":"1000",
             "9":"1001",
             "A":"1010",
             "B":"1011",
             "C":"1100",
             "D":"1101",
             "E":"1110",
             "F":"1111",
             "a":"1010",
             "b":"1011",
             "c":"1100",
             "d":"1101",
             "e":"1110",
             "f":"1111"}
        f=""
        s=""
        for i in range(8):
            f+=dic[s1[i]]
        for i in range(8):
            s+=dic[s2[i]]
        f=f[::-1]
        s=s[::-1]
        self.AVL=s[20:21]
        self.BASE=f[16:32]+s[0:8]+s[24:32]
        self.LIMIT=f[0:16]+s[16:20]
        self.DB=s[22:23]
        self.DPL=s[13:15]
        self.G=s[23:24]
        self.P=s[15:16]
        self.S=s[12:13]
        self.TYPE=s[8:12]
        self.L=s[21:22]
        return
    def getBIN(self):
        f=self.LIMIT[0:16]+self.BASE[0:16]
        s=self.BASE[16:24]+self.TYPE+self.S+self.DPL+self.P+self.LIMIT[16:20]+self.AVL+self.L+self.DB+self.G+self.BASE[24:32]
        f=f[::-1]
        s=s[::-1]
        return (f,s)
    def getHEX(self):
        s1,s2=self.getBIN()
        f=""
        s=""
        for i in range(8):
            f+=str(hex(int(s1[i*4:i*4+4],2)))[2:]
        for i in range(8):
            s+=str(hex(int(s2[i*4:i*4+4],2)))[2:]
        return (f,s)
    #Setting function
    # 1000
    def setCODE(self, E="1", DC="0", RW="0", A="0"):
        """
        Configure access byte for code segment

        Parameters (all binary strings):
        E  : Executable (must be 1 for code)
        DC : Conforming (0=non-conforming, 1=conforming)
        RW : Readable (0=execute-only, 1=readable)
        A  : Accessed (set by CPU)
        """
        if E != "1":
            print("Warning: E should be 1 for code segments")
        self.TYPE = A + RW + DC + E
    # 0000
    def setDATA(self, E="0", DC="0", RW="0", A="0"):
        """
        Configure access byte for data segment

        Parameters (all binary strings):
        E  : Executable (must be 0 for data)
        DC : Direction (0=expand up, 1=expand down)
        RW : Writable (0=read-only, 1=writable)
        A  : Accessed (set by CPU)
        """
        if E != "0":
            print("Warning: E should be 0 for data segments")
        self.TYPE = A + RW + DC + E

    # def setSYSTEM(self, type_value):
    #     """
    #     Configure access byte for system segment
    #
    #     Parameters:
    #     type_value (int) : System descriptor type (0-15)
    #     """
    #     if self.S != "0":
    #         print("Warning: S bit should be 0 for system segments")
    #     self.TYPE = format(type_value, '04b')
    def getINFO(self):
        print("GDT Descriptor Information:")

        # BASE
        base_int = int(self.BASE, 2)
        print(f"- BASE (0x{base_int:08X}): Linear address where the segment begins")

        # LIMIT
        limit_int = int(self.LIMIT, 2)
        granularity = "4KB pages" if self.G == "1" else "bytes"
        actual_size = (limit_int + 1) * (4096 if self.G == "1" else 1)
        size_unit = "MB" if actual_size >= 1_048_576 else "KB" if actual_size >= 1024 else "bytes"
        size_value = actual_size / (1_048_576 if size_unit == "MB" else 1024 if size_unit == "KB" else 1)
        print(f"- LIMIT (0x{limit_int:05X}): Maximum addressable unit in {granularity}")
        print(f"  Actual segment size: {size_value:.2f} {size_unit}")

        # DB (Default operation size)
        db_desc = "32-bit protected mode" if self.DB == "1" else "16-bit protected mode"
        print(f"- DB ({self.DB}): Default operation size - {db_desc}")

        # DPL (Descriptor Privilege Level)
        dpl_desc = {
            "00": "Ring 0 (Highest privilege, kernel mode)",
            "01": "Ring 1",
            "10": "Ring 2",
            "11": "Ring 3 (Lowest privilege, user mode)"
        }.get(self.DPL, "Invalid privilege level")
        print(f"- DPL ({self.DPL}): Privilege level - {dpl_desc}")

        # G (Granularity)
        g_desc = "4KB granularity" if self.G == "1" else "Byte granularity"
        print(f"- G ({self.G}): Scaling factor - {g_desc}")

        # P (Present)
        p_desc = "Segment is present in memory" if self.P == "1" else "Segment is not present"
        print(f"- P ({self.P}): Presence flag - {p_desc}")

        # S (Descriptor Type)
        if self.S == "1":
            print("- S (1): Descriptor defines a code or data segment")
        else:
            print("- S (0): Descriptor defines a system segment (TSS, LDT, etc.)")

        # TYPE (Access Byte)
        access_type = ""
        if self.S == "1":  # Code/Data segment
            # Type flags decoding
            accessed = "Accessed" if self.TYPE[0] == "1" else "Not accessed"

            if self.TYPE[3] == "1":  # Code segment
                readable = "Readable" if self.TYPE[1] == "1" else "Execute-only"
                conforming = "Conforming" if self.TYPE[2] == "1" else "Non-conforming"
                access_type = f"Code segment: {accessed}, {readable}, {conforming}"
            else:  # Data segment
                writable = "Writable" if self.TYPE[1] == "1" else "Read-only"
                direction = "Expand-down (stack-like)" if self.TYPE[2] == "1" else "Expand-up"
                access_type = f"Data segment: {accessed}, {writable}, {direction}"
        else:  # System segment
            type_int = int(self.TYPE, 2)
            sys_types = {
                1: "Available 16-bit TSS",
                2: "LDT",
                3: "Busy 16-bit TSS",
                5: "Task gate",
                9: "Available 32-bit TSS",
                11: "Busy 32-bit TSS"
            }
            access_type = sys_types.get(type_int, f"System descriptor type 0x{type_int:X}")
        print(f"- TYPE -- 11:({self.TYPE[3]}),10:({self.TYPE[2]}),9:({self.TYPE[1]}),8:({self.TYPE[0]})")
        print(f"- TYPE ({self.TYPE}): Access permissions - {access_type}")

        # L (Long mode)
        if self.L == "1":
            if self.S == "1" and self.TYPE[3] == "1" and self.DB == "0":
                print("- L (1): 64-bit code segment (Long mode)")
            else:
                print("- L (1): Invalid configuration (should only be set for 64-bit code segments)")
        else:
            print("- L (0): Not a 64-bit code segment")

        # AVL (Available)
        print(f"- AVL ({self.AVL}): Available for system use (no defined function)")

    def validate(self):
        """Validate the descriptor configuration"""
        errors = []

        # Long mode validation
        if self.L == "1":
            if self.S != "1" or self.TYPE[3] != "1":
                errors.append("L=1 requires code segment (S=1, TYPE[3]=1)")
            if self.DB != "0":
                errors.append("L=1 requires DB=0")

        # System segment validation
        if self.S == "0" and self.L == "1":
            errors.append("System segments cannot have L=1")

        # Granularity check
        if self.G == "1" and int(self.LIMIT, 2) < 0xFFF:
            errors.append("Limit < 0xFFF with G=1 may cause problems")

        # Operation size consistency
        if self.DB == "0" and self.L == "0" and self.S == "1":
            errors.append("16-bit segments not properly configured")

        return errors if errors else "Valid descriptor"
