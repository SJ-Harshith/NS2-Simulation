# Initialize the simulator
set ns [new Simulator]

# Create trace and NAM output files
set f [open out.tr w]
set nf [open out.nam w]
$ns trace-all $f
$ns namtrace-all $nf

# Define the finish procedure
proc finish {} {
    global f nf ns
    $ns flush-trace
    close $f
    close $nf
    exec nam out.nam &
    exec awk -f analyze_packets.awk out.tr &
    exit 0
}

# Create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

# Label the nodes
$n0 label "TCP Source"
$n1 label "UDP Source"
$n2 label "Sink"

# Set colors for packet classes
$ns color 1 red
$ns color 2 yellow

# Create the topology
$ns duplex-link $n0 $n1 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 1.75Mb 20ms DropTail
$ns queue-limit $n1 $n2 10

# Orient links for visualization in NAM
$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $n2 orient right

# Define UDP (CBR) traffic
set udp0 [new Agent/UDP]
set cbr0 [new Application/Traffic/CBR]
$ns attach-agent $n1 $udp0
$cbr0 attach-agent $udp0
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$udp0 set class_ 1

# Define TCP traffic
set tcp0 [new Agent/TCP]
set ftp0 [new Application/FTP]
$ns attach-agent $n0 $tcp0
$ftp0 attach-agent $tcp0
$ftp0 set maxPkts_ 1000
$tcp0 set class_ 2

# Define the TCP sink
set sink [new Agent/TCPSink]
$ns attach-agent $n2 $sink
$ns connect $tcp0 $sink

# Connect UDP (CBR) traffic to the sink
set null0 [new Agent/Null]
$ns attach-agent $n2 $null0
$ns connect $udp0 $null0

# Schedule events
$ns at 0.1 "$cbr0 start"
$ns at 1.0 "$ftp0 start"
$ns at 4.0 "$ftp0 stop"
$ns at 4.5 "$cbr0 stop"
$ns at 5.0 "finish"

# Run the simulation
$ns run
