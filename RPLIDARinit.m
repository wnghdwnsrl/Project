function pRPLIDAR = RPLIDARinit()
    
    hardwarex_init;
    pRPLIDAR = CreateRPLIDAR();
    [result] = ConnectRPLIDAR(pRPLIDAR, 'RPLIDAR0.txt');
    if result~=0
        fprintf('Not connected\n');
        return;
    else
        fprintf('Connected\n');
    end
%     [result] = StopRequestRPLIDAR(pRPLIDAR);
%     if result~=0
%         fprintf('Not Stop\n');
%         return;
%     else
%         fprintf('Stop request\n');
%     end
end