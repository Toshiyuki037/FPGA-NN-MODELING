New-Item -ItemType Directory -Force -Path build

ghdl -a src/constitution_layer.vhd
ghdl -a sim/tb_constitution_layer.vhd

ghdl -e tb_constitution_layer

ghdl -r tb_constitution_layer --vcd=build/wave.vcd