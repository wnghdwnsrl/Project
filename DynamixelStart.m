function DynamixelStart(lib_name, port_num, BAUDRATE, PROTOCOL_VERSION, DXL_ID, ADDR_MX_TORQUE_ENABLE, TORQUE_ENABLE)
    % Load Libraries
    if ~libisloaded(lib_name)
        [notfound, warnings] = loadlibrary(lib_name, 'dynamixel_sdk.h', 'addheader', 'port_handler.h', 'addheader', 'packet_handler.h');
    end

   % Initialize PortHandler Structs
   

    % Initialize PacketHandler Structs
    packetHandler();

    % Open port
    if (openPort(port_num))
        fprintf('Succeeded to open the port!\n');
    else
        unloadlibrary(lib_name);
        fprintf('Failed to open the port!\n');
        input('Press any key to terminate...\n');
        return;
    end


    % Set port baudrate
    if (setBaudRate(port_num, BAUDRATE))
        fprintf('Succeeded to change the baudrate!\n');
    else
        unloadlibrary(lib_name);
        fprintf('Failed to change the baudrate!\n');
        input('Press any key to terminate...\n');
        return;
    end
    % Enable Dynamixel Torque
    write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_MX_TORQUE_ENABLE, TORQUE_ENABLE);
    
    
end