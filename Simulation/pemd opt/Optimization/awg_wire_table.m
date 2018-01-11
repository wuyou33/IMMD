function [Dwdg,awgno] = awg_wire_table(Dwdgmin)
wire = [
    0000 	0.46 	11.684 	0.049 	0.16072 	380 	302 	125  	6120
    000 	0.4096 	10.40384 	0.0618 	0.202704 	328 	239 	160   	4860
    00 	0.3648 	9.26592 	0.0779 	0.255512 	283 	190 	200   	3860
    0 	0.3249 	8.25246 	0.0983 	0.322424 	245 	150 	250   	3060
    1 	0.2893 	7.34822 	0.1239 	0.406392 	211 	119 	325   	2430
    2 	0.2576 	6.54304 	0.1563 	0.512664 	181 	94 	410   	1930
    3 	0.2294 	5.82676 	0.197 	0.64616 	158 	75 	500   	1530
    4 	0.2043 	5.18922 	0.2485 	0.81508 	135 	60 	650   	1210
    5 	0.1819 	4.62026 	0.3133 	1.027624 	118 	47 	810   	960
    6 	0.162 	4.1148 	0.3951 	1.295928 	101 	37 	1100   	760
    7 	0.1443 	3.66522 	0.4982 	1.634096 	89 	30 	1300   	605
    8 	0.1285 	3.2639 	0.6282 	2.060496 	73 	24 	1650   	480
    9 	0.1144 	2.90576 	0.7921 	2.598088 	64 	19 	2050   	380
    10 	0.1019 	2.58826 	0.9989 	3.276392 	55 	15 	2600   	314
    11 	0.0907 	2.30378 	1.26 	4.1328 	47 	12 	3200   	249
    12 	0.0808 	2.05232 	1.588 	5.20864 	41 	9.3 	4150   	197
    13 	0.072 	1.8288 	2.003 	6.56984 	35 	7.4 	5300   	150
    14 	0.0641 	1.62814 	2.525 	8.282 	32 	5.9 	6700   	119
    15 	0.0571 	1.45034 	3.184 	10.44352 	28 	4.7 	8250   	94
    16 	0.0508 	1.29032 	4.016 	13.17248 	22 	3.7 	11     	75
    17 	0.0453 	1.15062 	5.064 	16.60992 	19 	2.9 	13     	59
    18 	0.0403 	1.02362 	6.385 	20.9428 	16 	2.3 	17    	47
    19 	0.0359 	0.91186 	8.051 	26.40728 	14 	1.8 	21    	37
    20 	0.032 	0.8128 	10.15 	33.292 	11 	1.5 	27    	29
    21 	0.0285 	0.7239 	12.8 	41.984 	9 	1.2 	33    	23
    22 	0.0253 	0.64516 	16.14 	52.9392 	7 	0.92 	42    	18
    23 	0.0226 	0.57404 	20.36 	66.7808 	4.7 	0.729 	53    	14.5
    24 	0.0201 	0.51054 	25.67 	84.1976 	3.5 	0.577 	68    	11.5
    25 	0.0179 	0.45466 	32.37 	106.1736 	2.7 	0.457 	85    	9
    26 	0.0159 	0.40386 	40.81 	133.8568 	2.2 	0.361 	107    	7.2
    27 	0.0142 	0.36068 	51.47 	168.8216 	1.7 	0.288 	130    	5.5
    28 	0.0126 	0.32004 	64.9 	212.872 	1.4 	0.226 	170    	4.5
    29 	0.0113 	0.28702 	81.83 	268.4024 	1.2 	0.182 	210    	3.6
    30 	0.01 	0.254 	103.2 	338.496 	0.86 	0.142 	270    	2.75
    31 	0.0089 	0.22606 	130.1 	426.728 	0.7 	0.113 	340    	2.25
    32 	0.008 	0.2032 	164.1 	538.248 	0.53 	0.091 	430    	1.8
    ];
i = 37;
while(1)
    i = i-1;
    if Dwdgmin < wire(i,3)
        Dwdg = wire(i,3);
        awgno = i-4;
        break;
    end
end

end