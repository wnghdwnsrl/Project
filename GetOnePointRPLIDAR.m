function [distances, angles]=GetOnePointRPLIDAR(pRPLIDAR)
    [result] = ClearCacheRPLIDAR(pRPLIDAR);
    if result~=0
        fprintf('버퍼 초기화 실패\n');
        return
    end
    [result, distances, angles, bNewScan, quality] = GetScanDataResponseRPLIDAR(pRPLIDAR); 
end