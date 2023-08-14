## device module
![at24c256](https://github.com/Taeho-Cho/FPGA/assets/57129682/b466a221-2657-4e11-b12b-514313c54400)
> [AT24C256](https://pdf1.alldatasheet.co.kr/datasheet-pdf/view/574755/ATMEL/AT24C256.html)

## AXI Lite slave IP
> create an IP from the AXI_Lite_slv.sv file for memery mapping

## RTL file tree
```
AT24C256_wrapper.v
└── AT24C256_I2C.sv
    └── prescaler.sv
```
wrap the RTL.sv files to add into the DB

## AT24C256 commands
![ByteWrite](https://github.com/Taeho-Cho/FPGA/assets/57129682/a2293599-5a30-4ae5-adce-46762bcc0950)
![RandomRead](https://github.com/Taeho-Cho/FPGA/assets/57129682/d8bf3a57-caf5-4540-bd90-63470a2891d6)
these commands can be found in the datasheet

## Simulation
> Byte Write command simulation
![BWS](https://github.com/Taeho-Cho/FPGA/assets/57129682/5783386e-6714-4edf-9a6b-4f41c4bac1da)


> Random Read command simulation
![RRW](https://github.com/Taeho-Cho/FPGA/assets/57129682/60e75774-2caf-4b5c-882a-e5499478fe2e)


## Block Diagram
![BD](https://github.com/Taeho-Cho/FPGA/assets/57129682/851de8ad-0d94-4a57-80a8-ac0e4c1a2464)

## 
