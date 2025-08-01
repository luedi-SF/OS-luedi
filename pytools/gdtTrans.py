
from GDTtool import GDT

if __name__ == '__main__':
    codeGDT=GDT(base=0,
                limit=0xFFFFF,
                segment_type="code",
                dpl=0,
                present=True,
                granularity="byte",
                operation_size=32,
                long_mode=False,
                avl=0)
    codeGDT.setCODE()
    codeGDT.getINFO()
    print(codeGDT.getHEX()[0][::-1])
    print(codeGDT.getHEX()[1][::-1])
    print(codeGDT.validate())
    dataGDT=GDT(base=0,
                limit=0xFFFFF,
                segment_type="data",
                dpl=0,
                present=True,
                granularity="4KB",
                operation_size=32,
                long_mode=False,
                avl=0)
    dataGDT.setDATA("0","1")
    dataGDT.getINFO()
    print(dataGDT.getHEX()[0][::-1])
    print(dataGDT.getHEX()[1][::-1])
    print(dataGDT.validate())
