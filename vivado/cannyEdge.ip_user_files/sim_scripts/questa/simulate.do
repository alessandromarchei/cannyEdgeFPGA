onbreak {quit -f}
onerror {quit -f}

vsim  -lib xil_defaultlib conv_block_gaussian_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {conv_block_gaussian.udo}

run 1000ns

quit -force
