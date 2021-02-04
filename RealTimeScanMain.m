%%Control table
%library
    lib_name = '';

        if strcmp(computer, 'PCWIN')
          lib_name = 'dxl_x86_c';
        elseif strcmp(computer, 'PCWIN64')
          lib_name = 'dxl_x64_c';
        elseif strcmp(computer, 'GLNX86')
          lib_name = 'libdxl_x86_c';
        elseif strcmp(computer, 'GLNXA64')
          lib_name = 'libdxl_x64_c';
        elseif strcmp(computer, 'MACI64')
          lib_name = 'libdxl_mac_c';
        end
        % Load Libraries
    if ~libisloaded(lib_name)
        [notfound, warnings] = loadlibrary(lib_name, 'dynamixel_sdk.h', 'addheader', 'port_handler.h', 'addheader', 'packet_handler.h');
    end
 % Control table address
    ADDR_MX_TORQUE_ENABLE       = 24;           % Control table address is different in Dynamixel model
    ADDR_MX_GOAL_POSITION       = 30;
    ADDR_MX_PRESENT_POSITION    = 36;
    ADDR_MX_GOAL_SPEED          = 32;           %골 속도
    ADDR_MX_PRESENT_SPEED       = 38;           %지금 속도
    ADDR_MOVING_SPEED           = 32;

    % Protocol version
    PROTOCOL_VERSION            = 1.0;          % See which protocol version is used in the Dynamixel

    % Default setting
    DXL_ID                      = 1;            % Dynamixel ID: 1
    BAUDRATE                    = 115200;
    DEVICENAME                  = 'COM7';       % Check which port is being used on your controller
                                                % ex) Windows: 'COM1'   Linux: '/dev/ttyUSB0' Mac: '/dev/tty.usbserial-*'

    TORQUE_ENABLE               = 1;            % Value for enabling the torque
    TORQUE_DISABLE              = 0;            % Value for disabling the torque
    DXL_MINIMUM_POSITION_VALUE  = 1500;          % Dynamixel will rotate between this value
    DXL_MAXIMUM_POSITION_VALUE  = 2500;         % and this value (note that the Dynamixel would not move when the position value is out of movable range. Check e-manual about the range of the Dynamixel you use.)
    DXL_MINIMUM_SPEED_VALUE     = 0;
    DXL_MAXIMUM_SPEED_VALUE     = 2047;
    DXL_MOVING_SPEED=100;

    DXL_MOVING_STATUS_THRESHOLD = 10;           % Dynamixel moving status threshold

    ESC_CHARACTER               = 'e';          % Key for escaping loop

    COMM_SUCCESS                = 0;            % Communication Success result value
    COMM_TX_FAIL                = -1001;        % Communication Tx Failed
        % Initialize PortHandler Structs
    % Set the port path
    % Get methods and members of PortHandlerLinux or PortHandlerWindows
    port_num = portHandler(DEVICENAME);

    % Initialize PacketHandler Structs
    packetHandler();
    index = 1;
    dxl_comm_result = COMM_TX_FAIL;             % Communication result
    dxl_goal_position = [DXL_MINIMUM_POSITION_VALUE DXL_MAXIMUM_POSITION_VALUE];         % Goal position
    dxl_goal_speed =[DXL_MINIMUM_SPEED_VALUE DXL_MAXIMUM_SPEED_VALUE];

    dxl_error = 0;                              % Dynamixel error
    dxl_present_position = 0;                   % Present position
    dxl_present_speed = 0;                      % present velocity
    
    
%% Main funtion
DynamixelStart(lib_name, port_num, BAUDRATE, PROTOCOL_VERSION, DXL_ID, ADDR_MX_TORQUE_ENABLE, TORQUE_ENABLE);
pRPLIDAR = RPLIDARinit();
dxl_direction=1;%
cloud_data=zeros(3,0);

%% RPLIDAR / Dynamixel 엔터 누르면 동작 /2월 1일/ 동작 목표: 다이나믹셀 조금씩 회전하면서 스캔하고(스캔이 있는 위치부터 되게 만들기, 반복스캔하고 멈출 수 있게 만들기
while 1
    if input('Press any key to continue! (or input e to quit!)\n', 's') == ESC_CHARACTER
        break;
    end
    
    SetAngle(port_num,lib_name,PROTOCOL_VERSION,DXL_ID,ADDR_MOVING_SPEED,ADDR_MX_GOAL_POSITION,dxl_goal_position(dxl_direction), DXL_MOVING_SPEED);
    dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
    dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
    if dxl_comm_result ~= COMM_SUCCESS
        fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
    elseif dxl_error ~= 0
        fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
    end
    
    while 1
       %좌표/각도/플롯
       dxl_present_position = GetAngle(lib_name,port_num, PROTOCOL_VERSION, DXL_ID, ADDR_MX_PRESENT_POSITION)
       [alldistances, allangles]=GetScanOneCircle(pRPLIDAR);
       point=[cosd(180 - dxl_present_position)*alldistances.*cos(allangles)+0.05*sind(180 - dxl_present_position); alldistances.*sin(allangles);sind(180 - dxl_present_position)*alldistances.*cos(allangles)-0.05*cosd(180 -dxl_present_position)];
       cloud_data=horzcat(cloud_data,point);
       ptCloud=pointCloud(transpose(cloud_data));
       ptCloud=pcdenoise(ptCloud);
       pcshow(ptCloud);
       xlim([-6 6]); ylim([-6 6]); zlim([-6 6]);
       if ~(abs(dxl_goal_position(dxl_direction)*0.088 - dxl_present_position) > DXL_MOVING_STATUS_THRESHOLD)
            break;
       end
    end
    if dxl_direction == 1
        dxl_direction = 2;
    else
        dxl_direction = 1;
    end
end
%수정 필요 한개의 점에 하나의 각도를 대입하는게 맞지만 읽는 속도가 너무 느림(2월 1일)


%%

[result]=RPLIDARend(pRPLIDAR);
clear pRPLIDAR; % unloadlibrary might fail if all the variables that use types from the library are not removed...
clear fig;
unloadlibrary('hardwarex');
DynamixelEnd(lib_name, port_num);