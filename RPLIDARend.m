function [result]=RPLIDARend(pRPLIDAR) 
        
        [result] = DisconnectRPLIDAR(pRPLIDAR);
        if result~=0
            fprintf('fail disconnect\n');
            return;
        else
            fprintf('Disconnected\n');
        end
        DestroyRPLIDAR(pRPLIDAR);
end