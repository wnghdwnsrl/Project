function SetAngle(port_num,lib_name,PROTOCOL_VERSION,DXL_ID,ADDR_MOVING_SPEED,ADDR_MX_GOAL_POSITION,dxl_goal_position, DXL_MOVING_SPEED)
    
     % Load Libraries
    if ~libisloaded(lib_name)
        [notfound, warnings] = loadlibrary(lib_name, 'dynamixel_sdk.h', 'addheader', 'port_handler.h', 'addheader', 'packet_handler.h');
    end
    write2ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_MOVING_SPEED, DXL_MOVING_SPEED);
    write2ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_MX_GOAL_POSITION, dxl_goal_position);
    
end