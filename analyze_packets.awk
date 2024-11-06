BEGIN {
    cbrPkt = 0;
    tcpPkt = 0;
}

{
    # Check for dropped packets
    if (($1 == "d") && ($5 == "cbr")) {
        cbrPkt += 1;
    }
    if (($1 == "d") && ($5 == "tcp")) {
        tcpPkt += 1;
    }
}

END {
    printf "\nNo. of CBR Packets Dropped: %d", cbrPkt;
    printf "\nNo. of TCP Packets Dropped: %d\n", tcpPkt;
}
