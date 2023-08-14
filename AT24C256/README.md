## device module
![at24c256](https://github.com/Taeho-Cho/FPGA/assets/57129682/b466a221-2657-4e11-b12b-514313c54400)
> [AT24C256](https://pdf1.alldatasheet.co.kr/datasheet-pdf/view/574755/ATMEL/AT24C256.html)

## AXI Lite slave IP
create an IP from the AXI_Lite_slv.sv file for memery mapping

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
![simul_BW](https://github.com/Taeho-Cho/FPGA/assets/57129682/57f2c450-25ad-4285-a047-7d29bd4ead17)

> Random Read command simulation
![simul_RR](https://github.com/Taeho-Cho/FPGA/assets/57129682/e027fe55-f8f5-4b97-93c7-eff6648300ac)


## Block Diagram
![BD](https://github.com/Taeho-Cho/FPGA/assets/57129682/db42c99b-d942-49af-b1c4-3320ca019a49)

## Cora-Z7 and AT24C256 connect
![CoraEEPROM](https://github.com/Taeho-Cho/FPGA/assets/57129682/41700a46-ee67-4b9d-a851-d9598297661c)

## oscilloscope waveform
> Byte Write
![BWcap](https://github.com/Taeho-Cho/FPGA/assets/57129682/987a01a3-3ffc-4099-9066-288df4dd1589)

> Random Read
![RRcap](https://github.com/Taeho-Cho/FPGA/assets/57129682/67be3b50-9fde-4beb-bcd2-21b3e7136cd7)

## Vitis debugging



1. write a value into a memory address of the AT24C256

![Vitis1](https://github.com/Taeho-Cho/FPGA/assets/57129682/16773a7b-088e-4a0d-9ec3-ab1b50daeabd)

2. read from the same memory address to see if the value is the same

![Vitis2](https://github.com/Taeho-Cho/FPGA/assets/57129682/62e511c7-61db-4eca-af16-f8d4706215c3)
