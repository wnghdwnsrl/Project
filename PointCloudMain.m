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
    ADDR_MX_CW_ANGLE_LIMIT      = 6;
    ADDR_MX_CCW_ANGLE_LIMIT     = 8;
    ADDR_MX_TORQUE_ENABLE       = 24;           % Control table address is different in Dynamixel model
    ADDR_MX_GOAL_POSITION       = 30;
    ADDR_MX_PRESENT_POSITION    = 36;
    ADDR_MX_GOAL_SPEED          = 32;           %골 속도
    ADDR_MX_PRESENT_SPEED       = 38;           %지금 속도
    ADDR_MOVING_SPEED           = 32;
    % ADDR_BAUD_RATE = 4; 

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
    % DXL_BAUD_RATE=16;

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
% fig = figure('Position',[200 200 800 800],'NumberTitle','off');
% set(fig,'WindowStyle','Normal'); axis('on');
% scale = 6;
dxl_direction=0;%
count = 0; alldistances = []; allangles = [];
cloud_data=zeros(3,0);
Matrix_3D=zeros(0,360,3);% 3차원 행렬 생성
key = 0;
dxl_present_position = GetAngle(lib_name,port_num, PROTOCOL_VERSION, DXL_ID, ADDR_MX_PRESENT_POSITION);
% SET_ANGLE(1500,10);
%% RPLIDAR / Dynamixel 계속 작동하는 반복문
% [result] = StartScanRequestRPLIDAR(pRPLIDAR);%스캔 시작
% while (isempty(key)||(key ~= 27)) % Wait for ESC key (ASCII code 27).
%     tic
%     [result, distances, angles, bNewScan, quality] = GetScanDataResponseRPLIDAR(pRPLIDAR);    
%     alldistances = [alldistances distances]; allangles = [allangles angles]; 
%     onedata=[distances;angles;dxl_present_position];
%     if count > 1080
%        dxl_present_position = GetAngle(lib_name,port_num, PROTOCOL_VERSION, DXL_ID, ADDR_MX_PRESENT_POSITION);       
%        clf;
%        angle2=dxl_present_position;
%        hold on; grid on; axis([-scale,scale,-scale,scale,-scale,scale]); 
%        view(3);
%        plot3(cosd(180 - angle2).*alldistances.*cos(allangles)+0.05*sind(180 - angle2), alldistances.*sin(allangles),sind(180 - angle2).*alldistances.*cos(allangles)-0.05*cosd(180 - angle2),'.');
%        xlabel('x'); ylabel('y'); zlabel('z');
%        pause(0.01); 
%        key = get(gcf,'CurrentCharacter');
%        count = 0; 
%        alldistances = []; allangles = [];
%        [result] = ClearCacheRPLIDAR(pRPLIDAR);
%     end    
%     count = count+1;
%     toc
% end
%% RPLIDAR / Dynamixel 엔터 누르면 동작
% while 1 % Wait for ESC key (ASCII code 27).
%     if input('Press any key to continue! (or input e to quit!)\n', 's') == ESC_CHARACTER
%         break;
%     end
%     if dxl_direction=0;
%         SetAngle(port_num,PROTOCOL_VERSION,DXL_ID,ADDR_MOVING_SPEED,ADDR_MX_GOAL_POSITION,dxl_goal_position, 100);
%     else
%         SetAngle();
%     end
%     for count=1:361
%             [result, distances, angles, bNewScan, quality] = GetScanDataResponseRPLIDAR(pRPLIDAR);    
%             alldistances = [alldistances distances]; allangles = [allangles angles]; 
%             onedata=[distances;angles;dxl_present_position];
%             totaldata=[totaldata onedata];
%             if count > 360
%                dxl_present_position = GetAngle(lib_name,port_num, PROTOCOL_VERSION, DXL_ID, ADDR_MX_PRESENT_POSITION);
%                angle2=dxl_present_position;
% 
%                clf;
%                hold on; grid on; axis([-scale,scale,-scale,scale,-scale,scale]); 
%                view(3);
%                plot3(cosd(180 - angle2).*alldistances.*cos(allangles)+0.05*sind(180 - angle2), alldistances.*sin(allangles),sind(180 - angle2).*alldistances.*cos(allangles)-0.05*cosd(180 - angle2),'.');
%                xlabel('x'); ylabel('y'); zlabel('z');
%                pause(0.01); 
%                key = get(gcf,'CurrentCharacter'); 
%                alldistances = []; allangles = []; % angle2=[];
%             end
%     end
%     
% end
%%  한번 회전할때 스캔하는 명렴문 사용 ver
SetAngle(port_num,lib_name,PROTOCOL_VERSION,DXL_ID,ADDR_MOVING_SPEED,ADDR_MX_GOAL_POSITION,1500, 100);
anglecount=0;
 while (isempty(key)||(key ~= 27)) % Wait for ESC key (ASCII code 27).
