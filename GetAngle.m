function dxl_present_position = GetAngle(lib_name,port_num, PROTOCOL_VERSION, DXL_ID, ADDR_MX_PRESENT_POSITION)

         % Load Libraries
    if ~libisloaded(lib_name)
        [notfound, warnings] = loadlibrary(lib_name, 'dynamixel_sdk.h', 'addheader', 'port_handler.h', 'addheader', 'packet_handler.h');
    end
        
        dxl_present_position = read2ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_MX_PRESENT_POSITION)*0.088;
        
end