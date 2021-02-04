function DynamixelEnd(lib_name, port_num)
    
     % Load Libraries
    if ~libisloaded(lib_name)
        [notfound, warnings] = loadlibrary(lib_name, 'dynamixel_sdk.h', 'addheader', 'port_handler.h', 'addheader', 'packet_handler.h');
    end
    
    % Close port
        closePort(port_num);

        % Unload Library
        unloadlibrary(lib_name);
end