%     if input('Press any key to continue! (or input e to quit!)\n', 's') == ESC_CHARACTER
%         break;
%     end
    if dxl_direction==0 %방향 바뀌는 것에 따라 달라짐
        SetAngle(port_num,lib_name,PROTOCOL_VERSION,DXL_ID,ADDR_MOVING_SPEED,ADDR_MX_GOAL_POSITION,1500+anglecount*20, 200);
    elseif dxl_direction==1
        SetAngle(port_num,lib_name,PROTOCOL_VERSION,DXL_ID,ADDR_MOVING_SPEED,ADDR_MX_GOAL_POSITION,2500-anglecount*20, 200);
    end
    anglecount=anglecount+1;
    fprintf('모터 회전\n');
    
    [alldistances, allangles]=GetScanOneCircle(pRPLIDAR);%360개의 점을 스캔
    fprintf('스캔완료\n');
    angle2 = GetAngle(lib_name,port_num, PROTOCOL_VERSION, DXL_ID, ADDR_MX_PRESENT_POSITION);%현재 모터 각도 스캔
    fprintf('모터 각도 확인\n');
%     cloud_data=horzcat(cloud_data,[cosd(180 - angle2).*alldistances.*cos(allangles)+0.05*sind(180 - angle2); alldistances.*sin(allangles);sind(180 - angle2).*alldistances.*cos(allangles)-0.05*cosd(180 - angle2)]);
    cloud_data=[cosd(180 - angle2).*alldistances.*cos(allangles)+0.05*sind(180 - angle2); alldistances.*sin(allangles);sind(180 - angle2).*alldistances.*cos(allangles)-0.05*cosd(180 - angle2)];
    tranMatrix=permute(cloud_data,[3 2 1]);
    Matrix_3D=cat(1,Matrix_3D,tranMatrix);%NxMx3행렬로 만들기 위해서 
    ptCloud=pointCloud(Matrix_3D);
    ptCloud=pcdenoise(ptCloud);
    pcshow(ptCloud);
    hold on;% grid on; axis([-scale,scale,-scale,scale,-scale,scale]); % 이 문단이 점을 3차원 공간에 나내는 명령문
    %view(3); 
    xlim([-6 6]); ylim([-6 6]); zlim([-6 6]);
    %plot3(cosd(180 - angle2).*alldistances.*cos(allangles)+0.05*sind(180 - angle2), alldistances.*sin(allangles),sind(180 - angle2).*alldistances.*cos(allangles)-0.05*cosd(180 - angle2),'.');
    xlabel('x'); ylabel('y'); zlabel('z');
    pause(0.01);
    key = get(gcf,'CurrentCharacter');
    if anglecount==50 && dxl_direction==0 %방향 바꾸는 조건문
        anglecount=0; dxl_direction=1;
    elseif anglecount==50 && dxl_direction==1
        anglecount=0; dxl_direction=0;
    end
    
 end

%%
close all;

[result]=RPLIDARend(pRPLIDAR);
clear pRPLIDAR; 
unloadlibrary('hardwarex');
DynamixelEnd(lib_name, port_num);