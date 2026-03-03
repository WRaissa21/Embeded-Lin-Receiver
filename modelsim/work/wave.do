onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned -radixshowbase 0 /test_bench_fin/CnD
add wave -noupdate -radix unsigned -radixshowbase 0 /test_bench_fin/Cs_bar
add wave -noupdate -radix unsigned -radixshowbase 0 /test_bench_fin/Data_Bus
add wave -noupdate -radix unsigned -radixshowbase 0 /test_bench_fin/M_Received
add wave -noupdate -radix unsigned -radixshowbase 0 /test_bench_fin/Master_Clk
add wave -noupdate -radix unsigned -radixshowbase 0 /test_bench_fin/Reset_bar
add wave -noupdate -radix unsigned -radixshowbase 0 /test_bench_fin/RnW
add wave -noupdate -radix unsigned -radixshowbase 0 /test_bench_fin/lin
add wave -noupdate -radix unsigned -radixshowbase 0 /test_bench_fin/U_0/OP_part/U_0/NextState
add wave -noupdate -radix unsigned -radixshowbase 0 /test_bench_fin/U_0/OP_part/U_0/CurrentState
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2229448 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {334155 ns} {5245571 ns}
