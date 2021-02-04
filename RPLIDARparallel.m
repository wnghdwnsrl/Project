function [distances, angles]=RPLIDARparallel()
    pRPLIDAR=RPLIDARinit();
    
    [distances,angles]=GetPosition(pRPLIDAR);
    
    [result]=RPLIDARend(pRPLIDAR);
    clear pRPLIDAR; % unloadlibrary might fail if all the variables that use types from the library are not removed...
    clear fig;
    unloadlibrary('hardwarex');
    Dynamixel_out(lib_name, port_num);
end